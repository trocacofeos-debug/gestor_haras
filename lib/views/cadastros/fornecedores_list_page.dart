import 'package:flutter/material.dart';

import 'fornecedores_list_page_desktop.dart';
import 'fornecedores_list_page_mobile.dart';

// =====================================================
// FornecedoresListPage
// =====================================================
//
// Roteador: decide entre a versão Desktop (tabela +
// popup) e Mobile (lista), com base na largura da tela.

class FornecedoresListPage extends StatelessWidget {
  const FornecedoresListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final desktop = MediaQuery.of(context).size.width >= 1000;

    return desktop
        ? const FornecedoresListPageDesktop()
        : const FornecedoresListPageMobile();
  }
}