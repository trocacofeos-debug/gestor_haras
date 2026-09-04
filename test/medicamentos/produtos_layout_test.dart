import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gestor_haras/models/medicamento_model.dart';
import 'package:gestor_haras/models/fornecedor_model.dart';
import 'package:gestor_haras/models/produto_model.dart';
import 'package:gestor_haras/services/produto_service.dart';
import 'package:gestor_haras/services/cloudflare_r2_service.dart';
import 'package:gestor_haras/views/cadastros/produtos_page.dart';

class _ProdutosFake implements ProdutoRepository {
  final produtos = <ProdutoModel>[
    const ProdutoModel(
      id: 'p1',
      nome: 'Vacina anual',
      tipo: TipoTratamento.vacina,
      quantidadePadrao: '1 dose',
      valorCentavos: 7500,
      quantidadeEstoque: 12.5,
      fornecedorId: 'f1',
      fornecedorNome: 'Agropecuária Central',
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

class _UploadProduto extends CloudflareR2Service {
  int chamadas = 0;

  @override
  Future<String> uploadArquivo({
    required PlatformFile arquivo,
    required String pasta,
  }) async {
    chamadas++;
    expect(pasta, 'produtos');
    return 'https://example.test/produto.png';
  }
}

Stream<List<FornecedorModel>> get _fornecedores => Stream.value(const [
  FornecedorModel(id: 'f1', nome: 'Agropecuária Central'),
]);

void main() {
  testWidgets('Produtos mostra somente o catálogo no celular', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: ProdutosPage(
          repository: _ProdutosFake(),
          fornecedores: _fornecedores,
        ),
      ),
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
      MaterialApp(
        home: CadastroProdutoPage(
          repository: repository,
          fornecedores: _fornecedores,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Dados do produto'), findsOneWidget);
    expect(find.text('Categoria'), findsOneWidget);
    expect(find.text('Tipo do produto'), findsNothing);
    expect(find.text('Quantidade em estoque *'), findsOneWidget);
    expect(find.text('Fornecedor (opcional)'), findsOneWidget);
    expect(find.text('Preço do produto *'), findsOneWidget);
    expect(find.textContaining('animal/aplicação'), findsNothing);
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
        home: CadastroProdutoPage(
          repository: repository,
          produto: produto,
          fornecedores: _fornecedores,
        ),
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
    await tester.scrollUntilVisible(
      salvar,
      400,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(salvar);
    await tester.pumpAndSettle();

    expect(repository.salvo?.id, 'p1');
    expect(repository.salvo?.nome, 'Vacina anual atualizada');
    expect(repository.salvo?.quantidadeEstoque, 12.5);
    expect(repository.salvo?.fornecedorId, 'f1');
    expect(repository.salvo?.fornecedorNome, 'Agropecuária Central');
    expect(tester.takeException(), isNull);
  });

  test('produto antigo mantém estoque zero e fornecedor opcional', () {
    final produto = ProdutoModel.fromMap({
      'nome': 'Produto antigo',
      'tipo': 'remedio',
      'quantidadePadrao': '1 unidade',
      'valorCentavos': 1000,
    }, 'p-antigo');

    expect(produto.quantidadeEstoque, 0);
    expect(produto.fornecedorId, isEmpty);
    expect(produto.fornecedorNome, isEmpty);
    expect(produto.fotoUrl, isEmpty);
  });

  testWidgets('foto do produto é enviada ao salvar', (tester) async {
    final repository = _ProdutosFake();
    final upload = _UploadProduto();
    final bytes = base64Decode(
      'iVBORw0KGgoAAAANSUhEUgAAAAIAAAACCAIAAAD91JpzAAAAEElEQVR4nGNocFAAIgYIBQAaDgOBnA45xwAAAABJRU5ErkJggg==',
    );
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: CadastroProdutoPage(
          repository: repository,
          produto: repository.produtos.single,
          fornecedores: _fornecedores,
          uploadService: upload,
          seletorFoto: () async => PlatformFile(
            name: 'produto.png',
            size: bytes.length,
            bytes: bytes,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.runAsync(() async {
      await tester.tap(find.byKey(const ValueKey('selecionar_foto_produto')));
      await Future<void>.delayed(const Duration(milliseconds: 100));
    });
    await tester.pumpAndSettle();
    expect(upload.chamadas, 0);
    expect(find.text('Remover foto'), findsOneWidget);

    final salvar = find.widgetWithText(FilledButton, 'Salvar alterações');
    await tester.scrollUntilVisible(
      salvar,
      400,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(salvar);
    await tester.pumpAndSettle();

    expect(upload.chamadas, 1);
    expect(repository.salvo?.fotoUrl, 'https://example.test/produto.png');
    expect(tester.takeException(), isNull);
  });
}
