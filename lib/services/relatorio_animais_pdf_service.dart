import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../models/financeiro_animais.dart';
import '../models/relatorio_animais.dart';
import 'pdf_file_writer.dart';

typedef SalvarArquivoPdf =
    Future<String?> Function(Uint8List bytes, String nomeArquivo);

class RelatorioAnimaisPdfService {
  const RelatorioAnimaisPdfService({this.salvarArquivo});

  final SalvarArquivoPdf? salvarArquivo;

  Future<Uint8List> gerar({
    required FinanceiroAnimaisDados dados,
    required FiltrosRelatorioAnimais filtros,
    DateTime? geradoEm,
  }) async {
    final movimentos = filtros.aplicar(dados.movimentos);
    final resumo = ResumoFinanceiroAnimais.calcular(movimentos);
    final porAnimal = resumirPorAnimal(movimentos);
    final documento = pw.Document(
      title: 'Relatório financeiro dos animais',
      author: 'Gestor Haras',
      creator: 'Gestor Haras',
    );
    final fonte = pw.Font.ttf(
      await rootBundle.load('assets/fonts/Roboto-Regular.ttf'),
    );
    final fonteDestaque = pw.Font.ttf(
      await rootBundle.load('assets/fonts/Roboto-Medium.ttf'),
    );
    final data = DateFormat('dd/MM/yyyy');
    final dataHora = DateFormat('dd/MM/yyyy HH:mm');
    final moeda = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    final agora = geradoEm ?? DateTime.now();
    final nomesSelecionados =
        filtros.animalIds
            .map((id) => dados.animais[id] ?? 'Animal não encontrado')
            .toList()
          ..sort();

    String valor(int centavos) => moeda.format(centavos / 100);
    String periodo() {
      if (filtros.inicio == null && filtros.fim == null) {
        return 'Todo o período';
      }
      return '${filtros.inicio == null ? 'Início' : data.format(filtros.inicio!)} a ${filtros.fim == null ? 'Hoje' : data.format(filtros.fim!)}';
    }

    pw.Widget totalCard(String titulo, int centavos, PdfColor cor) =>
        pw.Expanded(
          child: pw.Container(
            padding: const pw.EdgeInsets.all(10),
            decoration: pw.BoxDecoration(
              color: PdfColors.white,
              border: pw.Border.all(color: PdfColors.grey300),
              borderRadius: pw.BorderRadius.circular(5),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(titulo, style: const pw.TextStyle(fontSize: 9)),
                pw.SizedBox(height: 4),
                pw.Text(
                  valor(centavos),
                  style: pw.TextStyle(
                    color: cor,
                    fontSize: 15,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        );

    pw.Widget tabela({
      required List<String> cabecalho,
      required List<List<String>> linhas,
      List<pw.Alignment>? alinhamentos,
      Map<int, pw.TableColumnWidth>? larguras,
    }) => pw.TableHelper.fromTextArray(
      headers: cabecalho,
      data: linhas,
      border: pw.TableBorder.all(color: PdfColors.grey300, width: .5),
      headerDecoration: const pw.BoxDecoration(
        color: PdfColor.fromInt(0xFF1E293B),
      ),
      headerStyle: pw.TextStyle(
        color: PdfColors.white,
        fontSize: 8,
        fontWeight: pw.FontWeight.bold,
      ),
      cellStyle: const pw.TextStyle(fontSize: 7.5),
      cellPadding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 4),
      cellAlignments: alinhamentos == null
          ? null
          : {for (var i = 0; i < alinhamentos.length; i++) i: alinhamentos[i]},
      columnWidths: larguras,
      oddRowDecoration: const pw.BoxDecoration(
        color: PdfColor.fromInt(0xFFF8FAFC),
      ),
    );

    documento.addPage(
      pw.MultiPage(
        pageTheme: pw.PageTheme(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.fromLTRB(32, 34, 32, 34),
          theme: pw.ThemeData.withFont(base: fonte, bold: fonteDestaque),
        ),
        header: (context) => pw.Container(
          padding: const pw.EdgeInsets.only(bottom: 9),
          margin: const pw.EdgeInsets.only(bottom: 12),
          decoration: const pw.BoxDecoration(
            border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey300)),
          ),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'GESTOR HARAS',
                style: pw.TextStyle(
                  color: const PdfColor.fromInt(0xFF4338CA),
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 10,
                ),
              ),
              pw.Text(
                'Relatório dos animais',
                style: const pw.TextStyle(fontSize: 9),
              ),
            ],
          ),
        ),
        footer: (context) => pw.Align(
          alignment: pw.Alignment.centerRight,
          child: pw.Text(
            'Página ${context.pageNumber} de ${context.pagesCount}',
            style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
          ),
        ),
        build: (context) => [
          pw.Text(
            'Relatório financeiro dos animais',
            style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            'Gerado em ${dataHora.format(agora)}',
            style: const pw.TextStyle(color: PdfColors.grey600, fontSize: 9),
          ),
          pw.SizedBox(height: 16),
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.all(10),
            decoration: const pw.BoxDecoration(
              color: PdfColor.fromInt(0xFFEEF2FF),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Filtros aplicados',
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  'Período: ${periodo()}',
                  style: const pw.TextStyle(fontSize: 9),
                ),
                pw.Text(
                  'Animais: ${nomesSelecionados.isEmpty ? 'Todos os animais' : nomesSelecionados.join(', ')}',
                  style: const pw.TextStyle(fontSize: 9),
                ),
                pw.Text(
                  'Movimentos: ${filtros.tipo == null
                      ? 'Receitas e despesas'
                      : filtros.tipo == TipoMovimentoAnimal.receita
                      ? 'Somente receitas'
                      : 'Somente despesas'}',
                  style: const pw.TextStyle(fontSize: 9),
                ),
                pw.Text(
                  'Categoria: ${filtros.categoria ?? 'Todas'}',
                  style: const pw.TextStyle(fontSize: 9),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 14),
          pw.Row(
            children: [
              totalCard('Receitas', resumo.receitas, PdfColors.green700),
              pw.SizedBox(width: 8),
              totalCard('Despesas', resumo.despesas, PdfColors.red700),
              pw.SizedBox(width: 8),
              totalCard(
                'Saldo',
                resumo.saldo,
                resumo.saldo < 0 ? PdfColors.red700 : PdfColors.blueGrey900,
              ),
            ],
          ),
          pw.SizedBox(height: 18),
          pw.Text(
            'Resumo por animal',
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 8),
          if (porAnimal.isEmpty)
            pw.Text(
              'Nenhum lançamento encontrado para os filtros selecionados.',
            )
          else
            tabela(
              cabecalho: const [
                'Animal',
                'Lançamentos',
                'Receitas',
                'Despesas',
                'Saldo',
              ],
              linhas: porAnimal
                  .map(
                    (item) => [
                      item.animalNome,
                      '${item.lancamentos}',
                      valor(item.receitas),
                      valor(item.despesas),
                      valor(item.saldo),
                    ],
                  )
                  .toList(),
              alinhamentos: const [
                pw.Alignment.centerLeft,
                pw.Alignment.centerRight,
                pw.Alignment.centerRight,
                pw.Alignment.centerRight,
                pw.Alignment.centerRight,
              ],
              larguras: const {
                0: pw.FlexColumnWidth(2.2),
                1: pw.FlexColumnWidth(.8),
                2: pw.FlexColumnWidth(1.2),
                3: pw.FlexColumnWidth(1.2),
                4: pw.FlexColumnWidth(1.2),
              },
            ),
          pw.SizedBox(height: 18),
          pw.Text(
            'Lançamentos detalhados',
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 8),
          if (movimentos.isNotEmpty)
            tabela(
              cabecalho: const [
                'Data',
                'Animal',
                'Tipo',
                'Categoria',
                'Descrição',
                'Valor',
              ],
              linhas: movimentos
                  .map(
                    (movimento) => [
                      movimento.data == null
                          ? 'Sem data'
                          : data.format(movimento.data!),
                      movimento.animalNome,
                      movimento.tipo == TipoMovimentoAnimal.receita
                          ? 'Receita'
                          : 'Despesa',
                      movimento.categoria,
                      movimento.descricao.isEmpty ? '-' : movimento.descricao,
                      valor(movimento.centavos),
                    ],
                  )
                  .toList(),
              alinhamentos: const [
                pw.Alignment.centerLeft,
                pw.Alignment.centerLeft,
                pw.Alignment.centerLeft,
                pw.Alignment.centerLeft,
                pw.Alignment.centerLeft,
                pw.Alignment.centerRight,
              ],
              larguras: const {
                0: pw.FlexColumnWidth(.8),
                1: pw.FlexColumnWidth(1.5),
                2: pw.FlexColumnWidth(.8),
                3: pw.FlexColumnWidth(1),
                4: pw.FlexColumnWidth(2.2),
                5: pw.FlexColumnWidth(1),
              },
            ),
          if (dados.registrosInvalidos > 0) ...[
            pw.SizedBox(height: 12),
            pw.Text(
              '${dados.registrosInvalidos} lançamento(s) inválido(s) não foram incluídos.',
              style: const pw.TextStyle(
                fontSize: 8,
                color: PdfColors.orange800,
              ),
            ),
          ],
        ],
      ),
    );
    return documento.save();
  }

  Future<bool> exportar({
    required FinanceiroAnimaisDados dados,
    required FiltrosRelatorioAnimais filtros,
  }) async {
    final bytes = await gerar(dados: dados, filtros: filtros);
    return salvar(bytes);
  }

  String nomeArquivo([DateTime? agora]) {
    final data = DateFormat('yyyyMMdd').format(agora ?? DateTime.now());
    return 'relatorio_animais_$data.pdf';
  }

  Future<bool> salvar(Uint8List bytes, {String? nomeArquivo}) async {
    final nome = nomeArquivo ?? this.nomeArquivo();
    if (salvarArquivo != null) {
      return await salvarArquivo!(bytes, nome) != null;
    }

    // Usa um download direto no navegador. A alternativa do seletor abre uma
    // nova aba em alguns browsers e pode ser bloqueada como pop-up.
    if (kIsWeb) {
      return Printing.sharePdf(bytes: bytes, filename: nome);
    }

    final desktop = const {
      TargetPlatform.windows,
      TargetPlatform.linux,
      TargetPlatform.macOS,
    }.contains(defaultTargetPlatform);
    final caminho = await FilePicker.platform.saveFile(
      dialogTitle: 'Salvar relatório dos animais',
      fileName: nome,
      type: FileType.custom,
      allowedExtensions: const ['pdf'],
      bytes: desktop ? null : bytes,
      lockParentWindow: desktop,
    );
    if (caminho == null) return false;
    if (!desktop) return true;

    final caminhoPdf = caminho.toLowerCase().endsWith('.pdf')
        ? caminho
        : '$caminho.pdf';
    return escreverArquivoPdf(caminhoPdf, bytes);
  }
}
