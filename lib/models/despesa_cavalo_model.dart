import 'package:cloud_firestore/cloud_firestore.dart';

enum CategoriaDespesa {
  remedio,
  vacina,
  alimento,
  ferrageamento,
  veterinario,
  outro,
}

extension CategoriaDespesaExt on CategoriaDespesa {
  String get label {
    switch (this) {
      case CategoriaDespesa.remedio:
        return 'Remédio';
      case CategoriaDespesa.vacina:
        return 'Vacina';
      case CategoriaDespesa.alimento:
        return 'Alimento';
      case CategoriaDespesa.ferrageamento:
        return 'Ferrageamento';
      case CategoriaDespesa.veterinario:
        return 'Veterinário';
      case CategoriaDespesa.outro:
        return 'Outro';
    }
  }
}

CategoriaDespesa categoriaDespesaFromString(String valor) {
  return CategoriaDespesa.values.firstWhere(
    (c) => c.name == valor,
    orElse: () => CategoriaDespesa.outro,
  );
}

class DespesaCavaloModel {
  final String id;

  final CategoriaDespesa categoria;
  final String descricao;
  final double valor;

  final Timestamp data;

  const DespesaCavaloModel({
    required this.id,
    required this.categoria,
    this.descricao = '',
    this.valor = 0,
    required this.data,
  });

  factory DespesaCavaloModel.fromMap(
    Map<String, dynamic> map,
    String id,
  ) {
    return DespesaCavaloModel(
      id: id,
      categoria: categoriaDespesaFromString(map['categoria'] ?? 'outro'),
      descricao: map['descricao'] ?? '',
      valor: (map['valor'] ?? 0).toDouble(),
      data: map['data'] is Timestamp ? map['data'] : Timestamp.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'categoria': categoria.name,
      'descricao': descricao,
      'valor': valor,
      'data': data,
    };
  }
}