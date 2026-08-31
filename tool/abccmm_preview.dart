// Prévia local isolada: não acessa Firebase nem salva cavalos.
import 'package:flutter/material.dart';
import 'package:gestor_haras/services/abccmm_importacao.dart';
import 'package:gestor_haras/widgets/importar_abccmm_dialog.dart';

void main() => runApp(const MaterialApp(home: _Preview()));

class _Preview extends StatefulWidget {
  const _Preview();
  @override
  State<_Preview> createState() => _PreviewState();
}

class _PreviewState extends State<_Preview> {
  ResultadoImportacaoAbccmm? resultado;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Teste local de importação — sem salvar dados'),
    ),
    body: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FilledButton(
            onPressed: () async {
              final r = await showDialog<ResultadoImportacaoAbccmm>(
                context: context,
                builder: (_) => const ImportarAbccmmDialog(atuais: {}),
              );
              if (mounted) setState(() => resultado = r);
            },
            child: const Text('Testar importação'),
          ),
          if (resultado != null)
            Text(
              '${resultado!.genealogia?.ancestrais.length ?? 0} ancestrais recebidos pela tela de cadastro',
            ),
        ],
      ),
    ),
  );
}
