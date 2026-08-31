import 'package:cloud_firestore/cloud_firestore.dart';
// ignore: depend_on_referenced_packages
import 'package:cloud_firestore_platform_interface/cloud_firestore_platform_interface.dart'
    as platform;
import 'package:firebase_core/firebase_core.dart';
// ignore: depend_on_referenced_packages
import 'package:firebase_core_platform_interface/test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gestor_haras/models/cliente_model.dart';
import 'package:gestor_haras/views/clientes/cliente_detalhes_page.dart';

class _Firestore extends platform.FirebaseFirestorePlatform {
  @override
  platform.FirebaseFirestorePlatform delegateFor({
    required FirebaseApp app,
    required String databaseId,
  }) => this;

  @override
  platform.CollectionReferencePlatform collection(String collectionPath) =>
      _Collection(this, collectionPath);
}

class _Collection extends platform.CollectionReferencePlatform {
  _Collection(super.firestore, super.path) {
    parameters['where'] = <List<dynamic>>[];
    parameters['orderBy'] = <List<dynamic>>[];
  }

  @override
  platform.QueryPlatform where(Iterable<List<dynamic>> conditions) => this;

  @override
  Stream<platform.QuerySnapshotPlatform> snapshots({
    bool includeMetadataChanges = false,
    required platform.ListenSource listenSource,
  }) {
    return Stream.value(
      platform.QuerySnapshotPlatform(
        [
          platform.DocumentSnapshotPlatform(
            firestore,
            'dividas/teste',
            {'valorTotal': 123456.78},
            platform.PigeonSnapshotMetadata(
              hasPendingWrites: false,
              isFromCache: true,
            ),
          ),
        ],
        [],
        platform.SnapshotMetadataPlatform(false, true),
      ),
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setupFirebaseCoreMocks();
  setUpAll(() async {
    await Firebase.initializeApp();
    platform.FirebaseFirestorePlatform.instance = _Firestore();
  });

  for (final size in [const Size(1366, 768), const Size(1024, 600)]) {
    for (final tipo in TipoCliente.values) {
      testWidgets('detalhes de $tipo cabem em $size sem rolagem', (
        tester,
      ) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final cliente = ClienteModel(
          id: 'cliente-teste',
          tipoCliente: tipo,
          nome: 'Ana Carolina',
          sobrenome: 'Ferreira da Silva',
          razaoSocial: 'Haras Exemplo Comércio e Criação de Cavalos Ltda.',
          nomeFantasia: 'Haras Exemplo',
          nomeHaras: 'Haras Exemplo',
          idRural: '123456789',
          telefone: '(11) 99999-9999',
          cpfCnpj: '12.345.678/0001-90',
          email: 'contato.financeiro@harasexemplo.com.br',
          endereco: 'Avenida dos Criadores de Cavalos',
          numero: '1200',
          complemento: 'Bloco administrativo, sala 25',
          cep: '12345-678',
          cidade: 'São José dos Campos',
          estado: 'SP',
          enderecoHaras:
              'Estrada Municipal dos Criadores, km 45, Fazenda Exemplo',
          dataCadastro: Timestamp.fromMillisecondsSinceEpoch(0),
        );
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) => Scaffold(
                body: TextButton(
                  onPressed: () => abrirPopupDetalhesCliente(context, cliente),
                  child: const Text('Abrir cliente'),
                ),
              ),
            ),
          ),
        );
        await tester.tap(find.text('Abrir cliente'));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(find.text('Situação Financeira'), findsOneWidget);

        // Financial data loading/revealing must not push the shortcuts out of view.
        await tester.tap(find.text('Situação Financeira'));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        final popup = tester.getRect(find.byType(Dialog));
        for (final label in ['Editar', 'Financeiro', 'Propostas']) {
          final rect = tester.getRect(find.text(label));
          expect(popup.contains(rect.topLeft), isTrue);
          expect(popup.contains(rect.bottomRight), isTrue);
          expect(find.text(label).hitTestable(), findsOneWidget);
        }
        for (final state in tester.stateList<ScrollableState>(
          find.byType(Scrollable),
        )) {
          expect(state.position.maxScrollExtent, 0);
        }
        await tester.tap(find.byTooltip('Fechar'));
        await tester.pumpAndSettle();
        expect(find.text('Abrir cliente'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }
  }
}
