import 'package:flutter/material.dart';
import '../models/genealogia_abccmm.dart';

class GenealogiaAbccmmView extends StatelessWidget {
  final GenealogiaAbccmm genealogia;
  const GenealogiaAbccmmView({super.key, required this.genealogia});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Text(
        genealogia.posicoesPreservadas
            ? 'Posições preservadas da tabela original. Células vazias não são ancestrais; asteriscos indicam dados desconhecidos.'
            : 'Lista de ancestrais sem posição recuperável. Asteriscos indicam dados desconhecidos.',
      ),
      for (final aviso in genealogia.avisos)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Text(aviso, style: const TextStyle(color: Color(0xFF92400E))),
        ),
      for (final item in genealogia.ancestrais)
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  item.coluna < 0
                      ? 'Entrada ${item.linha + 1} · Parentesco não identificado'
                      : 'Linha ${item.linha + 1} · Coluna ${item.coluna + 1}',
                  style: Theme.of(context).textTheme.labelSmall,
                ),
                Text(
                  item.desconhecido ? 'Ancestral desconhecido' : item.nome,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                if (item.registro.isNotEmpty)
                  Text('Registro: ${item.registro}'),
                if (item.exame.isNotEmpty) Text('Exame: ${item.exame}'),
                if (item.livros.isNotEmpty)
                  Text('Livros: ${item.livros.join(" | ")}'),
              ],
            ),
          ),
        ),
    ],
  );
}
