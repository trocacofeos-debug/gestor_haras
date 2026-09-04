import 'package:cloud_firestore/cloud_firestore.dart';

enum TipoRegistroAnimal { controle, treinamento, reproducao }

extension TipoRegistroAnimalExt on TipoRegistroAnimal {
  String get titulo => switch (this) {
    TipoRegistroAnimal.controle => 'Altura, peso e controle',
    TipoRegistroAnimal.treinamento => 'Treinamento',
    TipoRegistroAnimal.reproducao => 'Reprodução',
  };

  String get nomeRegistro => switch (this) {
    TipoRegistroAnimal.controle => 'controle',
    TipoRegistroAnimal.treinamento => 'treinamento',
    TipoRegistroAnimal.reproducao => 'registro reprodutivo',
  };
}

class RegistroAnimalModel {
  const RegistroAnimalModel({
    required this.id,
    required this.tipo,
    required this.animalId,
    required this.animalNome,
    required this.data,
    this.titulo = '',
    this.status = '',
    this.observacoes = '',
    this.pai = '',
    this.mae = '',
    this.dataNascimento,
    this.alturaMetros,
    this.pesoKg,
  });

  final String id;
  final TipoRegistroAnimal tipo;
  final String animalId;
  final String animalNome;
  final DateTime data;
  final String titulo;
  final String status;
  final String observacoes;
  final String pai;
  final String mae;
  final DateTime? dataNascimento;
  final double? alturaMetros;
  final double? pesoKg;

  factory RegistroAnimalModel.fromMap(Map<String, dynamic> map, String id) {
    final tipo = TipoRegistroAnimal.values.firstWhere(
      (item) => item.name == map['tipo'],
      orElse: () => TipoRegistroAnimal.controle,
    );
    final data = map['data'];
    final nascimento = map['dataNascimento'];
    return RegistroAnimalModel(
      id: id,
      tipo: tipo,
      animalId: (map['animalId'] ?? '').toString(),
      animalNome: (map['animalNome'] ?? '').toString(),
      data: data is Timestamp ? data.toDate() : DateTime.now(),
      titulo: (map['titulo'] ?? '').toString(),
      status: (map['status'] ?? '').toString(),
      observacoes: (map['observacoes'] ?? '').toString(),
      pai: (map['pai'] ?? '').toString(),
      mae: (map['mae'] ?? '').toString(),
      dataNascimento: nascimento is Timestamp ? nascimento.toDate() : null,
      alturaMetros: (map['alturaMetros'] as num?)?.toDouble(),
      pesoKg: (map['pesoKg'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toMap() => {
    'tipo': tipo.name,
    'animalId': animalId,
    'animalNome': animalNome,
    'data': Timestamp.fromDate(DateTime(data.year, data.month, data.day)),
    'titulo': titulo.trim(),
    'status': status.trim(),
    'observacoes': observacoes.trim(),
    'pai': pai.trim(),
    'mae': mae.trim(),
    'dataNascimento': dataNascimento == null
        ? null
        : Timestamp.fromDate(
            DateTime(
              dataNascimento!.year,
              dataNascimento!.month,
              dataNascimento!.day,
            ),
          ),
    'alturaMetros': alturaMetros,
    'pesoKg': pesoKg,
    'atualizadoEm': FieldValue.serverTimestamp(),
  };
}
