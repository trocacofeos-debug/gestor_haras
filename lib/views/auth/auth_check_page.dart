import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
import '../home/admin_home.dart';
import '../home/cliente_home.dart';
import 'login_page.dart';

class AuthCheckPage extends StatelessWidget {
  const AuthCheckPage({super.key});

  @override
  Widget build(BuildContext context) => StreamBuilder<User?>(
    stream: FirebaseAuth.instance.authStateChanges(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }
      final usuario = snapshot.data;
      if (usuario == null) return const LoginPage();

      return FutureBuilder<SessaoUsuario>(
        future: AuthService().getSessaoUsuario(usuario.uid),
        builder: (context, sessaoSnapshot) {
          if (sessaoSnapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          final sessao =
              sessaoSnapshot.data ?? const SessaoUsuario(tipo: 'cliente');
          sessao.aplicarAcesso();
          return sessao.administrativo
              ? const AdminHome()
              : const ClienteHome();
        },
      );
    },
  );
}
