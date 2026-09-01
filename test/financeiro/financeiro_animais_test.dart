import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
// ignore: depend_on_referenced_packages
import 'package:firebase_core_platform_interface/test.dart';
// ignore: depend_on_referenced_packages
import 'package:cloud_firestore_platform_interface/cloud_firestore_platform_interface.dart'
    as platform;
import 'package:gestor_haras/models/financeiro_animais.dart';
import 'package:gestor_haras/services/financeiro_animais_service.dart';
import 'package:gestor_haras/views/financeiro/financeiro_animais_page.dart';
import 'package:gestor_haras/views/financeiro/financeiro_animais_mobile.dart';
import 'package:gestor_haras/views/home/admin_top_bar.dart';
import 'package:gestor_haras/widgets/desktop_window.dart';

final _banco = <String, Map<String, Map<String, dynamic>>>{};
final _leituras = <String>[];
String? _falha;

class _Firestore extends platform.FirebaseFirestorePlatform {
  @override
  platform.FirebaseFirestorePlatform delegateFor({
    required FirebaseApp app,
    required String databaseId,
  }) => this;
  @override
  platform.CollectionReferencePlatform collection(String path) =>
      _Collection(this, path);
  @override
  platform.DocumentReferencePlatform doc(String path) => _Document(this, path);
}

class _Collection extends platform.CollectionReferencePlatform {
  _Collection(super.firestore, super.path);
  @override
  platform.DocumentReferencePlatform doc([String? id]) =>
      _Document(firestore, '$path/$id');
  @override
  Future<platform.QuerySnapshotPlatform> get([
    platform.GetOptions options = const platform.GetOptions(),
  ]) async {
    expect(options.source, platform.Source.server);
    _leituras.add(path);
    if (path == _falha) throw StateError('Falha simulada');
    return platform.QuerySnapshotPlatform(
      [
        for (final e in (_banco[path] ?? {}).entries)
          platform.DocumentSnapshotPlatform(
            firestore,
            '$path/${e.key}',
            e.value,
            platform.PigeonSnapshotMetadata(
              hasPendingWrites: false,
              isFromCache: false,
            ),
          ),
      ],
      [],
      platform.SnapshotMetadataPlatform(false, false),
    );
  }
}

class _Document extends platform.DocumentReferencePlatform {
  _Document(super.firestore, super.path);
}

MovimentoAnimal _mov(
  String id,
  String animal,
  TipoMovimentoAnimal tipo,
  num valor,
  DateTime? data,
) => MovimentoAnimal.fromMap(
  {
    'valor': valor,
    'data': data == null ? null : Timestamp.fromDate(data),
    'descricao': id,
    'categoria': 'alimento',
  },
  id: id,
  animalId: animal,
  animalNome: animal == 'a' ? 'PLAYBOY SG' : 'ÉGUA LUA',
  tipo: tipo,
)!;

FinanceiroAnimaisDados _exemplo() => FinanceiroAnimaisDados(
  animais: const {'a': 'PLAYBOY SG', 'b': 'ÉGUA LUA'},
  movimentos: [
    _mov(
      'Hospedagem',
      'a',
      TipoMovimentoAnimal.receita,
      1000.10,
      DateTime(2026, 8, 1),
    ),
    _mov(
      'Ração',
      'a',
      TipoMovimentoAnimal.despesa,
      300.05,
      DateTime(2026, 8, 31, 23, 59),
    ),
    _mov(
      'Serviço',
      'b',
      TipoMovimentoAnimal.receita,
      200.20,
      DateTime(2026, 7, 31),
    ),
    _mov(
      'Vacina',
      'b',
      TipoMovimentoAnimal.despesa,
      100.05,
      DateTime(2026, 9, 1),
    ),
  ],
);

Future<void> _mostrar(WidgetTester tester, Finder finder) async {
  await tester.scrollUntilVisible(
    finder,
    150,
    scrollable: find
        .descendant(
          of: find.byKey(const PageStorageKey('financeiro-scroll')),
          matching: find.byType(Scrollable),
        )
        .first,
  );
  await tester.pumpAndSettle();
}

Future<void> _topo(WidgetTester tester) async {
  tester
      .state<ScrollableState>(
        find
            .descendant(
              of: find.byKey(const PageStorageKey('financeiro-scroll')),
              matching: find.byType(Scrollable),
            )
            .first,
      )
      .position
      .jumpTo(0);
  await tester.pumpAndSettle();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setupFirebaseCoreMocks();
  setUpAll(() async {
    await Firebase.initializeApp();
    platform.FirebaseFirestorePlatform.instance = _Firestore();
  });
  setUp(() {
    _banco.clear();
    _leituras.clear();
    _falha = null;
  });

  test('soma receitas e despesas em centavos sem misturar animais', () {
    final dados = _exemplo();
    final total = ResumoFinanceiroAnimais.calcular(dados.movimentos);
    expect(total.receitas, 120030);
    expect(total.despesas, 40010);
    expect(total.saldo, 80020);
    final animal = ResumoFinanceiroAnimais.calcular(
      dados.filtrar(animalId: 'b'),
    );
    expect(animal.receitas, 20020);
    expect(animal.despesas, 10005);
    expect(animal.saldo, 10015);
    expect(dados.filtrar(tipo: TipoMovimentoAnimal.despesa).length, 2);
  });

  test(
    'período inclui dia final completo, exclui sem data e ordena recentes',
    () {
      final dados = _exemplo();
      final agosto = dados.filtrar(
        inicio: DateTime(2026, 8, 1),
        fim: DateTime(2026, 8, 31),
      );
      expect(agosto.map((e) => e.id), ['Ração', 'Hospedagem']);
      final semData = FinanceiroAnimaisDados(
        animais: dados.animais,
        movimentos: [
          ...dados.movimentos,
          _mov('Antigo sem data', 'a', TipoMovimentoAnimal.despesa, 25, null),
        ],
      );
      expect(semData.filtrar().last.id, 'Antigo sem data');
      expect(
        semData
            .filtrar(inicio: DateTime(2026, 8, 1), fim: DateTime(2026, 8, 31))
            .length,
        2,
      );
    },
  );

  test('valor inválido não vira total zero e data faltante não vira hoje', () {
    for (final valor in [null, '1.234,56', double.nan, double.infinity, -10]) {
      expect(
        MovimentoAnimal.fromMap(
          {'valor': valor},
          id: 'x',
          animalId: 'a',
          animalNome: 'Animal',
          tipo: TipoMovimentoAnimal.receita,
        ),
        isNull,
      );
    }
    expect(
      _mov('sem-data', 'a', TipoMovimentoAnimal.receita, 12, null).data,
      isNull,
    );
    expect(
      ResumoFinanceiroAnimais.calcular([
        _mov('despesa', 'a', TipoMovimentoAnimal.despesa, 10, null),
      ]).saldo,
      -1000,
    );
  });

  test(
    'lê fichas existentes inclusive animal inativo, sem duplicar contas de clientes',
    () async {
      _banco.addAll({
        'cavalos': {
          'a': {'nome': 'PLAYBOY SG'},
          'b': {'nome': 'ÉGUA LUA', 'ativo': false},
        },
        'cavalos/a/receitas': {
          '1': {'valor': 1000.10},
        },
        'cavalos/a/despesas': {
          '1': {'valor': 300.05, 'categoria': 'alimento'},
        },
        'cavalos/b/receitas': {
          '1': {'valor': 200.20},
        },
        'cavalos/b/despesas': {
          '1': {'valor': 100.05},
          '2': {'valor': 'inválido'},
        },
        'contasFinanceiras': {
          '1': {'valor': 50000},
        },
      });
      final dados = await const FinanceiroAnimaisService().carregar();
      expect(dados.animais.length, 2);
      expect(dados.movimentos.length, 4);
      expect(dados.movimentos.map((m) => m.id).toSet().length, 4);
      expect(dados.registrosInvalidos, 1);
      expect(ResumoFinanceiroAnimais.calcular(dados.movimentos).saldo, 80020);
      expect(
        _leituras,
        unorderedEquals([
          'cavalos',
          'cavalos/a/receitas',
          'cavalos/a/despesas',
          'cavalos/b/receitas',
          'cavalos/b/despesas',
        ]),
      );
    },
  );

  test('falha em uma ficha impede um resumo parcial', () async {
    _banco['cavalos'] = {
      'a': {'nome': 'Animal'},
    };
    _falha = 'cavalos/a/despesas';
    await expectLater(
      const FinanceiroAnimaisService().carregar(),
      throwsStateError,
    );
  });

  for (final tamanho in [
    const Size(320, 700),
    const Size(390, 844),
    const Size(844, 390),
    const Size(1100, 760),
  ]) {
    testWidgets('filtra lançamentos e limpa seleção em $tamanho', (
      tester,
    ) async {
      tester.view.physicalSize = tamanho;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        MaterialApp(
          home: FinanceiroAnimaisPage(carregar: () async => _exemplo()),
        ),
      );
      await tester.pumpAndSettle();
      final mobile = tamanho.width < 900;
      expect(find.textContaining('1.200,30'), findsOneWidget);
      expect(find.textContaining('400,10'), findsOneWidget);
      expect(find.textContaining('800,20'), findsOneWidget);
      if (mobile) {
        await _mostrar(tester, find.text('Filtros'));
        await tester.tap(find.text('Filtros'));
        await tester.pumpAndSettle();
        await _mostrar(tester, find.byKey(const ValueKey('animal-todos')));
      }
      await tester.tap(find.byKey(const ValueKey('animal-todos')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('PLAYBOY SG').last);
      await tester.pumpAndSettle();
      await _mostrar(
        tester,
        find.text('2 lançamento(s) nos filtros selecionados'),
      );
      expect(
        find.text('2 lançamento(s) nos filtros selecionados'),
        findsOneWidget,
      );
      expect(find.textContaining('700,05'), findsOneWidget);
      if (mobile) {
        final despesas = find.widgetWithText(ChoiceChip, 'Despesas');
        await _mostrar(tester, despesas);
        await tester.tap(despesas);
      } else {
        await _topo(tester);
        await tester.tap(find.byKey(const ValueKey('tipo-todos')));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Somente despesas').last);
      }
      await tester.pumpAndSettle();
      await _mostrar(
        tester,
        find.text('1 lançamento(s) nos filtros selecionados'),
      );
      expect(
        find.text('1 lançamento(s) nos filtros selecionados'),
        findsOneWidget,
      );
      expect(find.textContaining(RegExp(r'-.*300,05')), findsOneWidget);
      await _topo(tester);
      await _mostrar(tester, find.text('Limpar filtros'));
      await tester.tap(find.text('Limpar filtros'));
      await tester.pumpAndSettle();
      await _mostrar(
        tester,
        find.text('4 lançamento(s) nos filtros selecionados'),
      );
      expect(
        find.text('4 lançamento(s) nos filtros selecionados'),
        findsOneWidget,
      );
      await tester.drag(
        find.byKey(const PageStorageKey('financeiro-scroll')),
        const Offset(0, -900),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets(
    'mobile atualiza ao puxar e não mantém totais antigos quando a leitura falha',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      var leituras = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: FinanceiroAnimaisPage(
            carregar: () async {
              leituras++;
              if (leituras == 3) throw StateError('Sem conexão');
              if (leituras == 1) return _exemplo();
              return FinanceiroAnimaisDados(
                animais: const {'a': 'PLAYBOY SG'},
                movimentos: [
                  _mov(
                    'Nova receita',
                    'a',
                    TipoMovimentoAnimal.receita,
                    50,
                    DateTime(2026, 8, 31),
                  ),
                ],
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(FinanceiroAnimaisMobile), findsOneWidget);
      expect(find.byType(DataTable), findsNothing);
      await tester.drag(
        find.byKey(const PageStorageKey('financeiro-scroll')),
        const Offset(0, 400),
      );
      await tester.pumpAndSettle();
      expect(leituras, 2);
      expect(find.textContaining('800,20'), findsNothing);
      expect(find.textContaining('50,00'), findsWidgets);
      await tester.tap(find.byTooltip('Atualizar lançamentos'));
      await tester.pumpAndSettle();
      expect(find.text('Saldo'), findsNothing);
      expect(find.textContaining('resultado incompleto'), findsOneWidget);
      await tester.tap(find.text('Tentar novamente'));
      await tester.pumpAndSettle();
      expect(leituras, 4);
      expect(find.text('Saldo'), findsOneWidget);
    },
  );

  testWidgets('cadastra despesa escolhendo animal na Gestão mobile', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    NovoMovimentoAnimal? salvo;
    await tester.pumpWidget(
      MaterialApp(
        home: FinanceiroAnimaisPage(
          carregar: () async => _exemplo(),
          salvar: (movimento) async => salvo = movimento,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('novo-lancamento-financeiro')));
    await tester.pumpAndSettle();
    expect(find.text('Receita'), findsWidgets);
    expect(find.text('Despesa'), findsWidgets);

    await tester.tap(find.byKey(const ValueKey('novo-lancamento-animal')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('PLAYBOY SG').last);
    await tester.enterText(
      find.byKey(const ValueKey('novo-lancamento-descricao')),
      'Consulta veterinária',
    );
    await tester.enterText(
      find.byKey(const ValueKey('novo-lancamento-valor')),
      '150,50',
    );
    await tester.tap(find.byKey(const ValueKey('salvar-novo-lancamento')));
    await tester.pumpAndSettle();

    expect(salvo, isNotNull);
    expect(salvo!.animalId, 'a');
    expect(salvo!.tipo, TipoMovimentoAnimal.despesa);
    expect(salvo!.descricao, 'Consulta veterinária');
    expect(salvo!.centavos, 15050);
    expect(salvo!.categoria, 'outro');
    expect(find.text('Despesa adicionada ao animal.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'mobile mantém leitura com fonte ampliada e abre o animal correto',
    (tester) async {
      tester.view.physicalSize = const Size(320, 740);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      String? aberto;
      final movimento = MovimentoAnimal(
        id: 'despesa-longa',
        animalId: 'a',
        animalNome: 'ANIMAL COM NOME LONGO PARA CONSULTA NO CELULAR',
        tipo: TipoMovimentoAnimal.despesa,
        descricao: 'Tratamento veterinário e acompanhamento do animal',
        categoria: 'Veterinário',
        centavos: 123456789,
        data: DateTime(2026, 8, 31),
      );
      final dados = FinanceiroAnimaisDados(
        animais: {'a': movimento.animalNome},
        movimentos: [movimento],
      );
      await tester.pumpWidget(
        MaterialApp(
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: const TextScaler.linear(1.6)),
            child: child!,
          ),
          home: Scaffold(
            body: FinanceiroAnimaisMobile(
              dados: dados,
              movimentos: dados.movimentos,
              animalId: null,
              tipo: null,
              periodo: null,
              onAnimal: (_) {},
              onTipo: (_) {},
              onPeriodo: () {},
              onMes: () {},
              onLimpar: () {},
              onAtualizar: () async {},
              onAbrirAnimal: (id) => aberto = id,
              onNovoLancamento: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await _mostrar(tester, find.text(movimento.descricao));
      await tester.tap(find.text(movimento.descricao));
      expect(aberto, 'a');
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('erro não exibe totais e permite tentar novamente', (
    tester,
  ) async {
    var tentativas = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: FinanceiroAnimaisPage(
          carregar: () async {
            if (tentativas++ == 0) throw StateError('Erro de leitura');
            return const FinanceiroAnimaisDados(animais: {}, movimentos: []);
          },
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('resultado incompleto'), findsOneWidget);
    expect(find.text('Saldo'), findsNothing);
    await tester.tap(find.text('Tentar novamente'));
    await tester.pumpAndSettle();
    await _mostrar(tester, find.text('Nenhum animal cadastrado.'));
    expect(find.text('Nenhum animal cadastrado.'), findsOneWidget);
    expect(find.text('Saldo'), findsOneWidget);
    expect(tentativas, 2);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Gestão abre Financeiro em janela e mantém Dívidas separada', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Align(alignment: Alignment.topCenter, child: AdminTopBar()),
        ),
      ),
    );
    await tester.tap(find.text('Gestão'));
    await tester.pumpAndSettle();
    expect(find.text('Dívidas'), findsOneWidget);
    await tester.tap(find.text('Financeiro'));
    await tester.pumpAndSettle();
    expect(find.byType(FinanceiroAnimaisPage), findsOneWidget);
    expect(find.byType(DesktopWindowScope), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
