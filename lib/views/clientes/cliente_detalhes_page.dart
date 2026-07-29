import 'package:flutter/material.dart';

import '../../models/cliente_model.dart';

import 'cliente_detalhes_page_desktop.dart';
import 'cliente_detalhes_page_mobile.dart';

// =====================================================
// ClienteDetalhesPage
// =====================================================
//
// Roteador: decide entre a versão Desktop (duas colunas)
// e Mobile (uma coluna, scroll vertical), com base na
// largura da tela.

class ClienteDetalhesPage extends StatelessWidget {
  final ClienteModel cliente;

  const ClienteDetalhesPage({
    super.key,
    required this.cliente,
  });

  @override
  Widget build(BuildContext context) {
    final desktop = MediaQuery.of(context).size.width >= 1000;

    return desktop
        ? ClienteDetalhesPageDesktop(cliente: cliente)
        : ClienteDetalhesPageMobile(cliente: cliente);
  }
}