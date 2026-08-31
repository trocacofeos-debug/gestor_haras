class AncestralAbccmm {
  final int linha;
  final int coluna;
  final String nome;
  final String registro;
  final String exame;
  final List<String> livros;

  const AncestralAbccmm({
    required this.linha,
    required this.coluna,
    this.nome = '',
    this.registro = '',
    this.exame = '',
    this.livros = const [],
  });

  bool get desconhecido => nome.isEmpty;

  factory AncestralAbccmm.fromMap(Map<String, dynamic> map) => AncestralAbccmm(
    linha: (map['linha'] as num).toInt(),
    coluna: (map['coluna'] as num).toInt(),
    nome: map['nome'] as String? ?? '',
    registro: map['registro'] as String? ?? '',
    exame: map['exame'] as String? ?? '',
    livros: List<String>.from(map['livros'] ?? []),
  );
  Map<String, dynamic> toMap() => {
    'linha': linha,
    'coluna': coluna,
    'nome': nome,
    'registro': registro,
    'exame': exame,
    'livros': livros,
  };
}

/// Posições da tabela de origem. Não deduz parentescos a partir de células vazias.
class GenealogiaAbccmm {
  final List<AncestralAbccmm> ancestrais;
  final List<String> avisos;
  final bool posicoesPreservadas;
  const GenealogiaAbccmm({
    required this.ancestrais,
    this.avisos = const [],
    this.posicoesPreservadas = true,
  });

  factory GenealogiaAbccmm.fromMap(Map<String, dynamic> map) =>
      GenealogiaAbccmm(
        ancestrais: (map['ancestrais'] as List? ?? [])
            .map(
              (e) =>
                  AncestralAbccmm.fromMap(Map<String, dynamic>.from(e as Map)),
            )
            .toList(),
        avisos: List<String>.from(map['avisos'] ?? []),
        posicoesPreservadas: map['posicoesPreservadas'] as bool? ?? true,
      );
  Map<String, dynamic> toMap() => {
    'ancestrais': ancestrais.map((e) => e.toMap()).toList(),
    'avisos': avisos,
    'posicoesPreservadas': posicoesPreservadas,
  };
}
