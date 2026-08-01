import 'package:flutter/material.dart';

import 'noticias_page_desktop.dart';
import 'noticias_page_mobile.dart';

// =====================================================
// NoticiasPage
// =====================================================
//
// Roteador: decide entre a versão Desktop (com AdminTopBar
// fixa) e Mobile, com base na largura da tela.

class NoticiasPage extends StatelessWidget {
  const NoticiasPage({super.key});

  @override
  Widget build(BuildContext context) {
    final desktop = MediaQuery.of(context).size.width >= 1000;

    return desktop ? const NoticiasPageDesktop() : const NoticiasPageMobile();
  }
}