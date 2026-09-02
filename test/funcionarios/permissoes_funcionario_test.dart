import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gestor_haras/models/funcionario_model.dart';
import 'package:gestor_haras/models/permissao_acesso.dart';
import 'package:gestor_haras/services/funcionario_permissoes_service.dart';
import 'package:gestor_haras/views/cadastros/funcionario_permissoes_page.dart';
import 'package:gestor_haras/views/cadastros/permissoes_funcionarios_page.dart';
import 'package:gestor_haras/views/home/admin_top_bar.dart';

class _RepositorioFake implements FuncionarioPermissoesRepository {
  Set<String>? salvas;
  String? funcionarioId;

  @override
  Future<ResultadoPermissoesFuncionario> salvar({
    required String funcionarioId,
    required String email,
    required Set<String> permissoes,
  }) async {
    this.funcionarioId = funcionarioId;
    salvas = {...permissoes};
    return const ResultadoPermissoesFuncionario(contasVinculadas: 1);
  }
}

class _ContasFake implements FuncionarioContasRepository {
  String? uidVinculado;
  String? funcionarioId;
  Set<String>? permissoes;

  @override
  Stream<List<ContaAcessoFuncionario>> listarContas() => Stream.value(const [
    ContaAcessoFuncionario(
      uid: 'u1',
      email: 'conta@haras.com',
      role: 'cliente',
      funcionarioId: '',
    ),
  ]);

  @override
  Future<void> vincularComoFuncionario({
    required String uid,
    required String funcionarioId,
    required Set<String> permissoes,
  }) async {
    uidVinculado = uid;
    this.funcionarioId = funcionarioId;
    this.permissoes = {...permissoes};
  }
}

void main() {
  tearDown(ControleAcesso.limpar);

  test('modelo preserva permissões e cadastro antigo começa sem acesso', () {
    final antigo = FuncionarioModel.fromMap({'nome': 'João'}, 'f1');
    final atual = FuncionarioModel.fromMap({
      'nome': 'Maria',
      'permissoes': ['clientes', 'animais'],
    }, 'f2');

    expect(antigo.permissoes, isEmpty);
    expect(atual.permissoes, {'clientes', 'animais'});
    expect(atual.toMap()['permissoes'], ['animais', 'clientes']);
  });

  test('controle libera somente os módulos escolhidos para funcionário', () {
    ControleAcesso.configurarFuncionario({'clientes', 'produtos'});

    expect(ControleAcesso.pode(ModuloAcesso.clientes), isTrue);
    expect(ControleAcesso.pode(ModuloAcesso.produtos), isTrue);
    expect(ControleAcesso.pode(ModuloAcesso.gestao), isFalse);
    expect(ControleAcesso.acessoTotal, isFalse);
  });

  testWidgets('administrador marca módulos e salva permissões', (tester) async {
    final repository = _RepositorioFake();
    final contasRepository = _ContasFake();
    const funcionario = FuncionarioModel(
      id: 'f1',
      nome: 'José da Silva',
      email: 'jose@haras.com',
      permissoes: {'clientes'},
    );
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: FuncionarioPermissoesPage(
          funcionario: funcionario,
          service: repository,
          contasService: contasRepository,
        ),
      ),
    );
    await tester.pumpAndSettle();

    final clientesFinder = find.byKey(const ValueKey('permissao_clientes'));
    await tester.scrollUntilVisible(
      clientesFinder,
      250,
      scrollable: find.byType(Scrollable).first,
    );
    final clientes = tester.widget<CheckboxListTile>(clientesFinder);
    expect(clientes.value, isTrue);
    final animais = find.byKey(const ValueKey('permissao_animais'));
    await tester.scrollUntilVisible(
      animais,
      120,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.drag(find.byType(ListView).first, const Offset(0, -180));
    await tester.pumpAndSettle();
    await tester.tap(animais);
    await tester.pump();
    final salvar = find.byKey(const ValueKey('salvar_permissoes'));
    await tester.ensureVisible(salvar);
    await tester.tap(salvar);
    await tester.pumpAndSettle();

    expect(repository.funcionarioId, 'f1');
    expect(repository.salvas, {'clientes', 'animais'});
    expect(tester.takeException(), isNull);
  });

  testWidgets('administrador transforma uma conta em funcionário', (
    tester,
  ) async {
    final repository = _RepositorioFake();
    final contasRepository = _ContasFake();
    const funcionario = FuncionarioModel(
      id: 'f1',
      nome: 'José da Silva',
      permissoes: {'clientes'},
    );
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: FuncionarioPermissoesPage(
          funcionario: funcionario,
          service: repository,
          contasService: contasRepository,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('conta_funcionario')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('conta@haras.com').last);
    await tester.pumpAndSettle();
    final botao = find.byKey(const ValueKey('vincular_conta_funcionario'));
    await tester.ensureVisible(botao);
    await tester.tap(botao);
    await tester.pumpAndSettle();

    expect(contasRepository.uidVinculado, 'u1');
    expect(contasRepository.funcionarioId, 'f1');
    expect(contasRepository.permissoes, {'clientes'});
    expect(find.text('Conta definida como funcionário.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('menu mostra somente os grupos permitidos ao funcionário', (
    tester,
  ) async {
    ControleAcesso.configurarFuncionario({'clientes'});
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: AdminTopBar())),
    );
    await tester.pumpAndSettle();

    expect(find.text('Cadastros'), findsOneWidget);
    expect(find.text('Gestão'), findsNothing);
    expect(find.text('Propostas'), findsNothing);
    expect(find.text('Site'), findsNothing);
    expect(find.text('Ajuda'), findsNothing);
    expect(find.text('Sair'), findsOneWidget);
    expect(find.text('FUNCIONÁRIO'), findsOneWidget);
    expect(find.text('Permissões'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('administrador abre a lista geral de permissões', (tester) async {
    ControleAcesso.liberarTudo();
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: PermissoesFuncionariosPage(
          funcionarios: Stream.value(const [
            FuncionarioModel(
              id: 'f1',
              nome: 'Maria Souza',
              email: 'maria@haras.com',
              permissoes: {'clientes', 'animais'},
            ),
          ]),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Permissões'), findsOneWidget);
    expect(find.text('Maria Souza'), findsOneWidget);
    expect(find.textContaining('2 de 9 módulos liberados'), findsOneWidget);
    expect(find.text('Integração'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
