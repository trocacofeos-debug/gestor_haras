import 'package:cloud_firestore/cloud_firestore.dart';

class ContaReceberService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  static const String collection = 'contas_receber';

  // ==========================
  // GERAR CONTA
  // ==========================
  Future<void> gerarConta({
    required String clienteId,
    required String clienteNome,
    required double valor,
    required String descricao,
    required DateTime vencimento,
  }) async {
    await _db.collection(collection).add({
      'clienteId': clienteId,
      'clienteNome': clienteNome,
      'valor': valor,
      'descricao': descricao,
      'status': 'pendente',
      'dataVenda': Timestamp.now(),
      'dataVencimento': Timestamp.fromDate(vencimento),
      'createdAt': Timestamp.now(),
    });
  }

  // ==========================
  // LISTAR CONTAS
  // ==========================
  Stream<QuerySnapshot<Map<String, dynamic>>> listarContas() {
    return _db
        .collection(collection)
        .orderBy('dataVencimento')
        .snapshots();
  }

  // ==========================
  // CONTAS PENDENTES
  // ==========================
  Stream<QuerySnapshot<Map<String, dynamic>>> listarPendentes() {
    return _db
        .collection(collection)
        .where('status', isEqualTo: 'pendente')
        .orderBy('dataVencimento')
        .snapshots();
  }

  // ==========================
  // CONTAS PAGAS
  // ==========================
  Stream<QuerySnapshot<Map<String, dynamic>>> listarPagas() {
    return _db
        .collection(collection)
        .where('status', isEqualTo: 'pago')
        .orderBy('dataVencimento')
        .snapshots();
  }

  // ==========================
  // MARCAR COMO PAGO
  // ==========================
  Future<void> marcarComoPago(String id) async {
    await _db.collection(collection).doc(id).update({
      'status': 'pago',
      'dataPagamento': Timestamp.now(),
    });
  }

  // ==========================
  // EXCLUIR
  // ==========================
  Future<void> excluir(String id) async {
    await _db.collection(collection).doc(id).delete();
  }

  // ==========================
  // TOTAL GERAL
  // ==========================
  Future<double> totalGeral() async {
    final snap = await _db.collection(collection).get();

    double total = 0;

    for (var doc in snap.docs) {
      total += (doc.data()['valor'] ?? 0).toDouble();
    }

    return total;
  }

  // ==========================
  // TOTAL POR STATUS
  // ==========================
  Future<double> totalPorStatus(String status) async {
    final snap = await _db
        .collection(collection)
        .where('status', isEqualTo: status)
        .get();

    double total = 0;

    for (var doc in snap.docs) {
      total += (doc.data()['valor'] ?? 0).toDouble();
    }

    return total;
  }

  // ==========================
  // TOTAL PENDENTE
  // ==========================
  Future<double> totalPendente() async {
    return totalPorStatus('pendente');
  }

  // ==========================
  // TOTAL PAGO
  // ==========================
  Future<double> totalPago() async {
    return totalPorStatus('pago');
  }
}