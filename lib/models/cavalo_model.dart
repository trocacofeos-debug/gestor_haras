import 'package:cloud_firestore/cloud_firestore.dart';
import 'ficha_abccmm.dart';
import 'genealogia_abccmm.dart';

class CavaloModel {
  final String id;

  final String nome;
  final String raca;
  final String sexo;
  final String pelagem;
  final String registroAbccmm;
  final String pai;
  final String mae;
  final FichaAbccmm fichaAbccmm;
  final GenealogiaAbccmm? genealogiaAbccmm;

  /// Altura em metros e peso em quilogramas; null quando não informados.
  final double? altura;
  final double? peso;

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
    this.registroAbccmm = '',
    this.pai = '',
    this.mae = '',
    this.fichaAbccmm = const FichaAbccmm(),
    this.genealogiaAbccmm,
    this.altura,
    this.peso,
    this.proprietarioId = '',
    this.proprietarioNome = '',
    this.fotos = const [],
    this.preco = 0,
    this.observacoes = '',
    this.ativo = true,
    this.dataCadastro,
  });

  factory CavaloModel.fromMap(Map<String, dynamic> map, String id) {
    return CavaloModel(
      id: id,
      nome: map['nome'] ?? '',
      raca: map['raca'] ?? '',
      sexo: map['sexo'] ?? '',
      pelagem: map['pelagem'] ?? '',
      registroAbccmm: map['registroAbccmm'] ?? '',
      pai: map['pai'] ?? '',
      mae: map['mae'] ?? '',
      fichaAbccmm: FichaAbccmm.fromMap(
        map['fichaAbccmm'] is Map
            ? Map<String, dynamic>.from(map['fichaAbccmm'] as Map)
            : const {},
      ),
      altura: (map['altura'] as num?)?.toDouble(),
      genealogiaAbccmm: map['genealogiaAbccmm'] is Map
          ? GenealogiaAbccmm.fromMap(
              Map<String, dynamic>.from(map['genealogiaAbccmm'] as Map),
            )
          : null,
      peso: (map['peso'] as num?)?.toDouble(),
      proprietarioId: map['proprietarioId'] ?? '',
      proprietarioNome: map['proprietarioNome'] ?? '',
      fotos: map['fotos'] != null ? List<String>.from(map['fotos']) : const [],
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
      'registroAbccmm': registroAbccmm,
      'pai': pai,
      'mae': mae,
      'fichaAbccmm': fichaAbccmm.toMap(),
      'genealogiaAbccmm': genealogiaAbccmm?.toMap(),
      'altura': altura,
      'peso': peso,
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
