import 'package:flutter/material.dart';

import 'cavalos_list_page_desktop.dart';
import 'cavalos_list_page_mobile.dart';

// =====================================================
// CavalosListPage
// =====================================================
//
// Roteador: decide entre a versão Desktop (tabela +
// popup) e Mobile (lista compacta), com base na largura da tela.
// As duas telas são independentes entre si.

class CavalosListPage extends StatelessWidget {
  const CavalosListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final desktop = MediaQuery.of(context).size.width >= 1000;

    return desktop
        ? const CavalosListPageDesktop()
        : const CavalosListPageMobile();
  }
}
