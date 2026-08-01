import 'package:flutter/material.dart';

import 'cadastro_hub_page_desktop.dart';
import 'cadastro_hub_page_mobile.dart';

// =====================================================
// CadastroHubPage
// =====================================================
//
// Roteador: decide entre a versão Desktop (cards em grid,
// conteúdo centralizado) e Mobile (lista vertical), com
// base na largura da tela.

class CadastroHubPage extends StatelessWidget {
  const CadastroHubPage({super.key});

  @override
  Widget build(BuildContext context) {
    final desktop = MediaQuery.of(context).size.width >= 1000;

    return desktop
        ? const CadastroHubPageDesktop()
        : const CadastroHubPageMobile();
  }
}