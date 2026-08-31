import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gestor_haras/widgets/app_dialogs.dart';
import 'package:gestor_haras/widgets/desktop_window.dart';
import 'package:gestor_haras/widgets/popup_workspace.dart';

final _finished = <String, String?>{};
final _contexts = <String, BuildContext>{};
int _disposed = 0;

class _Editor extends StatefulWidget {
  final String name;
  const _Editor(this.name);
  @override
  State<_Editor> createState() => _EditorState();
}

class _EditorState extends State<_Editor> {
  final controller = TextEditingController();
  @override
  void dispose() {
    controller.dispose();
    _disposed++;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _contexts[widget.name] = context;
    return Scaffold(
      body: Column(
        children: [
          TextField(
            controller: controller,
            decoration: InputDecoration(labelText: 'Campo ${widget.name}'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Salvar'),
          ),
          TextButton(
            onPressed: () => showAppDialog<bool>(
              context: context,
              title: 'Confirmação',
              builder: (ctx) => AlertDialog(
                title: const Text('Confirmar ação'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    child: const Text('Confirmar'),
                  ),
                ],
              ),
            ),
            child: const Text('Abrir confirmação'),
          ),
        ],
      ),
    );
  }
}

Future<void> _setup(
  WidgetTester tester, {
  bool desktop = true,
  GlobalKey<PopupWorkspaceState>? workspaceKey,
}) async {
  tester.view.physicalSize = desktop
      ? const Size(1280, 800)
      : const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final key = workspaceKey ?? GlobalKey<PopupWorkspaceState>();
  await tester.pumpWidget(
    MaterialApp(
      navigatorObservers: [PopupWorkspaceObserver(key)],
      builder: (_, child) => PopupWorkspace(key: key, child: child!),
      home: Builder(
        builder: (context) => Scaffold(
          body: Column(
            children: [
              for (final name in ['A', 'B'])
                TextButton(
                  onPressed: () async {
                    _finished[name] = await openDesktopWindow<String>(
                      context,
                      title: 'Cadastro $name',
                      builder: (_) => _Editor(name),
                    );
                  },
                  child: Text('Abrir $name'),
                ),
              TextButton(
                onPressed: () async {
                  _finished['dialog'] = await showAppDialog<String>(
                    context: context,
                    title: 'Detalhes',
                    builder: (_) => const Dialog(
                      child: SizedBox(
                        width: 500,
                        height: 350,
                        child: _Editor('dialog'),
                      ),
                    ),
                  );
                },
                child: const Text('Abrir diálogo'),
              ),
              TextButton(
                onPressed: () async {
                  final range = await showAppDateRangePicker(
                    context: context,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2030),
                    initialDateRange: DateTimeRange(
                      start: DateTime(2026, 1, 2),
                      end: DateTime(2026, 1, 8),
                    ),
                    saveText: 'Aplicar período',
                  );
                  _finished['periodo'] = range?.start.toIso8601String();
                },
                child: const Text('Abrir período'),
              ),
              TextButton(
                onPressed: () => Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) => const Scaffold(body: Text('Saiu')),
                  ),
                  (_) => false,
                ),
                child: const Text('Sair'),
              ),
            ],
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  setUp(() {
    _finished.clear();
    _contexts.clear();
    _disposed = 0;
  });

  testWidgets(
    'minimiza sem fechar nem perder texto e permite usar tela de fundo',
    (tester) async {
      await _setup(tester);
      await tester.tap(find.text('Abrir A'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'Rascunho preservado');
      await tester.tap(find.byTooltip('Minimizar'));
      await tester.pumpAndSettle();
      expect(find.byType(TextField), findsNothing);
      expect(_disposed, 0);
      expect(_finished, isEmpty);
      await tester.tap(find.text('Abrir B'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'Segundo cadastro');
      await tester.tap(find.byTooltip('Minimizar'));
      await tester.pumpAndSettle();
      await tester.tap(find.bySemanticsLabel('Restaurar Cadastro A'));
      await tester.pumpAndSettle();
      expect(find.text('Rascunho preservado'), findsOneWidget);
      await tester.tap(find.text('Salvar'));
      await tester.pumpAndSettle();
      expect(_finished['A'], 'Rascunho preservado');
      expect(_finished.containsKey('B'), false);
      await tester.tap(find.bySemanticsLabel('Restaurar Cadastro B'));
      await tester.pumpAndSettle();
      expect(find.text('Segundo cadastro'), findsOneWidget);
      await tester.tap(find.text('Salvar'));
      await tester.pumpAndSettle();
      expect(_finished['B'], 'Segundo cadastro');
      expect(_disposed, 2);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'conclusão assíncrona de popup minimizado não fecha outro popup',
    (tester) async {
      await _setup(tester);
      await tester.tap(find.text('Abrir A'));
      await tester.pumpAndSettle();
      final backgroundContext = _contexts['A']!;
      await tester.tap(find.byTooltip('Minimizar'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Abrir B'));
      await tester.pumpAndSettle();
      Navigator.pop(backgroundContext, 'Salvo em segundo plano');
      await tester.pumpAndSettle();
      expect(_finished['A'], 'Salvo em segundo plano');
      expect(find.text('Campo B'), findsOneWidget);
      expect(find.bySemanticsLabel('Restaurar Cadastro A'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  for (final desktop in [false, true]) {
    testWidgets('diálogo compacto minimiza e restaura em desktop=$desktop', (
      tester,
    ) async {
      await _setup(tester, desktop: desktop);
      await tester.tap(find.text('Abrir diálogo'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'Texto do diálogo');
      await tester.tap(find.byTooltip('Minimizar popup'));
      await tester.pumpAndSettle();
      expect(_finished, isEmpty);
      await tester.tap(find.bySemanticsLabel('Restaurar Detalhes'));
      await tester.pumpAndSettle();
      expect(find.text('Texto do diálogo'), findsOneWidget);
      await tester.tap(find.text('Salvar'));
      await tester.pumpAndSettle();
      expect(_finished['dialog'], 'Texto do diálogo');
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('minimiza confirmação filha sem fechar cadastro pai', (
    tester,
  ) async {
    await _setup(tester);
    await tester.tap(find.text('Abrir A'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Pai');
    await tester.tap(find.text('Abrir confirmação'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Minimizar popup'));
    await tester.pumpAndSettle();
    expect(find.text('Pai'), findsOneWidget);
    await tester.tap(find.bySemanticsLabel('Restaurar Confirmação'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Confirmar'));
    await tester.pumpAndSettle();
    expect(find.text('Pai'), findsOneWidget);
    expect(_finished, isEmpty);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'logout descarta popups minimizados sem deixá-los em outra sessão',
    (tester) async {
      await _setup(tester);
      await tester.tap(find.text('Abrir A'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Minimizar'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Sair'));
      await tester.pumpAndSettle();
      expect(find.text('Saiu'), findsOneWidget);
      expect(find.bySemanticsLabel('Restaurar Cadastro A'), findsNothing);
      expect(_finished.containsKey('A'), true);
      expect(_finished['A'], isNull);
      expect(_disposed, 1);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('fechar pai remove confirmação minimizada dependente', (
    tester,
  ) async {
    await _setup(tester);
    await tester.tap(find.text('Abrir A'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Abrir confirmação'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Minimizar popup'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Fechar'));
    await tester.pumpAndSettle();
    expect(find.bySemanticsLabel('Restaurar Confirmação'), findsNothing);
    expect(_finished.containsKey('A'), true);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'calendário mantém seleção e botão aplicar livre após restaurar',
    (tester) async {
      await _setup(tester, desktop: false);
      await tester.tap(find.text('Abrir período'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Minimizar popup'));
      await tester.pumpAndSettle();
      await tester.tap(find.bySemanticsLabel('Restaurar Selecionar período'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Aplicar período'));
      await tester.pumpAndSettle();
      expect(_finished['periodo'], '2026-01-02T00:00:00.000');
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('restaura janela maximizada no mesmo tamanho', (tester) async {
    await _setup(tester);
    await tester.tap(find.text('Abrir A'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Maximizar'));
    await tester.pumpAndSettle();
    final size = tester.getSize(find.byType(_Editor));
    await tester.tap(find.byTooltip('Minimizar'));
    await tester.pumpAndSettle();
    await tester.tap(find.bySemanticsLabel('Restaurar Cadastro A'));
    await tester.pumpAndSettle();
    expect(tester.getSize(find.byType(_Editor)), size);
    expect(find.byTooltip('Restaurar'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
