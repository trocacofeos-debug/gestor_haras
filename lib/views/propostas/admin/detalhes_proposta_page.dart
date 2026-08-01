import 'package:flutter/material.dart';

import 'detalhes_proposta_page_desktop.dart';
import 'detalhes_proposta_page_mobile.dart';

// =====================================================
// DetalhesPropostaPage
// =====================================================
//
// Roteador: decide entre a versão Desktop (duas colunas)
// e Mobile (uma coluna), com base na largura da tela.

class DetalhesPropostaPage extends StatelessWidget {
  final String propostaId;

  const DetalhesPropostaPage({
    super.key,
    required this.propostaId,
  });

  @override
  Widget build(BuildContext context) {
    final desktop = MediaQuery.of(context).size.width >= 1000;

    return desktop
        ? DetalhesPropostaPageDesktop(propostaId: propostaId)
        : DetalhesPropostaPageMobile(propostaId: propostaId);
  }
}