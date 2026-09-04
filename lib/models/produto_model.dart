import 'package:cloud_firestore/cloud_firestore.dart';

import 'medicamento_model.dart';

class ProdutoModel {
  const ProdutoModel({
    required this.id,
    required this.nome,
    required this.tipo,
    required this.quantidadePadrao,
    required this.valorCentavos,
    this.quantidadeEstoque = 0,
    this.fornecedorId = '',
    this.fornecedorNome = '',
    this.fotoUrl = '',
    this.observacoes = '',
    this.ativo = true,
  });

  final String id;
  final String nome;
  final TipoTratamento tipo;
  final String quantidadePadrao;
  final int valorCentavos;
  final double quantidadeEstoque;
  final String fornecedorId;
  final String fornecedorNome;
  final String fotoUrl;
  final String observacoes;
  final bool ativo;

  double get valor => valorCentavos / 100;

  ProdutoModel copyWith({String? id, bool? ativo}) => ProdutoModel(
    id: id ?? this.id,
    nome: nome,
    tipo: tipo,
    quantidadePadrao: quantidadePadrao,
    valorCentavos: valorCentavos,
    quantidadeEstoque: quantidadeEstoque,
    fornecedorId: fornecedorId,
    fornecedorNome: fornecedorNome,
    fotoUrl: fotoUrl,
    observacoes: observacoes,
    ativo: ativo ?? this.ativo,
  );

  factory ProdutoModel.fromMap(Map<String, dynamic> map, String id) {
    final tipo = TipoTratamento.values.firstWhere(
      (item) => item.name == map['tipo'],
      orElse: () => TipoTratamento.remedio,
    );
    return ProdutoModel(
      id: id,
      nome: (map['nome'] ?? '').toString(),
      tipo: tipo,
      quantidadePadrao: (map['quantidadePadrao'] ?? '').toString(),
      valorCentavos: map['valorCentavos'] is num
          ? (map['valorCentavos'] as num).round()
          : (((map['valor'] as num?) ?? 0) * 100).round(),
      quantidadeEstoque: (map['quantidadeEstoque'] as num?)?.toDouble() ?? 0,
      fornecedorId: (map['fornecedorId'] ?? '').toString(),
      fornecedorNome: (map['fornecedorNome'] ?? '').toString(),
      fotoUrl: (map['fotoUrl'] ?? '').toString(),
      observacoes: (map['observacoes'] ?? '').toString(),
      ativo: map['ativo'] != false,
    );
  }

  Map<String, dynamic> toMap() => {
    'nome': nome.trim(),
    'tipo': tipo.name,
    'quantidadePadrao': quantidadePadrao.trim(),
    'valorCentavos': valorCentavos,
    'valor': valor,
    'quantidadeEstoque': quantidadeEstoque,
    'fornecedorId': fornecedorId,
    'fornecedorNome': fornecedorNome,
    'fotoUrl': fotoUrl,
    'observacoes': observacoes.trim(),
    'ativo': ativo,
    'atualizadoEm': FieldValue.serverTimestamp(),
  };
}
