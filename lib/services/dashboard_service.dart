import 'package:cloud_firestore/cloud_firestore.dart';

class DashboardService {
  final FirebaseFirestore db = FirebaseFirestore.instance;

  // =========================
  // RESUMO GERAL
  // =========================
  Future<Map<String, dynamic>> getResumo() async {
    final clientesSnap = await db.collection('clientes').get();
    final contasSnap =
        await db.collection('contasFinanceiras').get();

    double recebido = 0;
    double pendente = 0;

    for (final doc in contasSnap.docs) {
      final data = doc.data();

      final valor = (data['valor'] is num)
          ? (data['valor'] as num).toDouble()
          : double.tryParse(data['valor'].toString()) ?? 0;

      final status = (data['status'] ?? 'pendente').toString();

      if (status == 'pago') {
        recebido += valor;
      } else {
        pendente += valor;
      }
    }

    return {
      'clientes': clientesSnap.size,
      'recebido': recebido,
      'pendente': pendente,
      'total': recebido + pendente,
    };
  }

  // =========================
  // ÚLTIMOS CLIENTES (SEGURO)
  // =========================
  Stream<QuerySnapshot> ultimosClientes() {
    return db
        .collection('clientes')
        .where('dataCadastro', isNotEqualTo: null)
        .orderBy('dataCadastro', descending: true)
        .limit(5)
        .snapshots()
        .handleError((error) {
      // ignore: avoid_print
      print('Erro ultimosClientes: $error');
    });
  }
}