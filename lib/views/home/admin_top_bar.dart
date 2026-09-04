// ignore_for_file: unused_import, deprecated_member_use

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../auth/login_page.dart';
import '../animais/acompanhamento_animais_page.dart';
import '../clientes/clientes_page.dart';
import '../cadastros/cavalos_list_page.dart';
import '../cadastros/funcionarios_list_page.dart';
import '../cadastros/fornecedores_list_page.dart';
import '../cadastros/cadastro_cavalo_page.dart';
import '../cadastros/cadastro_funcionario_page.dart';
import '../cadastros/cadastro_fornecedor_page.dart';
import '../cadastros/medicamentos_page.dart';
import '../cadastros/lancamentos_page.dart';
import '../cadastros/produtos_page.dart';
import '../cadastros/permissoes_funcionarios_page.dart';
import '../financeiro/financeiro_page.dart';
import '../financeiro/financeiro_animais_page.dart';
import '../financeiro/financeiro_geral_page.dart';
import '../financeiro/relatorios_animais_page.dart';
import '../financeiro/nova_conta_page.dart';
import '../propostas/admin/propostas_admin_page.dart';
import '../propostas/admin/nova_proposta_page.dart';
import '../site/cavalos_venda_list_page.dart';
import '../site/galeria_page.dart';
import '../site/noticias_page.dart';
import 'admin_home_desktop.dart';
import '../../widgets/desktop_window.dart';
import '../../models/permissao_acesso.dart';

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
  const AdminTopBar({super.key, this.mostrarInicio = true});

  final bool mostrarInicio;

  static const Color corSidebar = Color(0xFF0F172A);
  static const Color corPrimaria = Color(0xFF4F46E5);

  void _trocarTela(BuildContext context, Widget pagina) {
    final modulo = _moduloDaPagina(pagina);
    if (modulo != null && !ControleAcesso.pode(modulo)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Você não tem acesso a este módulo.')),
      );
      return;
    }
    openDesktopWindow(
      context,
      title: _tituloDaPagina(pagina),
      icon: _iconeDaPagina(pagina),
      builder: (_) => pagina,
    );
  }

  ModuloAcesso? _moduloDaPagina(Widget pagina) {
    if (pagina is ClientesPage) return ModuloAcesso.clientes;
    if (pagina is CavalosListPage) return ModuloAcesso.animais;
    if (pagina is AcompanhamentoAnimaisPage) return ModuloAcesso.animais;
    if (pagina is FuncionariosListPage) return ModuloAcesso.funcionarios;
    if (pagina is FornecedoresListPage) return ModuloAcesso.fornecedores;
    if (pagina is ProdutosPage) return ModuloAcesso.produtos;
    if (pagina is FinanceiroPage ||
        pagina is FinanceiroGeralPage ||
        pagina is FinanceiroAnimaisPage ||
        pagina is RelatoriosAnimaisPage ||
        pagina is NovaContaPage ||
        pagina is LancamentosPage ||
        pagina is MedicamentosPage) {
      return ModuloAcesso.gestao;
    }
    if (pagina is PropostasAdminPage || pagina is NovaPropostaPage) {
      return ModuloAcesso.propostas;
    }
    if (pagina is PermissoesFuncionariosPage) return null;
    if (pagina is CavalosVendaListPage ||
        pagina is GaleriaPage ||
        pagina is NoticiasPage) {
      return ModuloAcesso.site;
    }
    return null;
  }

  String _tituloDaPagina(Widget pagina) {
    if (pagina is ClientesPage) return 'Clientes';
    if (pagina is CavalosListPage) return 'Animais';
    if (pagina is AcompanhamentoAnimaisPage) return 'Animais';
    if (pagina is FuncionariosListPage) return 'Funcionários';
    if (pagina is FornecedoresListPage) return 'Fornecedores';
    if (pagina is MedicamentosPage) return pagina.titulo;
    if (pagina is LancamentosPage) return 'Lançamentos';
    if (pagina is ProdutosPage) return pagina.titulo;
    if (pagina is FinanceiroPage) return 'Dívidas';
    if (pagina is FinanceiroGeralPage) return 'Financeiro';
    if (pagina is FinanceiroAnimaisPage) return 'Financeiro';
    if (pagina is RelatoriosAnimaisPage) return 'Relatórios';
    if (pagina is NovaContaPage) return 'Cadastrar dívida';
    if (pagina is PropostasAdminPage) return 'Propostas';
    if (pagina is PermissoesFuncionariosPage) return 'Permissões';
    if (pagina is NovaPropostaPage) return 'Nova proposta';
    if (pagina is CavalosVendaListPage) return 'Cavalos à venda';
    if (pagina is GaleriaPage) return 'Galeria';
    if (pagina is NoticiasPage) return 'Notícias';
    return 'Gestor Haras';
  }

  IconData _iconeDaPagina(Widget pagina) {
    if (pagina is ClientesPage) return Icons.people_alt_rounded;
    if (pagina is CavalosListPage) return Icons.pets_rounded;
    if (pagina is AcompanhamentoAnimaisPage) return Icons.pets_rounded;
    if (pagina is FuncionariosListPage) return Icons.badge_rounded;
    if (pagina is FornecedoresListPage) return Icons.storefront_rounded;
    if (pagina is MedicamentosPage) return pagina.icone;
    if (pagina is LancamentosPage) return Icons.playlist_add_check_rounded;
    if (pagina is ProdutosPage) return pagina.icone;
    if (pagina is FinanceiroPage ||
        pagina is FinanceiroGeralPage ||
        pagina is FinanceiroAnimaisPage ||
        pagina is RelatoriosAnimaisPage ||
        pagina is NovaContaPage) {
      return Icons.account_balance_wallet_rounded;
    }
    if (pagina is PropostasAdminPage || pagina is NovaPropostaPage) {
      return Icons.description_rounded;
    }
    if (pagina is PermissoesFuncionariosPage) {
      return Icons.admin_panel_settings_outlined;
    }
    return Icons.web_asset_rounded;
  }

  Future<void> _logout(BuildContext context) async {
    ControleAcesso.limpar();
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
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
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
            if (mostrarInicio && ControleAcesso.pode(ModuloAcesso.dashboard))
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
            if ([
              ModuloAcesso.clientes,
              ModuloAcesso.animais,
              ModuloAcesso.funcionarios,
              ModuloAcesso.fornecedores,
              ModuloAcesso.produtos,
            ].any(ControleAcesso.pode))
              _menuDropdown(
                context: context,
                titulo: 'Cadastros',
                itens: [
                  if (ControleAcesso.pode(ModuloAcesso.clientes))
                    _ItemMenu('Clientes', () => const ClientesPage()),
                  if (ControleAcesso.pode(ModuloAcesso.animais))
                    _ItemMenu('Animais', () => const CavalosListPage()),
                  if (ControleAcesso.pode(ModuloAcesso.funcionarios))
                    _ItemMenu(
                      'Funcionários',
                      () => const FuncionariosListPage(),
                    ),
                  if (ControleAcesso.pode(ModuloAcesso.fornecedores))
                    _ItemMenu(
                      'Fornecedores',
                      () => const FornecedoresListPage(),
                    ),
                  if (ControleAcesso.pode(ModuloAcesso.produtos))
                    _ItemMenu('Produtos', () => const ProdutosPage()),
                ],
              ),
            if (ControleAcesso.pode(ModuloAcesso.gestao))
              _menuDropdown(
                context: context,
                titulo: 'Gestão',
                itens: [
                  _ItemMenu('Financeiro', () => const FinanceiroGeralPage()),
                  _ItemMenu('Lançamentos', () => const LancamentosPage()),
                  _ItemMenu('Relatórios', () => const RelatoriosAnimaisPage()),
                  _ItemMenu('Dívidas', () => const FinanceiroPage()),
                  _ItemMenu('Cadastrar dívida', () => const NovaContaPage()),
                ],
              ),
            if (ControleAcesso.pode(ModuloAcesso.animais))
              _botaoSimples(
                context: context,
                titulo: 'Animais',
                icon: Icons.pets_rounded,
                onTap: () =>
                    _trocarTela(context, const AcompanhamentoAnimaisPage()),
              ),
            if (ControleAcesso.pode(ModuloAcesso.propostas))
              _menuDropdown(
                context: context,
                titulo: 'Propostas',
                itens: [
                  _ItemMenu('Propostas', () => const PropostasAdminPage()),
                  _ItemMenu('Nova Proposta', () => const NovaPropostaPage()),
                ],
              ),
            if (ControleAcesso.acessoTotal)
              _botaoSimples(
                context: context,
                titulo: 'Permissões',
                icon: Icons.admin_panel_settings_outlined,
                onTap: () =>
                    _trocarTela(context, const PermissoesFuncionariosPage()),
              ),
            if (ControleAcesso.pode(ModuloAcesso.site))
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
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
                  Text(
                    ControleAcesso.acessoTotal ? 'ADMIN' : 'FUNCIONÁRIO',
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
            _botaoSimples(
              context: context,
              titulo: 'Sair',
              icon: Icons.logout_rounded,
              onTap: () => _logout(context),
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
            _trocarTela(context, item.pagina());
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
  final Widget Function() pagina;

  const _ItemMenu(this.titulo, this.pagina);
}
