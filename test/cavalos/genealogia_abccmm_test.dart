import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gestor_haras/models/cavalo_model.dart';
import 'package:gestor_haras/services/abccmm_importacao.dart';
import 'package:gestor_haras/services/genealogia_abccmm_importacao.dart';
import 'package:gestor_haras/widgets/importar_abccmm_dialog.dart';
import 'fixtures/abccmm_genealogia.dart';
import 'fixtures/abccmm_playboy.dart';

void main() {
  test(
    'tabela renderizada: aceita tabulações com quebras dentro de cada célula',
    () {
      const copiado =
          'Genealogia\nTRILHO DA ZIZICA\nReg.: 010982 | DNA - VPM | MM5 | MM8\tCARUSO J.D.\nReg.: 01429 | sem DNA | MM5 |\tOURO PRETO DO PORTO\nReg.: 414 | sem DNA | MM3 |\n\t\t\nFAVACHO POLACA\nReg.: AD93 | DNA - VPP | MM4A |\tLOBINHO LOBOS\nReg.: 471 | DNA - AP | MM3 | MM8\t*****\n***** | ***** | ***** | *****';
      final g = GenealogiaAbccmmImportacao.ler(copiado)!;
      expect(g.ancestrais, hasLength(6));
      expect(g.posicoesPreservadas, true);
      expect(g.ancestrais.first.registro, '010982');
      expect(g.ancestrais[1].coluna, 1);
      expect(g.ancestrais[3].nome, 'FAVACHO POLACA');
      expect(g.ancestrais.last.desconhecido, true);
    },
  );
  test('cópia sem colunas importa lista, sem inventar pai e mãe', () {
    const copiado =
        'Genealogia\nTRILHO DA ZIZICA\nReg.: 010982 | DNA - VPM | MM5 | MM8\nCARUSO J.D.\nReg.: 01429 | sem DNA | MM5 |\n*****\n***** | ***** | ***** | MM7';
    final r = AbccmmImportacao.analisar(copiado);
    expect(r.genealogia!.ancestrais, hasLength(3));
    expect(r.genealogia!.posicoesPreservadas, false);
    expect(r.genealogia!.ancestrais.every((e) => e.coluna == -1), true);
    expect(r.sugestoesDeParentesco, isEmpty);
    expect(r.campos, isEmpty);
    expect(r.genealogia!.ancestrais.last.livros, ['MM7']);
  });
  test('células com aspas, CRLF e pipes internos preservam posições', () {
    const copiado =
        '"TRILHO DA ZIZICA\r\nReg.: 010982 | DNA - VPM | MM5 | MM8"\t"CARUSO J.D.\r\nReg.: 01429 | sem DNA | MM5 |"\t"OURO PRETO DO PORTO\r\nReg.: 414 | sem DNA | MM3 |"';
    final g = GenealogiaAbccmmImportacao.ler(copiado)!;
    expect(g.ancestrais, hasLength(3));
    expect(g.posicoesPreservadas, true);
    expect(g.ancestrais.last.coluna, 2);
  });
  test('tabela real preserva 14 entradas, 9 nomes e 5 desconhecidos', () {
    final g = GenealogiaAbccmmImportacao.ler(genealogiaCopiada)!;
    expect(g.ancestrais, hasLength(14));
    expect(g.ancestrais.where((e) => e.desconhecido), hasLength(5));
    expect(g.ancestrais.first.nome, 'TRILHO DA ZIZICA');
    expect(g.ancestrais.first.registro, '010982');
    expect(g.ancestrais.first.livros, ['MM5', 'MM8']);
    expect(g.ancestrais.first.exame, 'DNA - VPM');
    final rosada = g.ancestrais.singleWhere((e) => e.nome == 'ROSADA J.D.');
    expect(rosada.coluna, 1);
    expect(rosada.linha, 2);
    expect(rosada.exame, 'sem DNA');
    expect(
      g.ancestrais.singleWhere((e) => e.nome == 'FAVACHO POLACA').registro,
      'AD93',
    );
    expect(
      g.ancestrais.where((e) => e.desconhecido && e.livros.contains('MM7')),
      hasLength(1),
    );
    expect(g.avisos, isNotEmpty);
  });
  test('pai e mãe são sugestões, sem deduzir avós da tabela ambígua', () {
    final r = AbccmmImportacao.analisar(genealogiaCopiada);
    expect(r.campos['pai'], 'TRILHO DA ZIZICA');
    expect(r.campos['mae'], 'FAVACHO POLACA');
    expect(
      r.sugestoesDeParentesco,
      containsAll(['pai', 'mae', 'paiRegistro', 'maeLivro']),
    );
    expect(r.campos.containsKey('nome'), isFalse);
    expect(r.campos.containsKey('registro'), isFalse);
  });
  test('ficha e genealogia juntas não confundem animal e ancestrais', () {
    final r = AbccmmImportacao.analisar('$fichaPlayboy\n$genealogiaCopiada');
    expect(r.campos['nome'], 'PLAYBOY SG');
    expect(r.campos['registro'], '038184');
    expect(r.genealogia!.ancestrais, hasLength(14));
    expect(GenealogiaAbccmmImportacao.ler(fichaPlayboy), isNull);
  });
  test('genealogia sobrevive à serialização sem alterar cadastros antigos', () {
    final g = GenealogiaAbccmmImportacao.ler(genealogiaCopiada)!;
    final original = CavaloModel(id: '1', genealogiaAbccmm: g);
    expect(
      CavaloModel.fromMap(original.toMap(), '1').genealogiaAbccmm!.toMap(),
      g.toMap(),
    );
    expect(CavaloModel.fromMap({}, 'antigo').genealogiaAbccmm, isNull);
  });
  testWidgets('revisão exige seleção para genealogia e parentesco no celular', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    ResultadoImportacaoAbccmm? retorno;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () async =>
                  retorno = await showDialog<ResultadoImportacaoAbccmm>(
                    context: context,
                    builder: (_) => const ImportarAbccmmDialog(
                      atuais: {},
                      temGenealogia: true,
                    ),
                  ),
              child: const Text('Abrir'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Abrir'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), genealogiaCopiada);
    await tester.ensureVisible(find.text('Reconhecer campos'));
    await tester.tap(find.text('Reconhecer campos'));
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<FilledButton>(
            find.widgetWithText(FilledButton, 'Preencher cadastro'),
          )
          .onPressed,
      isNull,
    );
    expect(
      tester
          .widgetList<CheckboxListTile>(find.byType(CheckboxListTile))
          .every((e) => e.value == false),
      isTrue,
    );
    final confirmar = find.text('Importar genealogia revisada');
    await tester.ensureVisible(confirmar);
    await tester.tap(confirmar);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Preencher cadastro'));
    await tester.pumpAndSettle();
    expect(retorno!.campos, isEmpty);
    expect(retorno!.genealogia!.ancestrais, hasLength(14));
    expect(tester.takeException(), isNull);
  });
}
