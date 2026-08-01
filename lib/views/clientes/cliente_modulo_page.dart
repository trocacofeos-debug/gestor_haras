import 'package:flutter/material.dart';

import '../../models/cliente_model.dart';

import 'cliente_modulo_page_desktop.dart';
import 'cliente_modulo_page_mobile.dart';

// =====================================================
// ClienteModuloPage
// =====================================================
//
// Roteador: decide entre a versão Desktop (conteúdo
// centralizado, largura máxima 900px) e Mobile (largura
// total), com base na largura da tela.

class ClienteModuloPage extends StatelessWidget {
  final ClienteModel cliente;

  final String modulo;

  const ClienteModuloPage({
    super.key,
    required this.cliente,
    required this.modulo,
  });

  @override
  Widget build(BuildContext context) {
    final desktop = MediaQuery.of(context).size.width >= 1000;

    return desktop
        ? ClienteModuloPageDesktop(cliente: cliente, modulo: modulo)
        : ClienteModuloPageMobile(cliente: cliente, modulo: modulo);
  }
}