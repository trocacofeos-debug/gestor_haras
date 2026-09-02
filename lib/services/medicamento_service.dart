import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/cavalo_model.dart';
import '../models/medicamento_model.dart';

String idDespesaTratamento(MedicamentoModel plano, DateTime data) =>
    '${plano.tipo.name}_${plano.id}_${chaveDataTratamento(data)}';

String chaveDataTratamento(DateTime data) =>
    '${data.year.toString().padLeft(4, '0')}'
    '${data.month.toString().padLeft(2, '0')}'
    '${data.day.toString().padLeft(2, '0')}';

Map<String, dynamic> dadosDespesaTratamento(
  MedicamentoModel plano,
  DateTime data,
) => {
  'categoria': plano.tipo.categoriaDespesa,
  'descricao': '${plano.tipo.singularCapital}: ${plano.nome} • ${plano.dose}',
  'valor': plano.valor,
  'data': Timestamp.fromDate(somenteData(data)),
  'origem': 'plano_${plano.tipo.name}',
  'tratamentoId': plano.id,
  'tratamentoTipo': plano.tipo.name,
  'tratamentoNome': plano.nome,
  'frequencia': plano.frequencia.name,
  'aplicacao': chaveDataTratamento(data),
  'automatico': true,
};

abstract class MedicamentoRepository {
  Stream<List<MedicamentoModel>> observar();
  Future<List<CavaloModel>> listarAnimais();
  Future<void> cadastrar(MedicamentoModel medicamento);
  Future<int> sincronizarTudo();
  Future<void> encerrar(String id);
  Future<int> limparHistorico();
}

/// Reúne os lançamentos antigos em uma única tela, sem perder dados.
class LancamentosRepository implements MedicamentoRepository {
  LancamentosRepository({FirebaseFirestore? firestore})
    : _servicos = {
        for (final tipo in TipoTratamento.values)
          tipo: MedicamentoService(firestore: firestore, tipo: tipo),
      };

  final Map<TipoTratamento, MedicamentoService> _servicos;

  @override
  Stream<List<MedicamentoModel>> observar() {
    final ultimos = <TipoTratamento, List<MedicamentoModel>>{};
    final assinaturas = <StreamSubscription<List<MedicamentoModel>>>[];
    late final StreamController<List<MedicamentoModel>> controller;

    void emitir() {
      if (ultimos.length != _servicos.length || controller.isClosed) return;
      final produtos =
          <MedicamentoModel>[
            for (final entry in ultimos.entries)
              for (final item in entry.value)
                item.copyWith(
                  id: '${entry.key.name}:${item.id}',
                  tipo: entry.key,
                ),
          ]..sort((a, b) {
            if (a.ativo != b.ativo) return a.ativo ? -1 : 1;
            return a.nome.toLowerCase().compareTo(b.nome.toLowerCase());
          });
      controller.add(produtos);
    }

    controller = StreamController<List<MedicamentoModel>>(
      onListen: () {
        for (final entry in _servicos.entries) {
          assinaturas.add(
            entry.value.observar().listen((itens) {
              ultimos[entry.key] = itens;
              emitir();
            }, onError: controller.addError),
          );
        }
      },
      onCancel: () async {
        for (final assinatura in assinaturas) {
          await assinatura.cancel();
        }
      },
    );
    return controller.stream;
  }

  @override
  Future<List<CavaloModel>> listarAnimais() =>
      _servicos[TipoTratamento.remedio]!.listarAnimais();

  @override
  Future<void> cadastrar(MedicamentoModel medicamento) =>
      _servicos[medicamento.tipo]!.cadastrar(medicamento);

  @override
  Future<int> sincronizarTudo() async {
    var total = 0;
    for (final servico in _servicos.values) {
      total += await servico.sincronizarTudo();
    }
    return total;
  }

  @override
  Future<void> encerrar(String id) {
    final separador = id.indexOf(':');
    if (separador < 1) {
      return _servicos[TipoTratamento.remedio]!.encerrar(id);
    }
    final nomeTipo = id.substring(0, separador);
    final tipo = TipoTratamento.values.firstWhere(
      (item) => item.name == nomeTipo,
      orElse: () => TipoTratamento.remedio,
    );
    return _servicos[tipo]!.encerrar(id.substring(separador + 1));
  }

  @override
  Future<int> limparHistorico() async {
    var total = 0;
    for (final servico in _servicos.values) {
      total += await servico.limparHistorico();
    }
    return total;
  }
}

class MedicamentoSalvoSemSincronizar implements Exception {
  const MedicamentoSalvoSemSincronizar(this.causa);
  final Object causa;
}

class MedicamentoService implements MedicamentoRepository {
  MedicamentoService({this.firestore, this.tipo = TipoTratamento.remedio});
  final FirebaseFirestore? firestore;
  final TipoTratamento tipo;

  FirebaseFirestore get _db => firestore ?? FirebaseFirestore.instance;
  CollectionReference<Map<String, dynamic>> get _planos =>
      _db.collection(tipo.colecao);

  @override
  Stream<List<MedicamentoModel>> observar() => _planos.snapshots().map((
    snapshot,
  ) {
    final lista = snapshot.docs
        .map(
          (doc) =>
              MedicamentoModel.fromMap(doc.data(), doc.id).copyWith(tipo: tipo),
        )
        .toList();
    lista.sort((a, b) {
      if (a.ativo != b.ativo) return a.ativo ? -1 : 1;
      return a.nome.toLowerCase().compareTo(b.nome.toLowerCase());
    });
    return lista;
  });

  @override
  Future<List<CavaloModel>> listarAnimais() async {
    final snapshot = await _db
        .collection('cavalos')
        .get(const GetOptions(source: Source.server));
    final lista = snapshot.docs
        .map((doc) => CavaloModel.fromMap(doc.data(), doc.id))
        .toList();
    lista.sort((a, b) => a.nome.toLowerCase().compareTo(b.nome.toLowerCase()));
    return lista;
  }

  @override
  Future<void> cadastrar(MedicamentoModel medicamento) async {
    final referencia = _planos.doc();
    final salvo = medicamento.copyWith(id: referencia.id, tipo: tipo);
    await referencia.set({
      ...salvo.toMap(),
      'criadoEm': FieldValue.serverTimestamp(),
    });
    try {
      await _sincronizarPlano(salvo);
    } catch (erro) {
      throw MedicamentoSalvoSemSincronizar(erro);
    }
  }

  @override
  Future<int> sincronizarTudo() async {
    final planos = await _planos
        .where('ativo', isEqualTo: true)
        .get(const GetOptions(source: Source.server));
    var total = 0;
    for (final doc in planos.docs) {
      total += await _sincronizarPlano(
        MedicamentoModel.fromMap(doc.data(), doc.id).copyWith(tipo: tipo),
      );
    }
    return total;
  }

  Future<int> _sincronizarPlano(MedicamentoModel plano) async {
    final ocorrencias = plano.ocorrenciasPendentes(DateTime.now());
    if (ocorrencias.isEmpty || plano.animalIds.isEmpty) return 0;
    if (ocorrencias.length * plano.animalIds.length > 5000) {
      throw StateError(
        'O período gera mais de 5.000 lançamentos. Informe uma data inicial mais recente.',
      );
    }

    final existentes = await _db
        .collection('cavalos')
        .where(FieldPath.documentId, whereIn: plano.animalIds.take(30).toList())
        .get(const GetOptions(source: Source.server));
    final idsExistentes = existentes.docs.map((doc) => doc.id).toSet();
    // Firestore limita whereIn; consulta os animais restantes em blocos.
    for (var i = 30; i < plano.animalIds.length; i += 30) {
      final bloco = plano.animalIds.skip(i).take(30).toList();
      final snapshot = await _db
          .collection('cavalos')
          .where(FieldPath.documentId, whereIn: bloco)
          .get(const GetOptions(source: Source.server));
      idsExistentes.addAll(snapshot.docs.map((doc) => doc.id));
    }

    var batch = _db.batch();
    var operacoes = 0;
    var total = 0;
    Future<void> enviarSeCheio() async {
      if (operacoes < 400) return;
      await batch.commit();
      batch = _db.batch();
      operacoes = 0;
    }

    for (final data in ocorrencias) {
      for (final animalId in plano.animalIds.where(idsExistentes.contains)) {
        final referencia = _db
            .collection('cavalos')
            .doc(animalId)
            .collection('despesas')
            .doc(idDespesaTratamento(plano, data));
        batch.set(referencia, dadosDespesaTratamento(plano, data));
        operacoes++;
        total++;
        await enviarSeCheio();
      }
    }
    if (operacoes > 0) await batch.commit();
    await _planos.doc(plano.id).update({
      'sincronizadoAte': Timestamp.fromDate(ocorrencias.last),
      'atualizadoEm': FieldValue.serverTimestamp(),
    });
    return total;
  }

  @override
  Future<void> encerrar(String id) => _planos.doc(id).update({
    'ativo': false,
    'atualizadoEm': FieldValue.serverTimestamp(),
  });

  @override
  Future<int> limparHistorico() async {
    final encerrados = await _planos
        .where('ativo', isEqualTo: false)
        .get(const GetOptions(source: Source.server));
    if (encerrados.docs.isEmpty) return 0;

    for (var inicio = 0; inicio < encerrados.docs.length; inicio += 400) {
      final batch = _db.batch();
      for (final doc in encerrados.docs.skip(inicio).take(400)) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    }
    return encerrados.docs.length;
  }
}
