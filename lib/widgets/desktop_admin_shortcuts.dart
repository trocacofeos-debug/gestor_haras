import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../views/auth/register_page.dart';
import '../views/cadastros/cadastro_cavalo_page.dart';
import '../views/cadastros/cadastro_fornecedor_page.dart';
import '../views/financeiro/nova_conta_page.dart';
import '../views/propostas/admin/nova_proposta_page.dart';
import 'desktop_window.dart';

/// Atalhos globais do painel administrativo no modo desktop.
class DesktopAdminShortcuts extends StatefulWidget {
  const DesktopAdminShortcuts({
    super.key,
    required this.navigatorKey,
    required this.child,
  });

  final GlobalKey<NavigatorState> navigatorKey;
  final Widget child;

  @override
  State<DesktopAdminShortcuts> createState() => _DesktopAdminShortcutsState();
}

class _DesktopAdminShortcutsState extends State<DesktopAdminShortcuts> {
  @override
  void initState() {
    super.initState();
    HardwareKeyboard.instance.addHandler(_capturarAtalho);
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_capturarAtalho);
    super.dispose();
  }

  bool _estaEditandoTexto() {
    final context = FocusManager.instance.primaryFocus?.context;
    if (context == null) return false;

    return context.widget is EditableText ||
        context.findAncestorWidgetOfExactType<EditableText>() != null;
  }

  void _abrir(LogicalKeyboardKey key) {
    final context = widget.navigatorKey.currentState?.overlay?.context;
    if (context == null) return;

    if (key == LogicalKeyboardKey.keyC) {
      openDesktopWindow(
        context,
        title: 'Novo cliente',
        icon: Icons.person_add_alt_1_rounded,
        width: 1120,
        builder: (_) => const RegisterPage(),
      );
      return;
    }

    if (key == LogicalKeyboardKey.keyD) {
      openDesktopWindow(
        context,
        title: 'Cadastrar dívida',
        icon: Icons.account_balance_wallet_rounded,
        width: 1180,
        builder: (_) => const NovaContaPage(),
      );
      return;
    }

    if (key == LogicalKeyboardKey.keyP) {
      openDesktopWindow(
        context,
        title: 'Nova proposta',
        icon: Icons.description_rounded,
        width: 1180,
        builder: (_) => const NovaPropostaPage(),
      );
      return;
    }

    if (key == LogicalKeyboardKey.keyF) {
      openDesktopWindow(
        context,
        title: 'Novo fornecedor',
        icon: Icons.storefront_rounded,
        width: 1120,
        builder: (_) => const CadastroFornecedorPage(),
      );
      return;
    }

    if (key == LogicalKeyboardKey.keyA) {
      openDesktopWindow(
        context,
        title: 'Novo cavalo',
        icon: Icons.pets_rounded,
        width: 1120,
        builder: (_) => const CadastroCavaloPage(),
      );
    }
  }

  bool _capturarAtalho(KeyEvent event) {
    if (!mounted ||
        event is! KeyDownEvent ||
        MediaQuery.sizeOf(context).width < 900 ||
        FirebaseAuth.instance.currentUser == null ||
        _estaEditandoTexto()) {
      return false;
    }

    final keyboard = HardwareKeyboard.instance;
    if (!keyboard.isAltPressed ||
        !keyboard.isShiftPressed ||
        keyboard.isControlPressed ||
        keyboard.isMetaPressed) {
      return false;
    }

    final key = event.logicalKey;
    if (key != LogicalKeyboardKey.keyC &&
        key != LogicalKeyboardKey.keyD &&
        key != LogicalKeyboardKey.keyP &&
        key != LogicalKeyboardKey.keyF &&
        key != LogicalKeyboardKey.keyA) {
      return false;
    }

    _abrir(key);
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
