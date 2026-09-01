import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

import '../../services/relatorio_animais_pdf_service.dart';
import '../../widgets/desktop_window.dart';

class RelatorioPdfPreviewPage extends StatefulWidget {
  const RelatorioPdfPreviewPage({
    super.key,
    required this.bytes,
    this.salvar,
    this.salvarAlternativo,
  });

  final Uint8List bytes;
  final Future<bool> Function(Uint8List bytes)? salvar;
  final Future<bool> Function(Uint8List bytes)? salvarAlternativo;

  @override
  State<RelatorioPdfPreviewPage> createState() =>
      _RelatorioPdfPreviewPageState();
}

class _RelatorioPdfPreviewPageState extends State<RelatorioPdfPreviewPage> {
  bool salvando = false;
  late final Uint8List _bytesOriginais;

  @override
  void initState() {
    super.initState();
    // O renderizador Web transfere o ArrayBuffer para um worker e pode
    // destacá-lo. Esta cópia nunca é entregue diretamente ao worker.
    _bytesOriginais = Uint8List.fromList(widget.bytes);
  }

  Uint8List _novaCopia() => Uint8List.fromList(_bytesOriginais);

  Future<void> _salvar() async {
    if (salvando) return;
    setState(() => salvando = true);
    try {
      final salvo = widget.salvar != null
          ? await widget.salvar!(_novaCopia())
          : await const RelatorioAnimaisPdfService().salvar(_novaCopia());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              salvo
                  ? 'PDF salvo com sucesso.'
                  : 'Salvamento cancelado. Nenhum arquivo foi criado.',
            ),
          ),
        );
      }
    } catch (erro) {
      await _salvarPeloSistema(erro);
    } finally {
      if (mounted) setState(() => salvando = false);
    }
  }

  Future<void> _salvarPeloSistema(Object erroOriginal) async {
    try {
      final abriu = widget.salvarAlternativo != null
          ? await widget.salvarAlternativo!(_novaCopia())
          : await Printing.sharePdf(
              bytes: _novaCopia(),
              filename: const RelatorioAnimaisPdfService().nomeArquivo(),
            );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            abriu
                ? 'Escolha onde deseja salvar o PDF.'
                : 'O dispositivo não disponibilizou uma opção para salvar.',
          ),
        ),
      );
    } catch (erroAlternativo) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Não foi possível salvar o PDF: $erroOriginal. Alternativa: $erroAlternativo',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final dentroDaJanela = DesktopWindowScope.isInside(context);
    return Scaffold(
      backgroundColor: const Color(0xFFE5E7EB),
      appBar: dentroDaJanela
          ? null
          : AppBar(title: const Text('Pré-visualização do relatório')),
      body: Column(
        children: [
          ColoredBox(
            color: const Color(0xFFEEF2FF),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Confira o relatório antes de imprimir ou salvar.',
                    ),
                  ),
                  const SizedBox(width: 12),
                  FilledButton.icon(
                    key: const ValueKey('salvar-pdf-previsualizacao'),
                    onPressed: salvando ? null : _salvar,
                    icon: salvando
                        ? const SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.download_rounded),
                    label: const Text('Salvar PDF'),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: PdfPreview(
              key: const ValueKey('previsualizacao-pdf'),
              build: (_) async => _novaCopia(),
              initialPageFormat: PdfPageFormat.a4,
              pageFormats: const {'A4': PdfPageFormat.a4},
              pdfFileName: const RelatorioAnimaisPdfService().nomeArquivo(),
              allowPrinting: true,
              allowSharing: false,
              canChangePageFormat: false,
              canChangeOrientation: false,
              canDebug: false,
              dynamicLayout: false,
              onPrintError: (context, erro) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Não foi possível imprimir: $erro')),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
