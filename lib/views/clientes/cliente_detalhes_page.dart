import 'package:flutter/material.dart';
import '../../widgets/app_dialogs.dart';

import '../../models/cliente_model.dart';
import '../../widgets/desktop_window.dart';

import 'cliente_detalhes_page_desktop.dart';
import 'cliente_detalhes_page_mobile.dart';

/// Mantém a lista e sua busca abertas atrás dos detalhes.
Future<void> abrirPopupDetalhesCliente(
  BuildContext context,
  ClienteModel cliente,
) {
  return showAppDialog<void>(
    context: context,
      title: 'Detalhes do cliente',
    builder: (dialogContext) => Dialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1160, maxHeight: 800),
        child: SizedBox(
          width: double.infinity,
          height:
              MediaQuery.sizeOf(dialogContext).height *
              (MediaQuery.sizeOf(dialogContext).width >= 900 ? .92 : .85),
          child: DesktopWindowScope(
            child: ClienteDetalhesPage(cliente: cliente),
          ),
        ),
      ),
    ),
  );
}

// =====================================================
// ClienteDetalhesPage
// =====================================================
//
// Roteador: decide entre a versão Desktop (campos em colunas)
// e Mobile (uma coluna, scroll vertical), com base na
// largura da tela.

class ClienteDetalhesPage extends StatelessWidget {
  final ClienteModel cliente;

  const ClienteDetalhesPage({super.key, required this.cliente});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => constraints.maxWidth >= 900
          ? ClienteDetalhesPageDesktop(cliente: cliente)
          : ClienteDetalhesPageMobile(cliente: cliente),
    );
  }
}


