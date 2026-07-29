import 'package:flutter/material.dart';

import 'nova_proposta_page_desktop.dart';
import 'nova_proposta_page_mobile.dart';

// =====================================================
// NovaPropostaPage
// =====================================================
//
// Roteador: decide entre a versão Desktop (duas colunas)
// e Mobile (uma coluna), com base na largura da tela.

class NovaPropostaPage extends StatelessWidget {
  const NovaPropostaPage({super.key});

  @override
  Widget build(BuildContext context) {
    final desktop = MediaQuery.of(context).size.width >= 1000;

    return desktop
        ? const NovaPropostaPageDesktop()
        : const NovaPropostaPageMobile();
  }
}