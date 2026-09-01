import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gestor_haras/models/divida_model.dart';
import 'package:gestor_haras/views/financeiro/nova_conta_page.dart';

Future<void> _mostrar(WidgetTester tester, Finder finder) async {
  await tester.scrollUntilVisible(
    finder,
    180,
    scrollable: find
        .descendant(
          of: find.byKey(const PageStorageKey('cadastrar-divida-scroll')),
          matching: find.byType(Scrollable),
        )
        .first,
  );
  await tester.pumpAndSettle();
}

void main() {
  for (final tamanho in [const Size(320, 700), const Size(1100, 760)]) {
    testWidgets('cadastro de dívida limpo e funcional em $tamanho', (
      tester,
    ) async {
      tester.view.physicalSize = tamanho;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      DividaModel? dividaSalva;
      List<Map<String, dynamic>>? parcelasSalvas;

      await tester.pumpWidget(
        MaterialApp(
          home: NovaContaPage(
            clienteIdInicial: 'cliente-1',
            clienteNomeInicial: 'Cliente Teste',
            criar: (divida, parcelas) async {
              dividaSalva = divida;
              parcelasSalvas = parcelas;
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      await _mostrar(tester, find.byKey(const ValueKey('divida-descricao')));
      await tester.enterText(
        find.byKey(const ValueKey('divida-descricao')),
        'Hospedagem de setembro',
      );
      await _mostrar(tester, find.byKey(const ValueKey('divida-valor')));
      await tester.enterText(
        find.byKey(const ValueKey('divida-valor')),
        '1.200,60',
      );
      tester.testTextInput.hide();
      await tester.pumpAndSettle();
      await _mostrar(tester, find.byKey(const ValueKey('divida-parcelas')));
      await tester.tap(find.byKey(const ValueKey('divida-parcelas')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('3').last);
      await tester.pumpAndSettle();
      await _mostrar(tester, find.byKey(const ValueKey('salvar-divida')));
      await tester.tap(find.byKey(const ValueKey('salvar-divida')));
      await tester.pumpAndSettle();

      expect(dividaSalva, isNotNull);
      expect(dividaSalva!.clienteId, 'cliente-1');
      expect(dividaSalva!.descricao, 'Hospedagem de setembro');
      expect(dividaSalva!.valorTotal, 1200.60);
      expect(dividaSalva!.parcelas, 3);
      expect(parcelasSalvas, hasLength(3));
      expect(parcelasSalvas!.first['valor'], closeTo(400.20, .001));
      expect(find.text('Dívida cadastrada com sucesso.'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
