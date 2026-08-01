import 'package:flutter/material.dart';

import 'clientes_page_desktop.dart';
import 'clientes_page_mobile.dart';

// =====================================================
// ClientesPage
// =====================================================
//
// Roteador: decide entre a versão Desktop (tabela +
// popup) e Mobile (cards), com base na largura da tela.
// As duas são telas independentes, sem código
// compartilhado entre si.

class ClientesPage extends StatelessWidget {
  const ClientesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final desktop = MediaQuery.of(context).size.width >= 1000;

    return desktop
        ? const ClientesPageDesktop()
        : const ClientesPageMobile();
  }
}