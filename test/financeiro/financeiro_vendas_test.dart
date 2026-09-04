import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gestor_haras/models/financeiro_animais.dart';
import 'package:gestor_haras/models/financeiro_vendas.dart';
import 'package:gestor_haras/views/financeiro/financeiro_geral_page.dart';
import 'package:gestor_haras/views/financeiro/financeiro_vendas_page.dart';

FinanceiroVendasDados _exemplo() => FinanceiroVendasDados(
  vendas: [
    VendaFinanceira(
      id: 'v1',
      clienteNome: 'Cliente A',
      descricao: 'Venda do animal Lua',
      totalCentavos: 100000,
      pagoCentavos: 40000,
      data: DateTime(2026, 9, 1),
    ),
    VendaFinanceira(
      id: 'v2',
      clienteNome: 'Cliente B',
      descricao: 'Venda do animal Sol',
      totalCentavos: 50000,
      pagoCentavos: 50000,
      data: DateTime(2026, 9, 2),
    ),
  ],
);

void main() {
  test('resume quantidade, total vendido, pago e pendente', () {
    final dados = _exemplo();
    expect(dados.quantidadeVendas, 2);
    expect(dados.vendasQuitadas, 1);
    expect(dados.totalCentavos, 150000);
    expect(dados.pagoCentavos, 90000);
    expect(dados.pendenteCentavos, 60000);
  });

  testWidgets('financeiro de vendas mostra totais e pagamentos no celular', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(home: FinanceiroVendasPage(carregar: () async => _exemplo())),
    );
    await tester.pumpAndSettle();

    expect(find.text('Vendas'), findsOneWidget);
    expect(find.text('Total vendido'), findsOneWidget);
    expect(find.text('Já pago'), findsOneWidget);
    expect(find.text('Pendente'), findsOneWidget);
    expect(find.textContaining('1.500,00'), findsOneWidget);
    expect(find.textContaining('900,00'), findsOneWidget);
    expect(find.textContaining('600,00'), findsOneWidget);
    expect(
      find.textContaining('1 venda(s) totalmente paga(s)'),
      findsOneWidget,
    );
    expect(find.text('Cliente A'), findsOneWidget);
    expect(find.textContaining('Pago: R\$'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Financeiro separa animais e vendas em duas abas', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: FinanceiroGeralPage(
          carregarAnimais: () async => const FinanceiroAnimaisDados(
            animais: {'a1': 'Lua'},
            movimentos: [
              MovimentoAnimal(
                id: 'm1',
                animalId: 'a1',
                animalNome: 'Lua',
                tipo: TipoMovimentoAnimal.receita,
                descricao: 'Hospedagem',
                categoria: 'Hospedagem',
                centavos: 50000,
                data: null,
              ),
            ],
          ),
          carregarVendas: () async => _exemplo(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Financeiro dos animais'), findsOneWidget);
    expect(find.text('Financeiro das vendas'), findsOneWidget);
    expect(find.text('Receitas e despesas dos animais'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
