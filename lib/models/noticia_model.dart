import 'package:cloud_firestore/cloud_firestore.dart';

class NoticiaModel {
  final String id;

  final String titulo;
  final String imagemUrl;
  final String link;
  final String descricao;

  final bool ativo;

  final Timestamp? dataPublicacao;

  const NoticiaModel({
    required this.id,
    this.titulo = '',
    this.imagemUrl = '',
    this.link = '',
    this.descricao = '',
    this.ativo = true,
    this.dataPublicacao,
  });

  factory NoticiaModel.fromMap(
    Map<String, dynamic> map,
    String id,
  ) {
    return NoticiaModel(
      id: id,
      titulo: map['titulo'] ?? '',
      imagemUrl: map['imagemUrl'] ?? '',
      link: map['link'] ?? '',
      descricao: map['descricao'] ?? '',
      ativo: map['ativo'] ?? true,
      dataPublicacao: map['dataPublicacao'] as Timestamp?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'titulo': titulo,
      'imagemUrl': imagemUrl,
      'link': link,
      'descricao': descricao,
      'ativo': ativo,
      'dataPublicacao': dataPublicacao ?? Timestamp.now(),
    };
  }
}