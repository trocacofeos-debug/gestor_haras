import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gestor_haras/models/cavalo_model.dart';
import 'package:gestor_haras/models/medicamento_model.dart';
import 'package:gestor_haras/services/medicamento_service.dart';
import 'package:gestor_haras/views/cadastros/medicamentos_page.dart';

class _RepositorioFake implements MedicamentoRepository {
  final itens = <MedicamentoModel>[
    MedicamentoModel(
      id: 'm1',
      nome: 'Vermífugo',
      dose: '10 ml',
      valorCentavos: 2500,
      frequencia: FrequenciaMedicamento.mensal,
      dataInicio: DateTime(2026, 8, 31),
      animalIds: const ['a1', 'a2'],
      animalNomes: const {'a1': 'Lua', 'a2': 'Sol'},
    ),
  ];

  @override
  Stream<List<MedicamentoModel>> observar() => Stream.value(itens);

  @override
  Future<List<CavaloModel>> listarAnimais() async => const [
    CavaloModel(id: 'a1', nome: 'Lua'),
    CavaloModel(id: 'a2', nome: 'Sol'),
  ];

  @override
  Future<void> cadastrar(MedicamentoModel medicamento) async {}

  @override
  Future<void> encerrar(String id) async {}

  @override
  Future<int> sincronizarTudo() async => 0;
}

void main() {
  testWidgets('lista de remédios funciona em largura mobile', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(home: MedicamentosPage(repository: _RepositorioFake())),
    );
    await tester.pumpAndSettle();

    expect(find.text('Vermífugo'), findsOneWidget);
    expect(find.textContaining('2 animal(is)'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('formulário permite selecionar vários animais', (tester) async {
    tester.view.physicalSize = const Size(900, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: CadastroMedicamentoPage(repository: _RepositorioFake()),
      ),
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const ValueKey('animal_a1')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('animal_a1')));
    await tester.tap(find.byKey(const ValueKey('animal_a2')));
    await tester.pump();

    expect(find.text('2 selecionado(s)'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('vacinas e suplementos usam títulos próprios', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: MedicamentosPage(
          repository: _RepositorioFake(),
          tipo: TipoTratamento.vacina,
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Vacinas'), findsOneWidget);
    expect(find.text('Cadastrar vacina'), findsOneWidget);

    await tester.pumpWidget(
      MaterialApp(
        home: MedicamentosPage(
          repository: _RepositorioFake(),
          tipo: TipoTratamento.suplemento,
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Suplementos'), findsOneWidget);
    expect(find.text('Cadastrar suplemento'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
