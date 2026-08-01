import 'package:flutter/material.dart';

import 'galeria_page_desktop.dart';
import 'galeria_page_mobile.dart';

// =====================================================
// GaleriaPage
// =====================================================
//
// Roteador: decide entre a versão Desktop (com AdminTopBar
// fixa) e Mobile, com base na largura da tela.

class GaleriaPage extends StatelessWidget {
  const GaleriaPage({super.key});

  @override
  Widget build(BuildContext context) {
    final desktop = MediaQuery.of(context).size.width >= 1000;

    return desktop ? const GaleriaPageDesktop() : const GaleriaPageMobile();
  }
}