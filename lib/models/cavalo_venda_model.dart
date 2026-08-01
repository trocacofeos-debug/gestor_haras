import 'package:cloud_firestore/cloud_firestore.dart';

class CavaloVendaModel {
  final String id;

  final String nome;
  final String raca;
  final String sexo;
  final String pelagem;
  final int idade;

  final double valor;
  final List<String> fotos;

  final String descricao;

  final bool ativo;

  final Timestamp? dataCadastro;

  const CavaloVendaModel({
    required this.id,
    this.nome = '',
    this.raca = '',
    this.sexo = '',
    this.pelagem = '',
    this.idade = 0,
    this.valor = 0,
    this.fotos = const [],
    this.descricao = '',
    this.ativo = true,
    this.dataCadastro,
  });

  factory CavaloVendaModel.fromMap(
    Map<String, dynamic> map,
    String id,
  ) {
    return CavaloVendaModel(
      id: id,
      nome: map['nome'] ?? '',
      raca: map['raca'] ?? '',
      sexo: map['sexo'] ?? '',
      pelagem: map['pelagem'] ?? '',
      idade: (map['idade'] ?? 0) is int
          ? map['idade'] ?? 0
          : int.tryParse(map['idade'].toString()) ?? 0,
      valor: (map['valor'] ?? 0).toDouble(),
      fotos: map['fotos'] != null
          ? List<String>.from(map['fotos'])
          : const [],
      descricao: map['descricao'] ?? '',
      ativo: map['ativo'] ?? true,
      dataCadastro: map['dataCadastro'] as Timestamp?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'raca': raca,
      'sexo': sexo,
      'pelagem': pelagem,
      'idade': idade,
      'valor': valor,
      'fotos': fotos,
      'descricao': descricao,
      'ativo': ativo,
      'dataCadastro': dataCadastro ?? Timestamp.now(),
    };
  }
}