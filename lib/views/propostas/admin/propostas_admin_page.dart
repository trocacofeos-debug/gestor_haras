import 'package:flutter/material.dart';

import 'propostas_admin_page_desktop.dart';
import 'propostas_admin_page_mobile.dart';

// =====================================================
// PropostasAdminPage
// =====================================================
//
// Roteador: decide entre a versão Desktop (cards em grid
// flexível via Wrap) e Mobile (lista vertical), com base
// na largura da tela.

class PropostasAdminPage extends StatelessWidget {
  const PropostasAdminPage({super.key});

  @override
  Widget build(BuildContext context) {
    final desktop = MediaQuery.of(context).size.width >= 1000;

    return desktop
        ? const PropostasAdminPageDesktop()
        : const PropostasAdminPageMobile();
  }
}