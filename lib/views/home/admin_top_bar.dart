// ignore_for_file: unused_import, deprecated_member_use

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../auth/login_page.dart';
import '../auth/register_page.dart';
import '../clientes/clientes_page.dart';
import '../cadastros/cavalos_list_page.dart';
import '../cadastros/funcionarios_list_page.dart';
import '../cadastros/fornecedores_list_page.dart';
import '../cadastros/cadastro_hub_page.dart';
import '../cadastros/cadastro_cavalo_page.dart';
import '../cadastros/cadastro_funcionario_page.dart';
import '../cadastros/cadastro_fornecedor_page.dart';
import '../financeiro/financeiro_page.dart';
import '../financeiro/nova_conta_page.dart';
import '../propostas/admin/propostas_admin_page.dart';
import '../propostas/admin/nova_proposta_page.dart';
import '../site/cavalos_venda_list_page.dart';
import '../site/galeria_page.dart';
import '../site/noticias_page.dart';
import 'admin_home_desktop.dart';

// =====================================================
// AdminTopBar
// =====================================================
//
// Barra de menu fixa, reutilizada em TODAS as telas do
// desktop (não só na Dashboard). Cada item do dropdown, e
// o botão "Início", trocam a tela atual por completo
// (pushAndRemoveUntil) — assim clicar entre seções pela
// barra nunca empilha telas infinitamente. A navegação
// *dentro* de uma seção (ex: lista -> detalhes) continua
// normal, com botão de voltar funcionando.

class AdminTopBar extends StatelessWidget {
  const AdminTopBar({super.key});

  static const Color corSidebar = Color(0xFF111827);
  static const Color corPrimaria = Color(0xFF4F46E5);

  void _trocarTela(BuildContext context, Widget pagina) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => pagina),
      (route) => false,
    );
  }

  Future<void> _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();

    if (!context.mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: corSidebar,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.15),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
        children: [
          Container(
            width: 26,
            height: 26,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: corPrimaria,
              borderRadius: BorderRadius.circular(7),
            ),
            child: const Text(
              'GH',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 11,
              ),
            ),
          ),
          const SizedBox(width: 10),
          const Text(
            'Gestor Haras',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 13.5,
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            width: 1,
            height: 22,
            color: Colors.white.withOpacity(.15),
          ),
          _botaoSimples(
            context: context,
            titulo: 'Início',
            icon: Icons.home_rounded,
            onTap: () =>
                _trocarTela(context, const AdminHomeDesktop()),
          ),
          _menuDropdown(
            context: context,
            titulo: 'Cadastros',
            itens: [
              _ItemMenu('Novo Cadastro', () => const CadastroHubPage()),
              _ItemMenu('Clientes', () => const ClientesPage()),
              _ItemMenu('Cavalos', () => const CavalosListPage()),
              _ItemMenu('Funcionários', () => const FuncionariosListPage()),
              _ItemMenu('Fornecedores', () => const FornecedoresListPage()),
            ],
          ),
          _menuDropdown(
            context: context,
            titulo: 'Financeiro',
            itens: [
              _ItemMenu('Dívidas', () => const FinanceiroPage()),
              _ItemMenu('Nova Conta', () => const NovaContaPage()),
            ],
          ),
          _menuDropdown(
            context: context,
            titulo: 'Propostas',
            itens: [
              _ItemMenu('Propostas', () => const PropostasAdminPage()),
              _ItemMenu('Nova Proposta', () => const NovaPropostaPage()),
            ],
          ),
          _menuDropdown(
            context: context,
            titulo: 'Site',
            itens: [
              _ItemMenu('Cavalos à Venda', () => const CavalosVendaListPage()),
              _ItemMenu('Galeria', () => const GaleriaPage()),
              _ItemMenu('Notícias', () => const NoticiasPage()),
            ],
          ),
          _menuDropdown(
            context: context,
            titulo: 'Ajuda',
            itens: [
              _ItemMenu('Sair', null, acaoDireta: () => _logout(context)),
            ],
          ),
        ],
      ),
      ),
    );
  }

  Widget _botaoSimples({
    required BuildContext context,
    required String titulo,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          alignment: Alignment.center,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: Colors.white.withOpacity(.85)),
              const SizedBox(width: 6),
              Text(
                titulo,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _menuDropdown({
    required BuildContext context,
    required String titulo,
    required List<_ItemMenu> itens,
  }) {
    return MenuAnchor(
      style: MenuStyle(
        backgroundColor: MaterialStateProperty.all(Colors.white),
        shape: MaterialStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
        ),
      ),
      menuChildren: itens.map((item) {
        return MenuItemButton(
          onPressed: () {
            if (item.acaoDireta != null) {
              item.acaoDireta!();
              return;
            }

            if (item.pagina != null) {
              _trocarTela(context, item.pagina!());
            }
          },
          child: Text(
            item.titulo,
            style: const TextStyle(fontSize: 13.5),
          ),
        );
      }).toList(),
      builder: (context, controller, child) {
        return Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () {
              if (controller.isOpen) {
                controller.close();
              } else {
                controller.open();
              }
            },
            child: Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              alignment: Alignment.center,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    titulo,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 16,
                    color: Colors.white.withOpacity(.6),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// =====================================================
// MODELO SIMPLES PARA UM ITEM DO MENU
// =====================================================

class _ItemMenu {
  final String titulo;
  final Widget Function()? pagina;
  final VoidCallback? acaoDireta;

  const _ItemMenu(
    this.titulo,
    this.pagina, {
    this.acaoDireta,
  });
}