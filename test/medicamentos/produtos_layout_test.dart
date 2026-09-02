import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gestor_haras/models/medicamento_model.dart';
import 'package:gestor_haras/models/produto_model.dart';
import 'package:gestor_haras/services/produto_service.dart';
import 'package:gestor_haras/views/cadastros/produtos_page.dart';

class _ProdutosFake implements ProdutoRepository {
  final produtos = <ProdutoModel>[
    const ProdutoModel(
      id: 'p1',
      nome: 'Vacina anual',
      tipo: TipoTratamento.vacina,
      quantidadePadrao: '1 dose',
      valorCentavos: 7500,
    ),
  ];
  ProdutoModel? salvo;

  @override
  Stream<List<ProdutoModel>> observar() => Stream.value(produtos);

  @override
  Future<List<ProdutoModel>> listar() async => produtos;

  @override
  Future<void> salvar(ProdutoModel produto) async => salvo = produto;

  @override
  Future<void> definirAtivo(String id, bool ativo) async {}
}

void main() {
  testWidgets('Produtos mostra somente o catálogo no celular', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(home: ProdutosPage(repository: _ProdutosFake())),
    );
    await tester.pumpAndSettle();

    expect(find.text('Produtos'), findsOneWidget);
    expect(find.text('Vacina anual'), findsOneWidget);
    expect(find.text('Cadastrar produto'), findsOneWidget);
    expect(find.textContaining('Selecionar animais'), findsNothing);
    expect(find.text('Frequência'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('cadastro de produto não pede animal nem frequência', (
    tester,
  ) async {
    final repository = _ProdutosFake();
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(home: CadastroProdutoPage(repository: repository)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Dados do produto'), findsOneWidget);
    expect(find.text('Tipo do produto'), findsOneWidget);
    expect(find.textContaining('Selecionar animais'), findsNothing);
    expect(find.text('Frequência'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('edição preserva o id e salva as alterações', (tester) async {
    final repository = _ProdutosFake();
    final produto = repository.produtos.single;
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: CadastroProdutoPage(repository: repository, produto: produto),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Editar produto'), findsOneWidget);
    expect(find.text('Vacina anual'), findsOneWidget);
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Vacina anual'),
      'Vacina anual atualizada',
    );
    final salvar = find.widgetWithText(FilledButton, 'Salvar alterações');
    await tester.ensureVisible(salvar);
    await tester.tap(salvar);
    await tester.pumpAndSettle();

    expect(repository.salvo?.id, 'p1');
    expect(repository.salvo?.nome, 'Vacina anual atualizada');
    expect(tester.takeException(), isNull);
  });
}
