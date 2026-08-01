import 'package:flutter/material.dart';

import 'funcionarios_list_page_desktop.dart';
import 'funcionarios_list_page_mobile.dart';

// =====================================================
// FuncionariosListPage
// =====================================================
//
// Roteador: decide entre a versão Desktop (tabela +
// popup) e Mobile (lista), com base na largura da tela.

class FuncionariosListPage extends StatelessWidget {
  const FuncionariosListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final desktop = MediaQuery.of(context).size.width >= 1000;

    return desktop
        ? const FuncionariosListPageDesktop()
        : const FuncionariosListPageMobile();
  }
}