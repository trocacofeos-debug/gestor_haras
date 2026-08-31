import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
// ignore: depend_on_referenced_packages
import 'package:firebase_core_platform_interface/test.dart';
// ignore: depend_on_referenced_packages
import 'package:cloud_firestore_platform_interface/cloud_firestore_platform_interface.dart'
    as platform;
import 'package:gestor_haras/models/funcionario_model.dart';
import 'package:gestor_haras/services/cloudflare_r2_service.dart';
import 'package:gestor_haras/services/funcionario_cadastro_formatos.dart';
import 'package:gestor_haras/views/cadastros/cadastro_funcionario_page.dart';
import 'package:gestor_haras/views/cadastros/funcionarios_lista_view.dart';
import 'package:gestor_haras/views/cadastros/funcionario_detalhes_page.dart';
import 'package:gestor_haras/widgets/funcionario_foto.dart';

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

const _antigo = FuncionarioModel(
  id: 'teste',
  nome: 'João de Souza',
  cargo: 'Tratador',
  salario: 1500,
  ativo: false,
  fotoUrl: '',
  ctpsNumero: '0012345',
  ctpsSerie: '002',
  ctpsUf: 'MG',
  emergenciaNome: 'Contato de exemplo',
);

class _Upload extends CloudflareR2Service {
  int chamadas = 0;
  bool falhar = false;
  @override
  Future<String> uploadArquivo({
    required PlatformFile arquivo,
    required String pasta,
  }) async {
    chamadas++;
    expect(pasta, 'funcionarios');
    if (falhar) throw Exception('Falha simulada');
    return 'https://example.test/funcionario.png';
  }
}

class _Picker extends FilePicker {
  FilePickerResult? resultado;
  @override
  Future<FilePickerResult?> pickFiles({
    String? dialogTitle,
    String? initialDirectory,
    FileType type = FileType.any,
    List<String>? allowedExtensions,
    Function(FilePickerStatus)? onFileLoading,
    bool allowCompression = false,
    int compressionQuality = 0,
    bool allowMultiple = false,
    bool withData = false,
    bool withReadStream = false,
    bool lockParentWindow = false,
    bool readSequential = false,
  }) async => resultado;
}

Future<void> _abrir(
  WidgetTester tester, {
  bool novo = false,
  Size size = const Size(1100, 760),
  _Upload? upload,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  gravado = null;
  await tester.pumpWidget(
    MaterialApp(
      home: Builder(
        builder: (context) => Scaffold(
          body: TextButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CadastroFuncionarioPage(
                  funcionarioParaEditar: novo ? null : _antigo,
                  uploadService: upload,
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
}

Future<void> _preencher(WidgetTester tester, String label, String value) async {
  final campo = find.widgetWithText(TextFormField, label);
  await tester.ensureVisible(campo);
  await tester.enterText(campo, value);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setupFirebaseCoreMocks();
  setUpAll(() async {
    FilePicker.platform = _Picker();
    await Firebase.initializeApp();
    platform.FirebaseFirestorePlatform.instance = _Firestore();
  });
  test(
    'salário aceita formatos brasileiros e edição sem multiplicar por cem',
    () {
      for (final valor in ['1500.00', '1500,00', '1.500,00', '1.500', '1500']) {
        expect(FuncionarioCadastroFormatos.lerSalario(valor), 1500);
      }
      expect(FuncionarioCadastroFormatos.lerSalario('NaN'), isNull);
      expect(FuncionarioCadastroFormatos.lerSalario('-10'), isNull);
      expect(FuncionarioCadastroFormatos.lerSalario('1,2,3'), isNull);
      expect(FuncionarioCadastroFormatos.lerSalario(''), 0);
    },
  );
  test(
    'modelo mantém documentos, foto, datas e compatibilidade com registros antigos',
    () {
      final f = FuncionarioModel.fromMap(_antigo.toMap(), _antigo.id);
      expect(f.ctpsNumero, '0012345');
      expect(f.ctpsSerie, '002');
      expect(f.ativo, false);
      expect(f.salario, 1500);
      final vazio = FuncionarioModel.fromMap({'nome': 'Antigo'}, 'antigo');
      expect(vazio.fotoUrl, '');
      expect(vazio.ctpsNumero, '');
      expect(vazio.dataNascimento, isNull);
    },
  );
  for (final novo in [true, false]) {
    for (final size in [const Size(390, 844), const Size(1100, 760)]) {
      testWidgets('cadastro e edição persistem dados em $size, novo=$novo', (
        tester,
      ) async {
        await _abrir(tester, novo: novo, size: size);
        for (final e in {
          'Nome completo': 'Funcionário de teste',
          'Cargo': 'Tratador',
          'Salário (R\$)': '1.500,00',
          'Carteira de trabalho (número)': '000123',
          'Série da CTPS': '004',
          'UF da CTPS': 'MG',
          'Matrícula': '001',
          'Jornada / horário': '08h às 17h',
          'Contato de emergência': 'Contato de exemplo',
          'Telefone de emergência': '31999990000',
        }.entries) {
          await _preencher(tester, e.key, e.value);
        }
        await tester.tap(find.text('Salvar funcionário'));
        await tester.pumpAndSettle();
        expect(gravado?['salario'], 1500);
        expect(gravado?['ctpsNumero'], '000123');
        expect(gravado?['ctpsSerie'], '004');
        expect(gravado?['matricula'], '001');
        expect(gravado?['emergenciaTelefone'], '31999990000');
        expect(gravado?['ativo'], novo);
        if (!novo) expect(gravado?['dataAdmissao'], isNull);
        expect(find.text('Abrir'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }
  }
  testWidgets(
    'datas inválidas e desligamento antes da admissão não são salvos',
    (tester) async {
      await _abrir(tester);
      await _preencher(tester, 'Data de nascimento', '31/02/2020');
      await _preencher(tester, 'Data de admissão', '02/01/2024');
      await _preencher(tester, 'Data de desligamento', '01/01/2024');
      await tester.tap(find.text('Salvar funcionário'));
      await tester.pumpAndSettle();
      expect(gravado, isNull);
      expect(find.text('Informe uma data válida (DD/MM/AAAA)'), findsOneWidget);
      expect(find.text('Desligamento anterior à admissão'), findsOneWidget);
    },
  );
  testWidgets(
    'foto é enviada apenas ao salvar; falha mantém formulário e permite repetir',
    (tester) async {
      final upload = _Upload()..falhar = true;
      final picker = _Picker();
      final original = FilePicker.platform;
      FilePicker.platform = picker;
      addTearDown(() => FilePicker.platform = original);
      final bytes = base64Decode(
        'iVBORw0KGgoAAAANSUhEUgAAAAIAAAACCAIAAAD91JpzAAAAEElEQVR4nGNocFAAIgYIBQAaDgOBnA45xwAAAABJRU5ErkJggg==',
      );
      picker.resultado = FilePickerResult([
        PlatformFile(name: 'foto.png', size: bytes.length, bytes: bytes),
      ]);
      await _abrir(tester, upload: upload);
      await tester.runAsync(() async {
        await tester.tap(find.text('Selecionar foto'));
        await Future<void>.delayed(const Duration(milliseconds: 100));
      });
      await tester.pumpAndSettle();
      expect(upload.chamadas, 0);
      expect(find.text('Desfazer seleção'), findsOneWidget);
      await tester.tap(find.text('Salvar funcionário'));
      await tester.pumpAndSettle();
      expect(upload.chamadas, 1);
      expect(gravado, isNull);
      expect(find.byType(CadastroFuncionarioPage), findsOneWidget);
      upload.falhar = false;
      await tester.tap(find.text('Salvar funcionário'));
      await tester.pumpAndSettle();
      expect(upload.chamadas, 2);
      expect(gravado?['fotoUrl'], 'https://example.test/funcionario.png');
      expect(gravado?['ativo'], false);
    },
  );
  for (final desktop in [false, true]) {
    testWidgets('detalhes mostram CTPS e foto, desktop=$desktop', (
      tester,
    ) async {
      tester.view.physicalSize = desktop
          ? const Size(1280, 800)
          : const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        const MaterialApp(
          home: FuncionarioDetalhesPage(funcionarioId: 'teste'),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('João de Souza'), findsOneWidget);
      expect(find.byType(FuncionarioFoto), findsOneWidget);
      final carteira = find.text('0012345');
      await tester.ensureVisible(carteira);
      await tester.pumpAndSettle();
      expect(carteira.hitTestable(), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets(
      'lista mantém padrão de clientes e busca por nome acentuado, desktop=$desktop',
      (tester) async {
        tester.view.physicalSize = desktop
            ? const Size(1280, 800)
            : const Size(390, 844);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await tester.pumpWidget(
          MaterialApp(
            home: FuncionariosListaView(
              desktop: desktop,
              funcionarios: Stream.value([
                _antigo,
                const FuncionarioModel(
                  id: '2',
                  nome: 'Ana',
                  cargo: 'Veterinária',
                ),
              ]),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.byType(DataTable), desktop ? findsOneWidget : findsNothing);
        expect(find.byType(FuncionarioFoto), findsNWidgets(2));
        await tester.enterText(find.byType(TextField), 'joao');
        await tester.pumpAndSettle();
        expect(find.text('João de Souza'), findsOneWidget);
        expect(find.text('Ana'), findsNothing);
        await tester.tap(find.byTooltip('Limpar busca'));
        await tester.pumpAndSettle();
        expect(find.text('Ana'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  }
}
