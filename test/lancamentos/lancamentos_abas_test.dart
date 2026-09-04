import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gestor_haras/models/cavalo_model.dart';
import 'package:gestor_haras/models/ficha_abccmm.dart';
import 'package:gestor_haras/models/medicamento_model.dart';
import 'package:gestor_haras/models/produto_model.dart';
import 'package:gestor_haras/models/registro_animal_model.dart';
import 'package:gestor_haras/services/medicamento_service.dart';
import 'package:gestor_haras/services/produto_service.dart';
import 'package:gestor_haras/services/registro_animal_service.dart';
import 'package:gestor_haras/views/cadastros/lancamentos_page.dart';
import 'package:gestor_haras/views/cadastros/registros_animais_page.dart';

class _MedicamentosFake implements MedicamentoRepository {
  @override
  Future<void> cadastrar(MedicamentoModel medicamento) async {}

  @override
  Future<void> encerrar(String id) async {}

  @override
  Future<int> limparHistorico() async => 0;

  @override
  Future<List<CavaloModel>> listarAnimais() async => const [
    CavaloModel(id: 'a1', nome: 'Lua'),
  ];

  @override
  Stream<List<MedicamentoModel>> observar() => Stream.value(const []);

  @override
  Future<int> sincronizarTudo() async => 0;
}

class _ProdutosFake implements ProdutoRepository {
  @override
  Future<void> definirAtivo(String id, bool ativo) async {}

  @override
  Future<List<ProdutoModel>> listar() async => const [];

  @override
  Stream<List<ProdutoModel>> observar() => Stream.value(const []);

  @override
  Future<void> salvar(ProdutoModel produto) async {}
}

class _RegistrosFake implements RegistroAnimalRepository {
  RegistroAnimalModel? salvo;

  @override
  Future<void> excluir(String id) async {}

  @override
  Future<List<CavaloModel>> listarAnimais() async => [
    CavaloModel(
      id: 'a1',
      nome: 'Lua',
      pai: 'Trilho da Zizica',
      mae: 'Favacho Polaca',
      altura: 1.55,
      peso: 450,
      fichaAbccmm: FichaAbccmm(dataNascimento: DateTime(2013, 2, 1)),
    ),
  ];

  @override
  Stream<List<RegistroAnimalModel>> observar(TipoRegistroAnimal tipo) =>
      Stream.value(const []);

  @override
  Future<void> salvar(RegistroAnimalModel registro) async => salvo = registro;
}

void main() {
  testWidgets('Lançamentos apresenta as cinco áreas de manejo', (tester) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: LancamentosPage(
          medicamentosRepository: _MedicamentosFake(),
          produtosRepository: _ProdutosFake(),
          registrosRepository: _RegistrosFake(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Dietas e suplementos'), findsWidgets);
    expect(find.text('Altura, peso e controle'), findsOneWidget);
    expect(find.text('Remédios e vermífugos'), findsOneWidget);
    expect(find.text('Treinamento'), findsOneWidget);
    expect(find.text('Reprodução'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('salva altura e peso vinculados ao animal', (tester) async {
    final repository = _RegistrosFake();
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: CadastroRegistroAnimalPage(
          tipo: TipoRegistroAnimal.controle,
          repository: repository,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Controle / avaliação'), findsNothing);
    expect(find.text('Status / resultado'), findsNothing);
    await tester.tap(find.byKey(const ValueKey('registro-animal')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Lua').last);
    await tester.pump();

    expect(find.text('Nascimento: 01/02/2013'), findsOneWidget);
    expect(
      tester
          .widget<TextFormField>(find.byKey(const ValueKey('registro-pai')))
          .controller
          ?.text,
      'Trilho da Zizica',
    );
    expect(
      tester
          .widget<TextFormField>(find.byKey(const ValueKey('registro-mae')))
          .controller
          ?.text,
      'Favacho Polaca',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Altura (m)'),
      '1,65',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Peso (kg)'),
      '480.5',
    );
    await tester.ensureVisible(
      find.byKey(const ValueKey('salvar-registro-animal')),
    );
    await tester.drag(find.byType(ListView).first, const Offset(0, -80));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('salvar-registro-animal')));
    await tester.pumpAndSettle();

    expect(repository.salvo?.animalNome, 'Lua');
    expect(repository.salvo?.alturaMetros, 1.65);
    expect(repository.salvo?.pesoKg, 480.5);
    expect(repository.salvo?.pai, 'Trilho da Zizica');
    expect(repository.salvo?.mae, 'Favacho Polaca');
    expect(repository.salvo?.dataNascimento, DateTime(2013, 2, 1));
    expect(tester.takeException(), isNull);
  });
}
