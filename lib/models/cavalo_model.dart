import 'package:cloud_firestore/cloud_firestore.dart';

class CavaloModel {
  final String? id;

  final String nome;
  final String raca;
  final String sexo;
  final String pelagem;
  final String registro;

  final int idade;

  final String descricao;

  final double preco;

  final String status;

  final bool destaque;
  final bool vendido;

  final String fotoPrincipal;

  final List<String> fotos;

  final String? videoUrl;

  final String? criadoPor;

  final Timestamp? criadoEm;
  final Timestamp? atualizadoEm;

  const CavaloModel({
    this.id,
    required this.nome,
    required this.raca,
    required this.sexo,
    required this.pelagem,
    required this.registro,
    required this.idade,
    required this.descricao,
    required this.preco,
    required this.status,
    required this.destaque,
    required this.vendido,
    required this.fotoPrincipal,
    required this.fotos,
    this.videoUrl,
    this.criadoPor,
    this.criadoEm,
    this.atualizadoEm,
  });

  factory CavaloModel.fromMap(
    Map<String, dynamic> map,
    String id,
  ) {
    final fotos = _converterFotos(
      map["fotos"],
    );

    return CavaloModel(
      id: id,
      nome: map["nome"]?.toString() ?? "",
      raca: map["raca"]?.toString() ?? "",
      sexo: map["sexo"]?.toString() ?? "",
      pelagem: map["pelagem"]?.toString() ?? "",
      registro: map["registro"]?.toString() ?? "",
      idade: _converterInt(
        map["idade"],
      ),
      descricao: map["descricao"]?.toString() ?? "",
      preco: _converterDouble(
        map["preco"],
      ),
      status: map["status"]?.toString() ?? "disponivel",
      destaque: map["destaque"] ?? false,
      vendido: map["vendido"] ?? false,
      fotoPrincipal: map["fotoPrincipal"]?.toString() ??
          (fotos.isNotEmpty ? fotos.first : ""),
      fotos: fotos,
      videoUrl: map["videoUrl"]?.toString(),
      criadoPor: map["criadoPor"]?.toString(),
      criadoEm: map["criadoEm"] as Timestamp?,
      atualizadoEm: map["atualizadoEm"] as Timestamp?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "nome": nome,
      "raca": raca,
      "sexo": sexo,
      "pelagem": pelagem,
      "registro": registro,
      "idade": idade,
      "descricao": descricao,
      "preco": preco,
      "status": status,
      "destaque": destaque,
      "vendido": vendido,
      "fotoPrincipal": fotoPrincipal,
      "fotos": fotos,
      "videoUrl": videoUrl,
      "criadoPor": criadoPor,
      "criadoEm":
          criadoEm ?? FieldValue.serverTimestamp(),
      "atualizadoEm":
          FieldValue.serverTimestamp(),
    };
  }

  CavaloModel copyWith({
    String? id,
    String? nome,
    String? raca,
    String? sexo,
    String? pelagem,
    String? registro,
    int? idade,
    String? descricao,
    double? preco,
    String? status,
    bool? destaque,
    bool? vendido,
    String? fotoPrincipal,
    List<String>? fotos,
    String? videoUrl,
    String? criadoPor,
    Timestamp? criadoEm,
    Timestamp? atualizadoEm,
  }) {
    return CavaloModel(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      raca: raca ?? this.raca,
      sexo: sexo ?? this.sexo,
      pelagem: pelagem ?? this.pelagem,
      registro: registro ?? this.registro,
      idade: idade ?? this.idade,
      descricao: descricao ?? this.descricao,
      preco: preco ?? this.preco,
      status: status ?? this.status,
      destaque: destaque ?? this.destaque,
      vendido: vendido ?? this.vendido,
      fotoPrincipal:
          fotoPrincipal ?? this.fotoPrincipal,
      fotos: fotos ?? this.fotos,
      videoUrl: videoUrl ?? this.videoUrl,
      criadoPor: criadoPor ?? this.criadoPor,
      criadoEm: criadoEm ?? this.criadoEm,
      atualizadoEm:
          atualizadoEm ?? this.atualizadoEm,
    );
  }

  static List<String> _converterFotos(
    dynamic valor,
  ) {
    if (valor == null) {
      return [];
    }

    if (valor is List) {
      return valor
          .where((e) => e != null)
          .map((e) => e.toString().trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }

    return [];
  }

  static int _converterInt(
    dynamic valor,
  ) {
    if (valor == null) {
      return 0;
    }

    if (valor is int) {
      return valor;
    }

    if (valor is double) {
      return valor.toInt();
    }

    return int.tryParse(
          valor.toString(),
        ) ??
        0;
  }

  static double _converterDouble(
    dynamic valor,
  ) {
    if (valor == null) {
      return 0;
    }

    if (valor is double) {
      return valor;
    }

    if (valor is int) {
      return valor.toDouble();
    }

    return double.tryParse(
          valor.toString(),
        ) ??
        0;
  }
}