import 'package:cloud_firestore/cloud_firestore.dart';

class VendaFinanceira {
  const VendaFinanceira({
    required this.id,
    required this.clienteNome,
    required this.descricao,
    required this.totalCentavos,
    required this.pagoCentavos,
    required this.data,
  });

  final String id;
  final String clienteNome;
  final String descricao;
  final int totalCentavos;
  final int pagoCentavos;
  final DateTime? data;

  int get pendenteCentavos {
    final valor = totalCentavos - pagoCentavos;
    if (valor < 0) return 0;
    return valor > totalCentavos ? totalCentavos : valor;
  }

  bool get quitada => totalCentavos > 0 && pendenteCentavos == 0;
}

class FinanceiroVendasDados {
  const FinanceiroVendasDados({
    required this.vendas,
    this.registrosInvalidos = 0,
  });

  final List<VendaFinanceira> vendas;
  final int registrosInvalidos;

  int get quantidadeVendas => vendas.length;
  int get vendasQuitadas => vendas.where((item) => item.quitada).length;
  int get totalCentavos =>
      vendas.fold(0, (total, item) => total + item.totalCentavos);
  int get pagoCentavos =>
      vendas.fold(0, (total, item) => total + item.pagoCentavos);
  int get pendenteCentavos =>
      vendas.fold(0, (total, item) => total + item.pendenteCentavos);
}

int? centavosDeVenda(Object? valor) {
  if (valor is! num || !valor.isFinite || valor < 0) return null;
  return (valor * 100).round();
}

bool statusVendaPago(Object? valor) {
  final status = (valor ?? '').toString().trim().toLowerCase();
  return status == 'pago' ||
      status == 'quitada' ||
      status == 'quitado' ||
      status == 'recebido';
}

DateTime? dataVenda(Object? valor) => valor is Timestamp
    ? valor.toDate()
    : valor is DateTime
    ? valor
    : null;
