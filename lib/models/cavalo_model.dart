import 'package:cloud_firestore/cloud_firestore.dart';

class CavaloModel {
  final String id;

  final String nome;
  final String raca;
  final String sexo;
  final String pelagem;

  final String proprietarioId;
  final String proprietarioNome;

  final List<String> fotos;
  final double preco;

  final String observacoes;

  final bool ativo;

  final Timestamp? dataCadastro;

  const CavaloModel({
    required this.id,
    this.nome = '',
    this.raca = '',
    this.sexo = '',
    this.pelagem = '',
    this.proprietarioId = '',
    this.proprietarioNome = '',
    this.fotos = const [],
    this.preco = 0,
    this.observacoes = '',
    this.ativo = true,
    this.dataCadastro,
  });

  factory CavaloModel.fromMap(
    Map<String, dynamic> map,
    String id,
  ) {
    return CavaloModel(
      id: id,
      nome: map['nome'] ?? '',
      raca: map['raca'] ?? '',
      sexo: map['sexo'] ?? '',
      pelagem: map['pelagem'] ?? '',
      proprietarioId: map['proprietarioId'] ?? '',
      proprietarioNome: map['proprietarioNome'] ?? '',
      fotos: map['fotos'] != null
          ? List<String>.from(map['fotos'])
          : const [],
      preco: (map['preco'] ?? 0).toDouble(),
      observacoes: map['observacoes'] ?? '',
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
      'proprietarioId': proprietarioId,
      'proprietarioNome': proprietarioNome,
      'fotos': fotos,
      'preco': preco,
      'observacoes': observacoes,
      'ativo': ativo,
      'dataCadastro': dataCadastro ?? Timestamp.now(),
    };
  }
}