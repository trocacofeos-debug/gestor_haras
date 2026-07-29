import 'package:flutter/material.dart';

import 'gerar_contrato_page_desktop.dart';
import 'gerar_contrato_page_mobile.dart';

// =====================================================
// GerarContratoPage
// =====================================================
//
// Roteador: decide entre a versão Desktop (info à
// esquerda, ações à direita) e Mobile (tudo empilhado),
// com base na largura da tela.

class GerarContratoPage extends StatelessWidget {
  final String propostaId;

  const GerarContratoPage({
    super.key,
    required this.propostaId,
  });

  @override
  Widget build(BuildContext context) {
    final desktop = MediaQuery.of(context).size.width >= 1000;

    return desktop
        ? GerarContratoPageDesktop(propostaId: propostaId)
        : GerarContratoPageMobile(propostaId: propostaId);
  }
}