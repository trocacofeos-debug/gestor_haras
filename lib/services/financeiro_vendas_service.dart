import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/financeiro_vendas.dart';

class FinanceiroVendasService {
  const FinanceiroVendasService({this.firestore});

  final FirebaseFirestore? firestore;

  Future<FinanceiroVendasDados> carregar() async {
    final db = firestore ?? FirebaseFirestore.instance;
    const opcoes = GetOptions(source: Source.server);
    final dividas = await db.collection('dividas').get(opcoes);
    final vendas = <VendaFinanceira>[];
    var invalidos = 0;

    for (var indice = 0; indice < dividas.docs.length; indice += 5) {
      await Future.wait(
        dividas.docs.skip(indice).take(5).map((divida) async {
          final dados = divida.data();
          final total = centavosDeVenda(dados['valorTotal']);
          if (total == null) {
            invalidos++;
            return;
          }
          final parcelas = await divida.reference
              .collection('parcelas')
              .get(opcoes);
          var pago = 0;
          if (parcelas.docs.isEmpty) {
            if (statusVendaPago(dados['status'])) pago = total;
          } else {
            for (final parcela in parcelas.docs) {
              if (!statusVendaPago(parcela.data()['status'])) continue;
              final valor = centavosDeVenda(parcela.data()['valor']);
              if (valor == null) {
                invalidos++;
              } else {
                pago += valor;
              }
            }
          }
          vendas.add(
            VendaFinanceira(
              id: divida.id,
              clienteNome: (dados['clienteNome'] ?? 'Cliente').toString(),
              descricao: (dados['descricao'] ?? 'Venda').toString(),
              totalCentavos: total,
              pagoCentavos: pago < 0 ? 0 : (pago > total ? total : pago),
              data: dataVenda(dados['dataCriacao']),
            ),
          );
        }),
      );
    }
    vendas.sort((a, b) {
      if (a.data == null) return b.data == null ? 0 : 1;
      if (b.data == null) return -1;
      return b.data!.compareTo(a.data!);
    });
    return FinanceiroVendasDados(vendas: vendas, registrosInvalidos: invalidos);
  }
}
