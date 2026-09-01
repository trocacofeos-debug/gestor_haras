import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gestor_haras/models/financeiro_animais.dart';
import 'package:gestor_haras/models/relatorio_animais.dart';
import 'package:gestor_haras/services/relatorio_animais_pdf_service.dart';
import 'package:gestor_haras/views/financeiro/relatorios_animais_page.dart';

MovimentoAnimal movimento({
  required String id,
  required String animalId,
  required TipoMovimentoAnimal tipo,
  required double valor,
  required DateTime data,
  String categoria = 'alimento',
}) => MovimentoAnimal.fromMap(
  {
    'valor': valor,
    'data': Timestamp.fromDate(data),
    'descricao': id,
    'categoria': categoria,
  },
  id: id,
  animalId: animalId,
  animalNome: animalId == 'a' ? 'PLAYBOY SG' : 'ÉGUA LUA',
  tipo: tipo,
)!;

FinanceiroAnimaisDados exemplo() => FinanceiroAnimaisDados(
  animais: const {'a': 'PLAYBOY SG', 'b': 'ÉGUA LUA'},
  movimentos: [
    movimento(
      id: 'Hospedagem',
      animalId: 'a',
      tipo: TipoMovimentoAnimal.receita,
      valor: 1000,
      data: DateTime(2026, 8, 5),
    ),
    movimento(
      id: 'Ração',
      animalId: 'a',
      tipo: TipoMovimentoAnimal.despesa,
      valor: 300,
      data: DateTime(2026, 8, 31, 23, 59),
    ),
    movimento(
      id: 'Vacina',
      animalId: 'b',
      tipo: TipoMovimentoAnimal.despesa,
      valor: 100,
      data: DateTime(2026, 8, 15),
      categoria: 'vacina',
    ),
    movimento(
      id: 'Fora do período',
      animalId: 'b',
      tipo: TipoMovimentoAnimal.receita,
      valor: 200,
      data: DateTime(2026, 9, 1),
    ),
  ],
);

void main() {
  test('filtra período completo, vários animais, tipo e categoria', () {
    final dados = exemplo();
    final agosto = const FiltrosRelatorioAnimais(
      animalIds: {'a', 'b'},
      tipo: TipoMovimentoAnimal.despesa,
      inicio: null,
      fim: null,
    ).aplicar(dados.movimentos);
    expect(agosto.map((item) => item.id), ['Ração', 'Vacina']);

    final vacina = FiltrosRelatorioAnimais(
      animalIds: const {'b'},
      categoria: 'Vacina',
      inicio: DateTime(2026, 8, 1),
      fim: DateTime(2026, 8, 31),
    ).aplicar(dados.movimentos);
    expect(vacina.single.id, 'Vacina');
  });

  test('resume receitas, despesas e saldo por animal', () {
    final resumos = resumirPorAnimal(exemplo().movimentos);
    final playboy = resumos.singleWhere((item) => item.animalId == 'a');
    expect(playboy.receitas, 100000);
    expect(playboy.despesas, 30000);
    expect(playboy.saldo, 70000);
    expect(playboy.lancamentos, 2);
  });

  test('gera documento PDF válido com várias seções', () async {
    final bytes = await const RelatorioAnimaisPdfService().gerar(
      dados: exemplo(),
      filtros: FiltrosRelatorioAnimais(
        inicio: DateTime(2026, 8, 1),
        fim: DateTime(2026, 8, 31),
      ),
      geradoEm: DateTime(2026, 8, 31, 12),
    );
    expect(ascii.decode(bytes.take(5).toList()), '%PDF-');
    expect(bytes.length, greaterThan(3000));
    final arquivo = File('build/qa/relatorio_animais_amostra.pdf');
    await arquivo.parent.create(recursive: true);
    await arquivo.writeAsBytes(bytes, flush: true);
  });

  test('exportação entrega bytes e nome PDF ao salvador', () async {
    List<int>? recebidos;
    String? nome;
    final service = RelatorioAnimaisPdfService(
      salvarArquivo: (bytes, arquivo) async {
        recebidos = bytes;
        nome = arquivo;
        return 'C:/Relatorios/$arquivo';
      },
    );
    final salvo = await service.exportar(
      dados: exemplo(),
      filtros: const FiltrosRelatorioAnimais(),
    );

    expect(salvo, isTrue);
    expect(nome, matches(r'^relatorio_animais_\d{8}\.pdf$'));
    expect(ascii.decode(recebidos!.take(5).toList()), '%PDF-');
  });

  for (final tamanho in [const Size(390, 844), const Size(1100, 760)]) {
    testWidgets(
      'relatório abre visualização em $tamanho sem alterar Financeiro',
      (tester) async {
        tester.view.physicalSize = tamanho;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        FiltrosRelatorioAnimais? exportado;
        await tester.pumpWidget(
          MaterialApp(
            home: RelatoriosAnimaisPage(
              carregar: () async => exemplo(),
              visualizar: (_, filtros) async => exportado = filtros,
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.text('Relatórios dos animais'), findsOneWidget);
        expect(find.textContaining('800,00'), findsOneWidget);
        final botao = find.byKey(const ValueKey('visualizar-relatorio-pdf'));
        await tester.scrollUntilVisible(
          botao,
          220,
          scrollable: find
              .descendant(
                of: find.byKey(
                  const PageStorageKey('relatorios-animais-scroll'),
                ),
                matching: find.byType(Scrollable),
              )
              .first,
        );
        await tester.tap(botao);
        await tester.pumpAndSettle();
        expect(exportado, isNotNull);
        expect(find.text('Visualizar relatório'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  }
}
