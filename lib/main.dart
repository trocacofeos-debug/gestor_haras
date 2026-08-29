import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';

// AUTH
import 'views/auth/login_page.dart';
import 'views/auth/auth_check_page.dart';

// HOME
import 'views/home/admin_home.dart';
import 'views/home/cliente_home.dart';

// PROPOSTAS
import 'views/propostas/admin/propostas_admin_page.dart';
import 'views/propostas/admin/nova_proposta_page.dart';

import 'views/propostas/cliente/minhas_propostas_page.dart';
import 'views/propostas/cliente/clicksign_signature_page.dart';

import 'widgets/desktop_app_frame.dart';
import 'widgets/desktop_admin_shortcuts.dart';

final appNavigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const GestorHarasApp());
}

class GestorHarasApp extends StatelessWidget {
  const GestorHarasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Gestor Haras",

      navigatorKey: appNavigatorKey,

      debugShowCheckedModeBanner: false,

      builder: (context, child) => DesktopAdminShortcuts(
        navigatorKey: appNavigatorKey,
        child: DesktopAppFrame(child: child ?? const SizedBox.shrink()),
      ),

      theme: ThemeData(
        useMaterial3: true,

        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1565C0)),

        scaffoldBackgroundColor: const Color(0xffF4F6FA),

        appBarTheme: const AppBarTheme(
          centerTitle: true,

          elevation: 0,

          backgroundColor: Colors.white,

          foregroundColor: Colors.black,
        ),

        inputDecorationTheme: InputDecorationTheme(
          filled: true,

          fillColor: Colors.white,

          labelStyle: const TextStyle(color: Color(0xFF475569)),

          hintStyle: const TextStyle(color: Color(0xFF94A3B8)),

          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),

            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
          ),

          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
          ),

          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFF4F46E5), width: 1.6),
          ),

          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFDC2626)),
          ),
        ),

        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 0,
          shadowColor: const Color(0x140F172A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
        ),

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),

        dividerTheme: const DividerThemeData(
          color: Color(0xFFE2E8F0),
          thickness: 1,
          space: 1,
        ),
      ),

      initialRoute: "/auth-check",

      routes: {
        // ==============================
        // AUTH
        // ==============================
        "/auth-check": (context) => const AuthCheckPage(),

        "/login": (context) => const LoginPage(),

        // ==============================
        // HOME
        // ==============================
        "/admin": (context) => const AdminHome(),

        "/cliente": (context) => const ClienteHome(),

        // ==============================
        // PROPOSTAS ADMIN
        // ==============================
        "/propostas-admin": (context) => const PropostasAdminPage(),

        "/nova-proposta": (context) => const NovaPropostaPage(),

        // ==============================
        // PROPOSTAS CLIENTE
        // ==============================
        "/propostas-cliente": (context) => const PropostasClientePage(),

        // ==============================
        // ASSINATURA CONTRATO
        // ==============================
        "/assinatura-contrato": (context) {
          final args = ModalRoute.of(context)?.settings.arguments;

          if (args == null || args is! String) {
            return const Scaffold(
              body: Center(child: Text("Proposta inválida")),
            );
          }

          return ClicksignSignaturePage(propostaId: args);
        },

        // ==============================
        // NOVO CAVALO
        // ==============================
        //
        // Removida: NovoCavaloPage não existe no
        // projeto. O cadastro de cavalo agora é feito
        // via CadastroCavaloPage (menu "Cadastro" do admin).
      },

      onUnknownRoute: (settings) {
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text("Página não encontrada")),
          ),
        );
      },
    );
  }
}
