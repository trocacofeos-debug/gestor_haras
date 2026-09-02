import 'package:cloud_firestore/cloud_firestore.dart';

class ResultadoPermissoesFuncionario {
  const ResultadoPermissoesFuncionario({required this.contasVinculadas});

  final int contasVinculadas;
}

class ContaAcessoFuncionario {
  const ContaAcessoFuncionario({
    required this.uid,
    required this.email,
    required this.role,
    required this.funcionarioId,
  });

  final String uid;
  final String email;
  final String role;
  final String funcionarioId;

  bool vinculadaAo(String id) => funcionarioId == id && role == 'funcionario';
}

abstract class FuncionarioContasRepository {
  Stream<List<ContaAcessoFuncionario>> listarContas();

  Future<void> vincularComoFuncionario({
    required String uid,
    required String funcionarioId,
    required Set<String> permissoes,
  });
}

abstract class FuncionarioPermissoesRepository {
  Future<ResultadoPermissoesFuncionario> salvar({
    required String funcionarioId,
    required String email,
    required Set<String> permissoes,
  });
}

class FuncionarioPermissoesService implements FuncionarioPermissoesRepository {
  FuncionarioPermissoesService({FirebaseFirestore? firestore})
    : firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore firestore;

  @override
  Future<ResultadoPermissoesFuncionario> salvar({
    required String funcionarioId,
    required String email,
    required Set<String> permissoes,
  }) async {
    final lista = permissoes.toList()..sort();
    final emailNormalizado = email.trim().toLowerCase();
    await firestore.collection('funcionarios').doc(funcionarioId).update({
      'permissoes': lista,
      'emailNormalizado': emailNormalizado,
      'permissoesAtualizadasEm': FieldValue.serverTimestamp(),
    });

    var vinculadas = 0;
    try {
      final porFuncionario = await firestore
          .collection('users')
          .where('funcionarioId', isEqualTo: funcionarioId)
          .get(const GetOptions(source: Source.server));
      final porEmail = emailNormalizado.isEmpty
          ? null
          : await firestore
                .collection('users')
                .where('email', isEqualTo: emailNormalizado)
                .get(const GetOptions(source: Source.server));
      final usuarios = {
        for (final usuario in [...porFuncionario.docs, ...?porEmail?.docs])
          usuario.id: usuario,
      };
      for (final usuario in usuarios.values) {
        final role = (usuario.data()['role'] ?? '').toString().toLowerCase();
        if (role == 'admin' || role == 'superadmin') continue;
        await usuario.reference.set({
          'role': 'funcionario',
          'funcionarioId': funcionarioId,
          'permissoes': lista,
          'atualizadoEm': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
        vinculadas++;
      }
    } on FirebaseException {
      // O vínculo é opcional: o login ainda encontra o funcionário pelo e-mail.
    }
    return ResultadoPermissoesFuncionario(contasVinculadas: vinculadas);
  }
}

class FuncionarioContasService implements FuncionarioContasRepository {
  FuncionarioContasService({FirebaseFirestore? firestore})
    : firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore firestore;

  @override
  Stream<List<ContaAcessoFuncionario>> listarContas() {
    return firestore.collection('users').snapshots().map((snapshot) {
      final contas = <ContaAcessoFuncionario>[];
      for (final doc in snapshot.docs) {
        final data = doc.data();
        final role = (data['role'] ?? 'cliente').toString().toLowerCase();
        if (role == 'admin' || role == 'superadmin') continue;
        contas.add(
          ContaAcessoFuncionario(
            uid: doc.id,
            email: (data['email'] ?? '').toString(),
            role: role,
            funcionarioId: (data['funcionarioId'] ?? '').toString(),
          ),
        );
      }
      contas.sort((a, b) => a.email.compareTo(b.email));
      return contas;
    });
  }

  @override
  Future<void> vincularComoFuncionario({
    required String uid,
    required String funcionarioId,
    required Set<String> permissoes,
  }) async {
    final usuario = firestore.collection('users').doc(uid);
    final lista = permissoes.toList()..sort();
    await firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(usuario);
      if (!snapshot.exists) {
        throw StateError('A conta selecionada não existe mais.');
      }
      final role = (snapshot.data()?['role'] ?? 'cliente')
          .toString()
          .toLowerCase();
      if (role == 'admin' || role == 'superadmin') {
        throw StateError('Uma conta de administrador não pode ser alterada.');
      }
      transaction.set(usuario, {
        'role': 'funcionario',
        'funcionarioId': funcionarioId,
        'permissoes': lista,
        'ativo': true,
        'atualizadoEm': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    });
  }
}
