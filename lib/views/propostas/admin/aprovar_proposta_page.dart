import 'package:flutter/material.dart';

import 'aprovar_proposta_page_desktop.dart';
import 'aprovar_proposta_page_mobile.dart';

// =====================================================
// AprovarPropostaPage
// =====================================================
//
// Roteador: decide entre a versão Desktop (cliente e
// documentos à esquerda, ações à direita) e Mobile (tudo
// empilhado), com base na largura da tela.

class AprovarPropostaPage extends StatelessWidget {
  final String propostaId;

  const AprovarPropostaPage({
    super.key,
    required this.propostaId,
  });

  @override
  Widget build(BuildContext context) {
    final desktop = MediaQuery.of(context).size.width >= 1000;

    return desktop
        ? AprovarPropostaPageDesktop(propostaId: propostaId)
        : AprovarPropostaPageMobile(propostaId: propostaId);
  }
}