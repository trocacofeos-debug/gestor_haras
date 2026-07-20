import 'package:cloud_firestore/cloud_firestore.dart';

class ContaFinanceiraModel {
  final String id;

  final String clienteId;
  final String clienteNome;

  final String descricao;
  final double valor;

  final String tipo; // receber | pagar
  final String status; // pendente | pago | atrasado

  final String categoria;
  final String observacao;

  final Timestamp vencimento;
  final Timestamp dataCriacao;
  final Timestamp? dataPagamento;

  final int parcelas;
  final int parcelaAtual;

  const ContaFinanceiraModel({
    this.id = '',
    required this.clienteId,
    required this.clienteNome,
    required this.descricao,
    required this.valor,
    required this.tipo,
    required this.status,
    required this.categoria,
    required this.observacao,
    required this.vencimento,
    required this.dataCriacao,
    this.dataPagamento,
    this.parcelas = 1,
    this.parcelaAtual = 1,
  });

  factory ContaFinanceiraModel.fromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>? ?? {};

    double parseDouble(dynamic v) {
      if (v is int) return v.toDouble();
      if (v is double) return v;
      if (v is String) return double.tryParse(v) ?? 0;
      return 0;
    }

    Timestamp parseTimestamp(dynamic v) {
      if (v is Timestamp) return v;
      return Timestamp.now();
    }

    return ContaFinanceiraModel(
      id: doc.id,
      clienteId: d['clienteId'] ?? '',
      clienteNome: d['clienteNome'] ?? '',
      descricao: d['descricao'] ?? '',
      valor: parseDouble(d['valor']),
      tipo: d['tipo'] ?? 'receber',
      status: d['status'] ?? 'pendente',
      categoria: d['categoria'] ?? '',
      observacao: d['observacao'] ?? '',
      vencimento: parseTimestamp(d['vencimento']),
      dataCriacao: parseTimestamp(d['dataCriacao']),
      dataPagamento: d['dataPagamento'],
      parcelas: d['parcelas'] ?? 1,
      parcelaAtual: d['parcelaAtual'] ?? 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'clienteId': clienteId,
      'clienteNome': clienteNome,
      'descricao': descricao,
      'valor': valor,
      'tipo': tipo,
      'status': status,
      'categoria': categoria,
      'observacao': observacao,
      'vencimento': vencimento,
      'dataCriacao': dataCriacao,
      'dataPagamento': dataPagamento,
      'parcelas': parcelas,
      'parcelaAtual': parcelaAtual,
    };
  }

  bool get pago => status == 'pago';
  bool get pendente => status == 'pendente';

  bool get atrasado {
    if (status == 'pago') return false;
    return vencimento.toDate().isBefore(DateTime.now());
  }
}