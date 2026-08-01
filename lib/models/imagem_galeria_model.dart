import 'package:cloud_firestore/cloud_firestore.dart';

class ImagemGaleriaModel {
  final String id;

  final String url;
  final String descricao;

  final bool ativo;

  final Timestamp? dataUpload;

  const ImagemGaleriaModel({
    required this.id,
    this.url = '',
    this.descricao = '',
    this.ativo = true,
    this.dataUpload,
  });

  factory ImagemGaleriaModel.fromMap(
    Map<String, dynamic> map,
    String id,
  ) {
    return ImagemGaleriaModel(
      id: id,
      url: map['url'] ?? '',
      descricao: map['descricao'] ?? '',
      ativo: map['ativo'] ?? true,
      dataUpload: map['dataUpload'] as Timestamp?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'url': url,
      'descricao': descricao,
      'ativo': ativo,
      'dataUpload': dataUpload ?? Timestamp.now(),
    };
  }
}