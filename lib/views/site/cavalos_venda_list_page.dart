import 'package:flutter/material.dart';

import 'cavalos_venda_list_page_desktop.dart';
import 'cavalos_venda_list_page_mobile.dart';

// =====================================================
// CavalosVendaListPage
// =====================================================
//
// Roteador: decide entre a versão Desktop (com AdminTopBar
// fixa) e Mobile, com base na largura da tela.

class CavalosVendaListPage extends StatelessWidget {
  const CavalosVendaListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final desktop = MediaQuery.of(context).size.width >= 1000;

    return desktop
        ? const CavalosVendaListPageDesktop()
        : const CavalosVendaListPageMobile();
  }
}