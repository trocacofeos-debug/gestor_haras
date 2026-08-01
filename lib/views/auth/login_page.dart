import 'package:flutter/material.dart';

import 'login_page_desktop.dart';
import 'login_page_mobile.dart';

// =====================================================
// LoginPage
// =====================================================
//
// Roteador: decide entre a versão Desktop e Mobile, com
// base na largura da tela. O card de login já é
// centralizado com largura máxima (430px), então o
// visual é o mesmo nos dois — a separação existe pra
// manter consistência com o resto do app e facilitar
// ajustes futuros específicos de cada plataforma.

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final desktop = MediaQuery.of(context).size.width >= 1000;

    return desktop ? const LoginPageDesktop() : const LoginPageMobile();
  }
}