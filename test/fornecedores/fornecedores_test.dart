import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
// ignore: depend_on_referenced_packages
import 'package:firebase_core_platform_interface/test.dart';
// ignore: depend_on_referenced_packages
import 'package:cloud_firestore_platform_interface/cloud_firestore_platform_interface.dart'
    as platform;
import 'package:gestor_haras/models/fornecedor_model.dart';
import 'package:gestor_haras/views/cadastros/cadastro_fornecedor_page.dart';
import 'package:gestor_haras/views/cadastros/fornecedor_detalhes_page.dart';
import 'package:gestor_haras/views/cadastros/fornecedores_lista_view.dart';

Map<String, dynamic>? gravado;

class _Firestore extends platform.FirebaseFirestorePlatform {
  @override
  platform.FirebaseFirestorePlatform delegateFor({
    required FirebaseApp app,
    required String databaseId,
  }) => this;
  @override
  platform.CollectionReferencePlatform collection(String path) =>
      _Collection(this, path);
}

class _Collection extends platform.CollectionReferencePlatform {
  _Collection(super.firestore, super.path);
  @override
  platform.DocumentReferencePlatform doc([String? id]) =>
      _Document(firestore, '$path/${id ?? "novo"}');
}

class _Document extends platform.DocumentReferencePlatform {
  _Document(super.firestore, super.path);
  @override
  Future<void> set(
    Map<String, dynamic> data, [
    platform.SetOptions? options,
  ]) async => gravado = data;
  @override
  Future<void> update(Map<platform.FieldPath, dynamic> data) async {
    gravado = {
      for (final e in data.entries) e.key.components.join('.'): e.value,
    };
  }

  @override
  Stream<platform.DocumentSnapshotPlatform> snapshots({
    bool includeMetadataChanges = false,
    required platform.ListenSource listenSource,
  }) => Stream.value(
    platform.DocumentSnapshotPlatform(
      firestore,
      path,
      _antigo.toMap(),
      platform.PigeonSnapshotMetadata(
        hasPendingWrites: false,
        isFromCache: true,
      ),
    ),
  );
}

const _antigo = FornecedorModel(
  id: 'teste',
  nome: 'Rações São José',
  categoria: 'Alimentação',
  cpfCnpj: '00123456000199',
  telefone: '31999990000',
  email: 'contato@example.test',
  endereco: 'Rua do Haras, 12',
  observacoes: 'Entrega pela manhã',
  ativo: false,
);

Future<void> _tamanho(WidgetTester tester, bool desktop) async {
  tester.view.physicalSize = desktop
      ? const Size(1100, 760)
      : const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setupFirebaseCoreMocks();
  setUpAll(() async {
    await Firebase.initializeApp();
    platform.FirebaseFirestorePlatform.instance = _Firestore();
  });

  for (final desktop in [false, true]) {
    for (final novo in [false, true]) {
      testWidgets(
        'cadastro preserva campos e status, desktop=$desktop novo=$novo',
        (tester) async {
          await _tamanho(tester, desktop);
          gravado = null;
          await tester.pumpWidget(
            MaterialApp(
              home: Builder(
                builder: (context) => Scaffold(
                  body: TextButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CadastroFornecedorPage(
                          fornecedorParaEditar: novo ? null : _antigo,
                        ),
                      ),
                    ),
                    child: const Text('Abrir'),
                  ),
                ),
              ),
            ),
          );
          await tester.tap(find.text('Abrir'));
          await tester.pumpAndSettle();
          if (novo) {
            await tester.tap(
              find.text(desktop ? 'Salvar fornecedor' : 'Salvar'),
            );
            await tester.pumpAndSettle();
            expect(gravado, isNull);
            expect(find.text('Campo obrigatório'), findsOneWidget);
          }
          for (final e in {
            'Nome / Razão Social *': 'Rações São José',
            'CPF / CNPJ': '00123456000199',
            'Categoria': 'Alimentação',
            'Telefone': '31999990000',
            'Email': 'contato@example.test',
            'Endereço': 'Rua do Haras, 12',
            'Observações': 'Entrega pela manhã',
          }.entries) {
            final campo = find.widgetWithText(TextFormField, e.key);
            await tester.ensureVisible(campo);
            await tester.enterText(campo, e.value);
          }
          await tester.tap(find.text(desktop ? 'Salvar fornecedor' : 'Salvar'));
          await tester.pumpAndSettle();
          expect(gravado?['cpfCnpj'], '00123456000199');
          expect(gravado?['endereco'], 'Rua do Haras, 12');
          expect(gravado?['observacoes'], 'Entrega pela manhã');
          expect(gravado?['ativo'], novo);
          expect(find.text('Abrir'), findsOneWidget);
          expect(tester.takeException(), isNull);
        },
      );
    }
    testWidgets(
      'lista busca, abre detalhes e permite editar, desktop=$desktop',
      (tester) async {
        await _tamanho(tester, desktop);
        await tester.pumpWidget(
          MaterialApp(
            home: FornecedoresListaView(
              desktop: desktop,
              fornecedores: Stream.value([_antigo]),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.byType(DataTable), desktop ? findsOneWidget : findsNothing);
        await tester.enterText(find.byType(TextField), 'sao jose');
        await tester.pumpAndSettle();
        expect(find.text(_antigo.nome), findsOneWidget);
        await tester.enterText(find.byType(TextField), 'sem resultado');
        await tester.pumpAndSettle();
        expect(find.text('Nenhum fornecedor encontrado'), findsOneWidget);
        await tester.tap(find.byTooltip('Limpar busca'));
        await tester.pumpAndSettle();
        await tester.tap(find.text(_antigo.nome));
        await tester.pumpAndSettle();
        expect(find.byType(FornecedorDetalhesPage), findsOneWidget);
        expect(find.text('00123456000199'), findsOneWidget);
        await tester.tap(find.byTooltip('Editar fornecedor'));
        await tester.pumpAndSettle();
        expect(find.byType(CadastroFornecedorPage), findsOneWidget);
        final status = tester.widget<SwitchListTile>(
          find.byType(SwitchListTile),
        );
        expect(status.value, false);
      },
    );
  }
}
