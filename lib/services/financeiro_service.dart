import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/conta_financeira_model.dart';

class FinanceiroService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  static const String collection = 'contasFinanceiras';

  Future<void> criarConta(ContaFinanceiraModel conta) async {
    await _db.collection(collection).add(conta.toMap());
  }

  Stream<List<ContaFinanceiraModel>> listarContas() {
    return _db
        .collection(collection)
        .orderBy('vencimento', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => ContaFinanceiraModel.fromDoc(d)).toList());
  }

  /// 🔥 PAGAR SOMENTE UMA PARCELA
  Future<void> pagarParcela(String id) async {
    await _db.collection(collection).doc(id).update({
      'status': 'pago',
      'dataPagamento': Timestamp.now(),
    });
  }

  Future<Map<String, double>> resumoFinanceiro() async {
    final snap = await _db.collection(collection).get();

    double total = 0;
    double pago = 0;
    double pendente = 0;

    for (final doc in snap.docs) {
      final v = doc['valor'];

      final valor = (v is int)
          ? v.toDouble()
          : (v is double ? v : double.tryParse(v.toString()) ?? 0);

      total += valor;

      if (doc['status'] == 'pago') {
        pago += valor;
      } else {
        pendente += valor;
      }
    }

    return {
      'total': total,
      'pago': pago,
      'pendente': pendente,
    };
  }
}