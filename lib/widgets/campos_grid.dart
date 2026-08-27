import 'package:flutter/material.dart';

/// Organiza campos de formulário em colunas que se ajustam à largura
/// disponível — no desktop mostra 2 ou 3 por linha (reduzindo a altura
/// total do formulário), no mobile cai para 1 coluna automaticamente.
class CamposGrid extends StatelessWidget {
  final List<Widget> campos;
  final double larguraMinimaColuna;
  final int maximoColunas;

  const CamposGrid({
    super.key,
    required this.campos,
    this.larguraMinimaColuna = 260,
    this.maximoColunas = 3,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final colunas = (constraints.maxWidth / larguraMinimaColuna)
            .floor()
            .clamp(1, maximoColunas);

        if (colunas <= 1) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: campos,
          );
        }

        final largura = (constraints.maxWidth - (colunas - 1) * 16) / colunas;

        return Wrap(
          spacing: 16,
          runSpacing: 0,
          children: campos
              .map((c) => SizedBox(width: largura, child: c))
              .toList(),
        );
      },
    );
  }
}
