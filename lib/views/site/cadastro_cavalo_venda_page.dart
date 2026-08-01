import 'package:flutter/material.dart';

import '../../models/cavalo_venda_model.dart';
import 'cadastro_cavalo_venda_page_desktop.dart';
import 'cadastro_cavalo_venda_page_mobile.dart';

// =====================================================
// CadastroCavaloVendaPage
// =====================================================
//
// Roteador: decide entre a versão Desktop (com AdminTopBar
// fixa e formulário centralizado) e Mobile, com base na
// largura da tela.

class CadastroCavaloVendaPage extends StatelessWidget {
  final CavaloVendaModel? cavaloParaEditar;

  const CadastroCavaloVendaPage({super.key, this.cavaloParaEditar});

  @override
  Widget build(BuildContext context) {
    final desktop = MediaQuery.of(context).size.width >= 1000;

    return desktop
        ? CadastroCavaloVendaPageDesktop(cavaloParaEditar: cavaloParaEditar)
        : CadastroCavaloVendaPageMobile(cavaloParaEditar: cavaloParaEditar);
  }
}