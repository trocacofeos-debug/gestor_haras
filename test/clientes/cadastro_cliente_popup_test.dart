import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
// Firebase supplies the platform mock used by this regression test.
// ignore: depend_on_referenced_packages
import 'package:firebase_core_platform_interface/test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gestor_haras/models/cliente_model.dart';
import 'package:gestor_haras/views/clientes/cadastro_cliente_page.dart';
import 'package:gestor_haras/widgets/desktop_window.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setupFirebaseCoreMocks();

  setUpAll(() async {
    await Firebase.initializeApp();
  });

  for (final size in [
    const Size(1280, 900),
    const Size(1024, 600),
    const Size(390, 844),
  ]) {
    testWidgets('editar no popup sem erro de layout em $size', (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final cliente = ClienteModel(
        id: 'cliente-teste',
        tipoCliente: TipoCliente.fisica,
        nome: 'Ana',
        sobrenome: 'Silva',
        cpfCnpj: '12345678900',
        telefone: '11999999999',
        dataCadastro: Timestamp.fromMillisecondsSinceEpoch(0),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () => showDialog<void>(
                  context: context,
                  builder: (_) => Dialog(
                    child: DesktopWindowScope(
                      child: Builder(
                        builder: (popupContext) => TextButton(
                          onPressed: () => openDesktopWindow<void>(
                            popupContext,
                            title: 'Editar cliente',
                            builder: (_) =>
                                CadastroClientePage(cliente: cliente),
                          ),
                          child: const Text('Editar'),
                        ),
                      ),
                    ),
                  ),
                ),
                child: const Text('Abrir cliente'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Abrir cliente'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Editar'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('Ana'), findsOneWidget);

      await tester.tap(find.text('Jurídica'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(
        find.widgetWithText(TextFormField, 'Razão Social'),
        findsOneWidget,
      );

      await tester.tap(find.text('Rural'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      // Dispose the form after switching tabs, as happens on cancel/close.
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }
}
