import 'package:flutter/material.dart';

import 'admin_home_desktop.dart';
import 'admin_home_mobile.dart';

// =====================================================
// AdminHome
// =====================================================
//
// Não é mais uma tela em si — só decide qual das duas
// telas (totalmente separadas) mostrar, com base na
// largura da tela:
//
//   - largura >= 1000  -> AdminHomeDesktop
//   - largura <  1000  -> AdminHomeMobile
//
// As duas vivem em arquivos próprios e não compartilham
// código entre si (cada uma é independente).

class AdminHome extends StatelessWidget {
  const AdminHome({super.key});

  @override
  Widget build(BuildContext context) {
    final desktop = MediaQuery.of(context).size.width >= 1000;

    return desktop ? const AdminHomeDesktop() : const AdminHomeMobile();
  }
}