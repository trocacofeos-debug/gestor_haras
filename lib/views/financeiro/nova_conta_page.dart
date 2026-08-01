import 'package:flutter/material.dart';

import 'nova_conta_page_desktop.dart';
import 'nova_conta_page_mobile.dart';

// =====================================================
// NovaContaPage
// =====================================================
//
// Roteador: decide entre a versão Desktop (duas colunas)
// e Mobile (uma coluna), com base na largura da tela.
// Repassa os parâmetros opcionais de cliente pré-selecionado
// para a versão escolhida.

class NovaContaPage extends StatelessWidget {
  final String? clienteIdInicial;

  final String? clienteNomeInicial;

  const NovaContaPage({
    super.key,
    this.clienteIdInicial,
    this.clienteNomeInicial,
  });

  @override
  Widget build(BuildContext context) {
    final desktop = MediaQuery.of(context).size.width >= 1000;

    return desktop
        ? NovaContaPageDesktop(
            clienteIdInicial: clienteIdInicial,
            clienteNomeInicial: clienteNomeInicial,
          )
        : NovaContaPageMobile(
            clienteIdInicial: clienteIdInicial,
            clienteNomeInicial: clienteNomeInicial,
          );
  }
}