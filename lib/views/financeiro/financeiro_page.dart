import 'package:flutter/material.dart';

import 'financeiro_page_desktop.dart';
import 'financeiro_page_mobile.dart';

// =====================================================
// FinanceiroPage
// =====================================================
//
// Roteador: decide entre a versão Desktop (resumo fixo à
// esquerda + lista rolável à direita) e Mobile (tudo numa
// coluna só), com base na largura da tela.

class FinanceiroPage extends StatelessWidget {
  const FinanceiroPage({super.key});

  @override
  Widget build(BuildContext context) {
    final desktop = MediaQuery.of(context).size.width >= 1000;

    return desktop
        ? const FinanceiroPageDesktop()
        : const FinanceiroPageMobile();
  }
}