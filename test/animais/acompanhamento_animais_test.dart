import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gestor_haras/models/cavalo_model.dart';
import 'package:gestor_haras/models/financeiro_animais.dart';
import 'package:gestor_haras/models/medicamento_model.dart';
import 'package:gestor_haras/models/registro_animal_model.dart';
import 'package:gestor_haras/services/medicamento_service.dart';
import 'package:gestor_haras/services/registro_animal_service.dart';
import 'package:gestor_haras/views/animais/acompanhamento_animais_page.dart';

class _LancamentosFake implements MedicamentoRepository {
  @override
  Future<void> cadastrar(MedicamentoModel medicamento) async {}

  @override
  Future<void> encerrar(String id) async {}

  @override
  Future<int> limparHistorico() async => 0;

  @override
  Future<List<CavaloModel>> listarAnimais() async => const [
    CavaloModel(
      id: 'animal-1',
      nome: 'Lua Serena',
      raca: 'Mangalarga Marchador',
      pai: 'Trilho',
      mae: 'Polaca',
    ),
  ];

  @override
  Stream<List<MedicamentoModel>> observar() => Stream.value([
    MedicamentoModel(
      id: 'dieta-1',
      nome: 'Ração Premium',
      dose: '2 kg',
      valorCentavos: 2000,
      frequencia: FrequenciaMedicamento.diario,
      dataInicio: DateTime(2026, 9, 1),
      animalIds: const ['animal-1'],
      animalNomes: const {'animal-1': 'Lua Serena'},
      tipo: TipoTratamento.racao,
    ),
    MedicamentoModel(
      id: 'remedio-1',
      nome: 'Vermífugo',
      dose: '10 ml',
      valorCentavos: 3000,
      frequencia: FrequenciaMedicamento.mensal,
      dataInicio: DateTime(2026, 9, 2),
      animalIds: const ['animal-1'],
      animalNomes: const {'animal-1': 'Lua Serena'},
    ),
  ]);

  @override
  Future<int> sincronizarTudo() async => 0;
}

class _RegistrosFake implements RegistroAnimalRepository {
  @override
  Future<void> excluir(String id) async {}

  @override
  Future<List<CavaloModel>> listarAnimais() async => const [];

  @override
  Stream<List<RegistroAnimalModel>> observar(TipoRegistroAnimal tipo) =>
      Stream.value([
        RegistroAnimalModel(
          id: tipo.name,
          tipo: tipo,
          animalId: 'animal-1',
          animalNome: 'Lua Serena',
          data: DateTime(2026, 9, 3),
          titulo: tipo == TipoRegistroAnimal.controle ? '' : tipo.titulo,
          alturaMetros: tipo == TipoRegistroAnimal.controle ? 1.6 : null,
          pesoKg: tipo == TipoRegistroAnimal.controle ? 480 : null,
        ),
      ]);

  @override
  Future<void> salvar(RegistroAnimalModel registro) async {}
}

Future<FinanceiroAnimaisDados> _financeiro() async => FinanceiroAnimaisDados(
  animais: const {'animal-1': 'Lua Serena'},
  movimentos: [
    MovimentoAnimal(
      id: 'r1',
      animalId: 'animal-1',
      animalNome: 'Lua Serena',
      tipo: TipoMovimentoAnimal.receita,
      descricao: 'Treinamento',
      categoria: 'Treinamento',
      centavos: 10000,
      data: DateTime(2026, 9, 1),
    ),
    MovimentoAnimal(
      id: 'd1',
      animalId: 'animal-1',
      animalNome: 'Lua Serena',
      tipo: TipoMovimentoAnimal.despesa,
      descricao: 'Vermífugo',
      categoria: 'Remédio',
      centavos: 3500,
      data: DateTime(2026, 9, 2),
    ),
  ],
);

void main() {
  testWidgets('reúne todo o detalhamento do animal no celular', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: AcompanhamentoAnimaisPage(
          lancamentosRepository: _LancamentosFake(),
          registrosRepository: _RegistrosFake(),
          carregarFinanceiro: _financeiro,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Lua Serena'), findsWidgets);
    expect(find.text('Dietas e suplementos'), findsWidgets);
    expect(find.text('Ração: Ração Premium'), findsOneWidget);
    expect(find.text('Remédios e vacinas'), findsWidgets);
    await tester.drag(find.byType(TabBarView), const Offset(-350, 0));
    await tester.pumpAndSettle();
    expect(find.text('Remédio: Vermífugo'), findsOneWidget);
    expect(find.text('Altura e peso'), findsOneWidget);
    expect(find.text('Treinamentos'), findsWidgets);
    expect(find.text('Reprodução'), findsWidgets);
    expect(find.text('Financeiro'), findsOneWidget);
    expect(find.textContaining('100,00'), findsWidgets);
    expect(find.textContaining('35,00'), findsWidgets);
    expect(find.textContaining('65,00'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
