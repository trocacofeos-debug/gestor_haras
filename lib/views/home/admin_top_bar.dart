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
import '../../widgets/desktop_window.dart';

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

  static const Color corSidebar = Color(0xFF0F172A);
  static const Color corPrimaria = Color(0xFF4F46E5);

  void _trocarTela(BuildContext context, Widget pagina) {
    openDesktopWindow(
      context,
      title: _tituloDaPagina(pagina),
      icon: _iconeDaPagina(pagina),
      builder: (_) => pagina,
    );
  }

  String _tituloDaPagina(Widget pagina) {
    if (pagina is ClientesPage) return 'Clientes';
    if (pagina is CavalosListPage) return 'Cavalos';
    if (pagina is FuncionariosListPage) return 'Funcionários';
    if (pagina is FornecedoresListPage) return 'Fornecedores';
    if (pagina is CadastroHubPage) return 'Novo cadastro';
    if (pagina is FinanceiroPage) return 'Financeiro e dívidas';
    if (pagina is NovaContaPage) return 'Nova conta';
    if (pagina is PropostasAdminPage) return 'Propostas';
    if (pagina is NovaPropostaPage) return 'Nova proposta';
    if (pagina is CavalosVendaListPage) return 'Cavalos à venda';
    if (pagina is GaleriaPage) return 'Galeria';
    if (pagina is NoticiasPage) return 'Notícias';
    return 'Gestor Haras';
  }

  IconData _iconeDaPagina(Widget pagina) {
    if (pagina is ClientesPage) return Icons.people_alt_rounded;
    if (pagina is CavalosListPage) return Icons.pets_rounded;
    if (pagina is FuncionariosListPage) return Icons.badge_rounded;
    if (pagina is FornecedoresListPage) return Icons.storefront_rounded;
    if (pagina is FinanceiroPage || pagina is NovaContaPage) {
      return Icons.account_balance_wallet_rounded;
    }
    if (pagina is PropostasAdminPage || pagina is NovaPropostaPage) {
      return Icons.description_rounded;
    }
    return Icons.web_asset_rounded;
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
    if (DesktopWindowScope.isInside(context)) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F172A), Color(0xFF172033)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF6366F1), Color(0xFF4338CA)],
                  ),
                  borderRadius: BorderRadius.circular(9),
                  boxShadow: const [
                    BoxShadow(color: Color(0x554F46E5), blurRadius: 10),
                  ],
                ),
                child: const Text(
                  'GH',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'GESTOR HARAS',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  letterSpacing: .6,
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
                onTap: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const AdminHomeDesktop()),
                    (route) => false,
                  );
                },
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
                  _ItemMenu(
                    'Cavalos à Venda',
                    () => const CavalosVendaListPage(),
                  ),
                  _ItemMenu('Galeria', () => const GaleriaPage()),
                  _ItemMenu('Notícias', () => const NoticiasPage()),
                ],
              ),
              Container(
                margin: const EdgeInsets.only(left: 12, right: 4),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(.08),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: Colors.white.withOpacity(.10)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Color(0xFF34D399),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'ADMIN',
                      style: TextStyle(
                        color: Color(0xFFCBD5E1),
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: .5,
                      ),
                    ),
                  ],
                ),
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
          height: 56,
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
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
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
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
          child: Text(item.titulo, style: const TextStyle(fontSize: 13.5)),
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
              height: 56,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              alignment: Alignment.center,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    titulo,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
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

  const _ItemMenu(this.titulo, this.pagina, {this.acaoDireta});
}
