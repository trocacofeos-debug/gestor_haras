import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/permissao_acesso.dart';

class SessaoUsuario {
  const SessaoUsuario({
    required this.tipo,
    this.funcionarioId,
    this.permissoes = const {},
  });

  final String tipo;
  final String? funcionarioId;
  final Set<String> permissoes;

  bool get administrativo =>
      tipo == 'admin' || tipo == 'superadmin' || tipo == 'funcionario';

  void aplicarAcesso() {
    if (tipo == 'funcionario') {
      ControleAcesso.configurarFuncionario(permissoes);
    } else {
      ControleAcesso.liberarTudo();
    }
  }
}

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ================= LOGIN =================
  Future<UserCredential> login(String email, String senha) async {
    return await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: senha.trim(),
    );
  }

  // ================= TIPO USUÁRIO =================
  Future<String> getTipoUsuario(String uid) async {
    return (await getSessaoUsuario(uid)).tipo;
  }

  Future<SessaoUsuario> getSessaoUsuario(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    final data = doc.data() ?? const <String, dynamic>{};
    final role = (data['role'] ?? 'cliente').toString().toLowerCase();
    if (role == 'admin' || role == 'superadmin') {
      return SessaoUsuario(tipo: role);
    }

    final funcionarioId = (data['funcionarioId'] ?? '').toString();
    if (role == 'funcionario' && funcionarioId.isNotEmpty) {
      final funcionario = await _db
          .collection('funcionarios')
          .doc(funcionarioId)
          .get();
      if (funcionario.exists && funcionario.data()?['ativo'] != false) {
        return SessaoUsuario(
          tipo: 'funcionario',
          funcionarioId: funcionarioId,
          permissoes: Set<String>.from(
            funcionario.data()?['permissoes'] ?? data['permissoes'] ?? const [],
          ),
        );
      }
    }

    final email = (_auth.currentUser?.email ?? data['email'] ?? '')
        .toString()
        .trim()
        .toLowerCase();
    if (email.isNotEmpty) {
      var funcionarios = await _db
          .collection('funcionarios')
          .where('emailNormalizado', isEqualTo: email)
          .limit(1)
          .get();
      if (funcionarios.docs.isEmpty) {
        funcionarios = await _db
            .collection('funcionarios')
            .where('email', isEqualTo: email)
            .limit(1)
            .get();
      }
      if (funcionarios.docs.isNotEmpty) {
        final funcionario = funcionarios.docs.single;
        if (funcionario.data()['ativo'] != false) {
          final permissoes = Set<String>.from(
            funcionario.data()['permissoes'] ?? const [],
          );
          return SessaoUsuario(
            tipo: 'funcionario',
            funcionarioId: funcionario.id,
            permissoes: permissoes,
          );
        }
      }
    }
    return const SessaoUsuario(tipo: 'cliente');
  }

  // ================= LOGOUT =================
  Future<void> logout() async {
    ControleAcesso.limpar();
    await _auth.signOut();
  }

  // ================= USUÁRIO ATUAL =================
  User? get user => _auth.currentUser;
}
