import 'dart:convert';
import 'fixtures/abccmm_playboy.dart';
import 'fixtures/abccmm_genealogia.dart';
import 'package:gestor_haras/models/genealogia_abccmm.dart';
import 'package:file_picker/file_picker.dart';
import 'package:gestor_haras/models/cavalo_model.dart';
import 'package:gestor_haras/services/cloudflare_r2_service.dart';
import 'package:gestor_haras/views/cadastros/cadastro_cavalo_page.dart';
import 'package:gestor_haras/widgets/desktop_window.dart';
import 'package:firebase_core/firebase_core.dart';
// ignore: depend_on_referenced_packages
import 'package:firebase_core_platform_interface/test.dart';
// ignore: depend_on_referenced_packages
import 'package:cloud_firestore_platform_interface/cloud_firestore_platform_interface.dart'
    as platform;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gestor_haras/views/cadastros/cavalo_detalhes_page.dart';

final _metadata = platform.PigeonSnapshotMetadata(
  hasPendingWrites: false,
  isFromCache: true,
);
Map<platform.FieldPath, dynamic>? _ultimaAtualizacao;
Map<String, dynamic>? _ultimoCadastro;

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

class _Document extends platform.DocumentReferencePlatform {
  _Document(super.firestore, super.path);
  @override
  Future<void> set(
    Map<String, dynamic> data, [
    platform.SetOptions? options,
  ]) async {
    _ultimoCadastro = data;
  }

  @override
  Future<void> update(Map<platform.FieldPath, dynamic> data) async {
    _ultimaAtualizacao = data;
  }

  @override
  Stream<platform.DocumentSnapshotPlatform> snapshots({
    bool includeMetadataChanges = false,
    required platform.ListenSource listenSource,
  }) {
    return Stream.value(
      platform.DocumentSnapshotPlatform(firestore, path, {
        'nome': 'Estrela do Haras Exemplo',
        'raca': 'Mangalarga Marchador',
        'sexo': 'Fêmea',
        'pelagem': 'Castanha',
        'altura': 1.65,
        'peso': 480.5,
        'ativo': false,
        'proprietarioNome': 'Ana Carolina Ferreira da Silva',
        'observacoes': List.filled(
          40,
          'Observação extensa do animal.',
        ).join(' '),
      }, _metadata),
    );
  }
}

class _Collection extends platform.CollectionReferencePlatform {
  _Collection(super.firestore, super.path) {
    parameters['orderBy'] = <List<dynamic>>[];
    parameters['where'] = <List<dynamic>>[];
  }
  @override
  platform.DocumentReferencePlatform doc([String? id]) =>
      _Document(firestore, '$path/$id');
  @override
  platform.QueryPlatform orderBy(Iterable<List<dynamic>> orders) => this;
  @override
  Stream<platform.QuerySnapshotPlatform> snapshots({
    bool includeMetadataChanges = false,
    required platform.ListenSource listenSource,
  }) {
    return Stream.value(
      platform.QuerySnapshotPlatform(
        List.generate(
          25,
          (index) => platform.DocumentSnapshotPlatform(
            firestore,
            '$path/item-$index',
            {'descricao': 'Lançamento $index', 'valor': 100.0},
            _metadata,
          ),
        ),
        [],
        platform.SnapshotMetadataPlatform(false, true),
      ),
    );
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

class _Upload extends CloudflareR2Service {
  int chamadas = 0;
  bool falhar = false;
  @override
  Future<String> uploadArquivo({
    required PlatformFile arquivo,
    required String pasta,
  }) async {
    chamadas++;
    expect(pasta, 'cavalos');
    expect(arquivo.bytes, isNotEmpty);
    if (falhar) throw Exception('Falha simulada');
    return 'https://example.test/nova.png';
  }
}

PlatformFile _fotoTeste() {
  final bytes = base64Decode(
    'iVBORw0KGgoAAAANSUhEUgAAAAIAAAACCAIAAAD91JpzAAAAEElEQVR4nGNocFAAIgYIBQAaDgOBnA45xwAAAABJRU5ErkJggg==',
  );
  return PlatformFile(name: 'cavalo.png', size: bytes.length, bytes: bytes);
}

Future<void> _abrirEdicaoFoto(
  WidgetTester tester,
  _Upload upload,
  List<String> fotos, {
  bool novo = false,
  Size tamanho = const Size(1024, 600),
  GenealogiaAbccmm? genealogia,
}) async {
  tester.view.physicalSize = tamanho;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  _ultimaAtualizacao = null;
  await tester.pumpWidget(
    MaterialApp(
      home: Builder(
        builder: (context) => Scaffold(
          body: TextButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => DesktopWindowScope(
                  child: CadastroCavaloPage(
                    cavaloParaEditar: novo
                        ? null
                        : CavaloModel(
                            id: 'foto-teste',
                            nome: 'Estrela',
                            altura: 1.6,
                            peso: 450,
                            fotos: fotos,
                            ativo: false,
                            genealogiaAbccmm: genealogia,
                          ),
                    uploadService: upload,
                  ),
                ),
              ),
            ),
            child: const Text('Abrir edição'),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('Abrir edição'));
  await tester.pumpAndSettle();
}

Future<void> _escolherFoto(WidgetTester tester, String label) async {
  await tester.runAsync(() async {
    await tester.tap(find.text(label));
    // Let the engine decode the tiny PNG before inspecting its preview.
    await Future<void>.delayed(const Duration(milliseconds: 100));
  });
  await tester.pumpAndSettle();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setupFirebaseCoreMocks();
  setUpAll(() async {
    await Firebase.initializeApp();
    platform.FirebaseFirestorePlatform.instance = _Firestore();
  });

  test(
    'medidas antigas, numéricas e opcionais são serializadas corretamente',
    () {
      final antigo = CavaloModel.fromMap({'nome': 'Antigo'}, 'antigo');
      expect(antigo.altura, isNull);
      expect(antigo.peso, isNull);
      final atual = CavaloModel.fromMap({'altura': 1.65, 'peso': 480}, 'atual');
      expect(atual.altura, 1.65);
      expect(atual.peso, 480.0);
      expect(atual.toMap()['altura'], 1.65);
      expect(atual.toMap()['peso'], 480.0);
      expect(antigo.toMap()['altura'], isNull);
    },
  );

  for (final novo in [false, true]) {
    testWidgets(
      'genealogia é salva e preservada ao editar (${novo ? "novo" : "editar"})',
      (tester) async {
        await _abrirEdicaoFoto(tester, _Upload(), [], novo: novo);
        await tester.enterText(
          find.widgetWithText(TextFormField, 'Nome do cavalo'),
          'PLAYBOY SG',
        );
        await tester.tap(find.text('Importar dados da ABCCMM'));
        await tester.pumpAndSettle();
        await tester.enterText(
          find.descendant(
            of: find.byType(AlertDialog),
            matching: find.byType(TextField),
          ),
          genealogiaCopiada,
        );
        await tester.ensureVisible(find.text('Reconhecer campos'));
        await tester.tap(find.text('Reconhecer campos'));
        await tester.pumpAndSettle();
        for (final label in [
          'Pai: TRILHO DA ZIZICA',
          'Mãe: FAVACHO POLACA',
          'Importar genealogia revisada',
        ]) {
          await tester.ensureVisible(find.text(label));
          await tester.tap(find.text(label));
          await tester.pumpAndSettle();
        }
        await tester.tap(find.text('Preencher cadastro'));
        await tester.pumpAndSettle();
        expect(find.text('Genealogia importada (14 entradas)'), findsOneWidget);
        await tester.tap(
          find.text(novo ? 'Cadastrar cavalo' : 'Salvar alterações'),
        );
        await tester.pumpAndSettle();
        final mapa =
            (novo
                    ? (_ultimoCadastro?['genealogiaAbccmm'])
                    : (_ultimaAtualizacao?[platform.FieldPath([
                        'genealogiaAbccmm',
                      ])]))
                as Map;
        expect((mapa['ancestrais'] as List), hasLength(14));
        expect(
          novo
              ? (_ultimoCadastro?['pai'])
              : (_ultimaAtualizacao?[platform.FieldPath(['pai'])]),
          'TRILHO DA ZIZICA',
        );
        final genealogia = GenealogiaAbccmm.fromMap(
          Map<String, dynamic>.from(mapa),
        );
        await _abrirEdicaoFoto(tester, _Upload(), [], genealogia: genealogia);
        await tester.tap(find.text('Salvar alterações'));
        await tester.pumpAndSettle();
        expect(
          _ultimaAtualizacao?[platform.FieldPath(['genealogiaAbccmm'])],
          mapa,
        );
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'cola ficha PLAYBOY, revisa e salva (${novo ? "novo" : "editar"})',
      (tester) async {
        await _abrirEdicaoFoto(tester, _Upload(), [], novo: novo);
        await tester.tap(find.text('Importar dados da ABCCMM'));
        await tester.pumpAndSettle();
        final entrada = find.descendant(
          of: find.byType(AlertDialog),
          matching: find.byType(TextField),
        );
        await tester.enterText(entrada, fichaPlayboy);
        await tester.ensureVisible(find.text('Reconhecer campos'));
        await tester.tap(find.text('Reconhecer campos'));
        await tester.pumpAndSettle();
        final nomeImportado = find.widgetWithText(
          CheckboxListTile,
          'Nome do cavalo: PLAYBOY SG',
        );
        if (tester.widget<CheckboxListTile>(nomeImportado).value != true) {
          await tester.ensureVisible(nomeImportado);
          await tester.tap(nomeImportado);
        }
        await tester.tap(find.text('Preencher cadastro'));
        await tester.pumpAndSettle();
        expect(
          tester
              .widget<TextFormField>(
                find.widgetWithText(TextFormField, 'Nome do cavalo'),
              )
              .controller!
              .text,
          'PLAYBOY SG',
        );
        await tester.tap(
          find.text(novo ? 'Cadastrar cavalo' : 'Salvar alterações'),
        );
        await tester.pumpAndSettle();
        final ficha =
            (novo
                    ? (_ultimoCadastro?['fichaAbccmm'])
                    : (_ultimaAtualizacao?[platform.FieldPath([
                        'fichaAbccmm',
                      ])]))
                as Map;
        expect(ficha['dataNascimento'], '2013-02-01');
        expect(ficha['bloqueado'], false);
        expect(ficha['vivo'], true);
        expect(ficha['proprietario'], 'FREDERICO SANTOS GONÇALVES');
        expect(
          novo
              ? (_ultimoCadastro?['registroAbccmm'])
              : (_ultimaAtualizacao?[platform.FieldPath(['registroAbccmm'])]),
          '038184',
        );
        expect(
          novo
              ? (_ultimoCadastro?['proprietarioId'])
              : (_ultimaAtualizacao?[platform.FieldPath(['proprietarioId'])]),
          '',
        );
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'ficha no celular permite alcançar todos os campos (${novo ? "novo" : "editar"})',
      (tester) async {
        await _abrirEdicaoFoto(
          tester,
          _Upload(),
          [],
          novo: novo,
          tamanho: const Size(390, 844),
        );
        for (final label in [
          'Data de nascimento',
          'Chip',
          'Registro do pai',
          'Exame da mãe',
          'Criador',
          'Proprietário na ABCCMM',
          'Notas sobre o animal',
        ]) {
          final campo = find.widgetWithText(TextFormField, label);
          await tester.ensureVisible(campo);
          await tester.pumpAndSettle();
          expect(campo.hitTestable(), findsOneWidget);
          expect(tester.takeException(), isNull);
        }
        expect(
          find
              .text(novo ? 'Cadastrar cavalo' : 'Salvar alterações')
              .hitTestable(),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'ficha da associação: validar nascimento e salvar (${novo ? "novo" : "editar"})',
      (tester) async {
        await _abrirEdicaoFoto(tester, _Upload(), [], novo: novo);
        await tester.enterText(
          find.widgetWithText(TextFormField, 'Nome do cavalo'),
          'Estrela',
        );
        final nascimento = find.widgetWithText(
          TextFormField,
          'Data de nascimento',
        );
        await tester.ensureVisible(nascimento);
        await tester.enterText(nascimento, '31/02/2020');
        final salvar = find.text(
          novo ? 'Cadastrar cavalo' : 'Salvar alterações',
        );
        await tester.tap(salvar);
        await tester.pumpAndSettle();
        expect(
          find.text('Informe uma data válida (DD/MM/AAAA)'),
          findsOneWidget,
        );
        await tester.enterText(nascimento, '29/02/2020');
        for (final e in {
          'Chip': '00001234',
          'Livro': 'MM-6',
          'Criador': 'Haras Exemplo',
          'Proprietário na ABCCMM': 'Maria',
          'Registro do pai': '00123',
        }.entries) {
          final campo = find.widgetWithText(TextFormField, e.key);
          await tester.ensureVisible(campo);
          await tester.enterText(campo, e.value);
        }
        await tester.tap(salvar);
        await tester.pumpAndSettle();
        final ficha =
            (novo
                    ? (_ultimoCadastro?['fichaAbccmm'])
                    : (_ultimaAtualizacao?[platform.FieldPath([
                        'fichaAbccmm',
                      ])]))
                as Map;
        expect(ficha['dataNascimento'], '2020-02-29');
        expect(ficha['chip'], '00001234');
        expect(ficha['paiRegistro'], '00123');
        expect(ficha['criador'], 'Haras Exemplo');
        expect(ficha['proprietario'], 'Maria');
        expect(
          novo
              ? (_ultimoCadastro?['proprietarioId'])
              : (_ultimaAtualizacao?[platform.FieldPath(['proprietarioId'])]),
          '',
        );
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'altura e peso no ${novo ? "cadastro" : "editar"}: validar e salvar',
      (tester) async {
        await _abrirEdicaoFoto(tester, _Upload(), [], novo: novo);
        final altura = find.widgetWithText(TextFormField, 'Altura (m)');
        final peso = find.widgetWithText(TextFormField, 'Peso (kg)');
        expect(altura.hitTestable(), findsOneWidget);
        expect(peso.hitTestable(), findsOneWidget);
        expect(
          tester.widget<TextFormField>(altura).controller!.text,
          novo ? '' : '1,6',
        );
        expect(
          tester.widget<TextFormField>(peso).controller!.text,
          novo ? '' : '450',
        );
        await tester.enterText(
          find.widgetWithText(TextFormField, 'Nome do cavalo'),
          'Cavalo com medidas',
        );
        final salvar = find.text(
          novo ? 'Cadastrar cavalo' : 'Salvar alterações',
        );
        for (final entrada in ['-1', '0', 'abc', 'NaN']) {
          await tester.enterText(altura, entrada);
          await tester.enterText(peso, entrada);
          await tester.tap(salvar);
          await tester.pumpAndSettle();
          expect(
            find.text('Informe um número maior que zero'),
            findsNWidgets(2),
          );
          expect(tester.takeException(), isNull);
        }
        await tester.enterText(altura, '1,65');
        await tester.enterText(peso, '480.5');
        await tester.tap(salvar);
        await tester.pumpAndSettle();
        expect(
          novo
              ? (_ultimoCadastro?['altura'])
              : (_ultimaAtualizacao?[platform.FieldPath(['altura'])]),
          1.65,
        );
        expect(
          novo
              ? (_ultimoCadastro?['peso'])
              : (_ultimaAtualizacao?[platform.FieldPath(['peso'])]),
          480.5,
        );
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets('permite apagar medidas opcionais na edição', (tester) async {
    await _abrirEdicaoFoto(tester, _Upload(), []);
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Altura (m)'),
      '',
    );
    await tester.enterText(find.widgetWithText(TextFormField, 'Peso (kg)'), '');
    await tester.tap(find.text('Salvar alterações'));
    await tester.pumpAndSettle();
    expect(_ultimaAtualizacao, isNotNull);
    expect(_ultimaAtualizacao?[platform.FieldPath(['altura'])], isNull);
    expect(_ultimaAtualizacao?[platform.FieldPath(['peso'])], isNull);
  });

  for (final existentes in [
    <String>[],
    ['https://example.test/antiga.png', 'https://example.test/extra.png'],
  ]) {
    testWidgets(
      'salva foto principal preservando fotos extras: ${existentes.length}',
      (tester) async {
        final picker = _Picker()..resultado = FilePickerResult([_fotoTeste()]);
        FilePicker.platform = picker;
        final upload = _Upload();
        await _abrirEdicaoFoto(tester, upload, existentes);
        await _escolherFoto(
          tester,
          existentes.isEmpty ? 'Adicionar foto' : 'Trocar foto',
        );
        expect(find.text('Desfazer seleção'), findsOneWidget);
        expect(upload.chamadas, 0);
        expect(_ultimaAtualizacao, isNull);
        expect(find.text('Salvar alterações').hitTestable(), findsOneWidget);
        await tester.tap(find.text('Salvar alterações'));
        await tester.pumpAndSettle();
        expect(upload.chamadas, 1);
        expect(_ultimaAtualizacao?[platform.FieldPath(['fotos'])], [
          'https://example.test/nova.png',
          ...existentes.skip(1),
        ]);
        expect(_ultimaAtualizacao?[platform.FieldPath(['ativo'])], isFalse);
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets(
    'falha de upload mantém edição aberta e permite tentar novamente',
    (tester) async {
      FilePicker.platform = _Picker()
        ..resultado = FilePickerResult([_fotoTeste()]);
      final upload = _Upload()..falhar = true;
      await _abrirEdicaoFoto(tester, upload, []);
      await _escolherFoto(tester, 'Adicionar foto');
      await tester.tap(find.text('Salvar alterações'));
      await tester.pumpAndSettle();
      expect(_ultimaAtualizacao, isNull);
      expect(find.text('Salvar alterações'), findsOneWidget);
      upload.falhar = false;
      await tester.tap(find.text('Salvar alterações'));
      await tester.pumpAndSettle();
      expect(upload.chamadas, 2);
      expect(_ultimaAtualizacao?[platform.FieldPath(['fotos'])], [
        'https://example.test/nova.png',
      ]);
    },
  );

  testWidgets(
    'cancelar escolha ou desfazer seleção preserva foto atual sem upload',
    (tester) async {
      final picker = _Picker();
      FilePicker.platform = picker;
      final upload = _Upload();
      final existentes = ['https://example.test/antiga.png'];
      await _abrirEdicaoFoto(tester, upload, existentes);
      await _escolherFoto(tester, 'Trocar foto');
      expect(find.text('Desfazer seleção'), findsNothing);
      picker.resultado = FilePickerResult([_fotoTeste()]);
      await _escolherFoto(tester, 'Trocar foto');
      await tester.tap(find.text('Desfazer seleção'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Salvar alterações'));
      await tester.pumpAndSettle();
      expect(upload.chamadas, 0);
      expect(_ultimaAtualizacao?[platform.FieldPath(['fotos'])], existentes);
    },
  );

  for (final size in [const Size(1366, 768), const Size(1024, 600)]) {
    testWidgets('detalhes do cavalo sem valores financeiros em $size', (
      tester,
    ) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () =>
                    abrirPopupDetalhesCavalo(context, 'cavalo-teste'),
                child: const Text('Abrir cavalo'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Abrir cavalo'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('Estrela do Haras Exemplo'), findsOneWidget);
      expect(find.text('1,65 m'), findsOneWidget);
      expect(find.text('480,5 kg'), findsOneWidget);
      expect(find.textContaining('R\$'), findsNothing);
      expect(find.text('Resumo financeiro'), findsNothing);
      expect(find.text('Ver despesas'), findsNothing);
      expect(find.text('Ver receitas'), findsNothing);
      for (final state in tester.stateList<ScrollableState>(
        find.byType(Scrollable),
      )) {
        expect(state.position.maxScrollExtent, 0);
      }
      for (final label in ['Editar', 'Ler observações completas']) {
        expect(find.text(label).hitTestable(), findsOneWidget);
      }
      await tester.tap(find.text('Ler observações completas'));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsOneWidget);
      await tester.tap(find.widgetWithText(TextButton, 'Fechar'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Editar'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      // A ficha ampliada rola sem reduzir os campos; o resumo continua compacto.
      expect(find.byType(SingleChildScrollView), findsOneWidget);
      for (final label in ['Salvar alterações', 'Cancelar']) {
        expect(find.text(label).hitTestable(), findsOneWidget);
      }
      final nome = find.widgetWithText(TextFormField, 'Nome do cavalo');
      expect(nome.hitTestable(), findsOneWidget);
      expect(find.text('Estrela do Haras Exemplo'), findsOneWidget);
      await tester.enterText(nome, '');
      await tester.tap(find.text('Salvar alterações'));
      await tester.pumpAndSettle();
      expect(find.text('Campo obrigatório'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.enterText(nome, 'Estrela atualizada');
      _ultimaAtualizacao = null;
      await tester.tap(find.text('Salvar alterações'));
      await tester.pumpAndSettle();
      expect(
        _ultimaAtualizacao?[platform.FieldPath(['nome'])],
        'Estrela atualizada',
      );
      expect(_ultimaAtualizacao?[platform.FieldPath(['ativo'])], isFalse);
      expect(
        _ultimaAtualizacao?[platform.FieldPath(['raca'])],
        'Mangalarga Marchador',
      );
      expect(find.text('Abrir cavalo'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
