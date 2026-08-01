import 'package:flutter/material.dart';

import 'register_page_desktop.dart';
import 'register_page_mobile.dart';

// =====================================================
// RegisterPage
// =====================================================
//
// Roteador: decide entre a versão Desktop (card um pouco
// mais largo) e Mobile (igual já era), com base na
// largura da tela.

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    final desktop = MediaQuery.of(context).size.width >= 1000;

    return desktop
        ? const RegisterPageDesktop()
        : const RegisterPageMobile();
  }
}