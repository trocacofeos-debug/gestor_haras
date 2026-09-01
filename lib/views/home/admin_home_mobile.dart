// ignore_for_file: deprecated_member_use

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../services/dashboard_service.dart';

import '../auth/login_page.dart';
import '../clientes/clientes_page.dart';
import '../cadastros/cadastro_hub_page.dart';
import '../cadastros/cavalos_list_page.dart';
import '../cadastros/funcionarios_list_page.dart';
import '../cadastros/fornecedores_list_page.dart';
import '../cadastros/medicamentos_page.dart';
import '../../models/medicamento_model.dart';
import '../site/cavalos_venda_list_page.dart';
import '../site/galeria_page.dart';
import '../site/noticias_page.dart';
import '../financeiro/financeiro_animais_page.dart';
import '../financeiro/relatorios_animais_page.dart';
import '../financeiro/financeiro_page.dart';
import '../financeiro/nova_conta_page.dart';

// =====================================================
// AdminHomeMobile
// =====================================================
//
// Tela exclusiva para celular/tablet estreito: drawer
// lateral (menu hambúrguer) e conteúdo em uma coluna só.
//
// Não compartilha código com AdminHomeDesktop — são duas
// telas independentes.

class AdminHomeMobile extends StatefulWidget {
  const AdminHomeMobile({super.key});

  @override
  State<AdminHomeMobile> createState() => _AdminHomeMobileState();
}

class _AdminHomeMobileState extends State<AdminHomeMobile> {
  final DashboardService service = DashboardService();
  final scaffoldKey = GlobalKey<ScaffoldState>();

  static const Color corSidebar = Color(0xFF111827); // slate-900
  static const Color corPrimaria = Color(0xFF4F46E5); // indigo-600
  static const Color corTextoPrimario = Color(0xFF111827);
  static const Color corTextoSecundario = Color(0xFF6B7280);
  static const Color corFundo = Color(0xFFF3F4F6);
  static const Color corBorda = Color(0xFFE5E7EB);

  int menuSelecionado = 0;

  double recebido = 0;
  double pendente = 0;
  double total = 0;

  @override
  void initState() {
    super.initState();
    carregar();
  }

  Future<void> carregar() async {
    try {
      final data = await service.getResumo();

      if (!mounted) return;

      setState(() {
        recebido = (data['recebido'] ?? 0).toDouble();
        pendente = (data['pendente'] ?? 0).toDouble();
        total = (data['total'] ?? 0).toDouble();
      });
    } catch (e) {
      debugPrint('Erro dashboard: $e');
    }
  }

  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  void abrirTela(Widget pagina, int menu) {
    setState(() {
      menuSelecionado = menu;
    });

    Navigator.push(context, MaterialPageRoute(builder: (_) => pagina));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: corFundo,
      appBar: _header(),
      drawer: _drawer(),
      bottomNavigationBar: NavigationBar(
        selectedIndex: 0,
        onDestinationSelected: (indice) {
          switch (indice) {
            case 0:
              return;
            case 1:
              abrirTela(const CadastroHubPage(), 2);
            case 2:
              abrirTela(const CavalosListPage(), 3);
            case 3:
              abrirTela(const FinanceiroAnimaisPage(), 9);
            case 4:
              scaffoldKey.currentState?.openDrawer();
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Início',
          ),
          NavigationDestination(
            icon: Icon(Icons.add_box_outlined),
            selectedIcon: Icon(Icons.add_box_rounded),
            label: 'Cadastrar',
          ),
          NavigationDestination(
            icon: Icon(Icons.pets_outlined),
            selectedIcon: Icon(Icons.pets_rounded),
            label: 'Animais',
          ),
          NavigationDestination(
            icon: Icon(Icons.account_balance_wallet_outlined),
            selectedIcon: Icon(Icons.account_balance_wallet_rounded),
            label: 'Gestão',
          ),
          NavigationDestination(icon: Icon(Icons.menu_rounded), label: 'Mais'),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: carregar,
        color: corPrimaria,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
                child: _corpoUmaColuna(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =====================================================
  // LAYOUT DE UMA COLUNA
  // =====================================================

  Widget _corpoUmaColuna() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _cabecalhoBoasVindas(),
        const SizedBox(height: 28),
        _tituloSecao('Visão Geral'),
        const SizedBox(height: 14),
        _gridResumo(),
      ],
    );
  }

  Widget _tituloSecao(String texto) {
    return Text(
      texto,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: corTextoPrimario,
        letterSpacing: .2,
      ),
    );
  }

  // =====================================================
  // LOGO (monograma)
  // =====================================================

  Widget _logo({double tamanho = 44}) {
    return Container(
      width: tamanho,
      height: tamanho,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: corPrimaria,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        'GH',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: tamanho * 0.36,
          letterSpacing: .5,
        ),
      ),
    );
  }

  // =====================================================
  // DRAWER
  // =====================================================

  Widget _drawer() {
    return Drawer(
      backgroundColor: corSidebar,
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  _logo(),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Gestor Haras',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          'Sistema Administrativo',
                          style: TextStyle(color: Colors.white54, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(color: Colors.white12, height: 1),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  _drawerItem(
                    'Dashboard',
                    Icons.grid_view_rounded,
                    () => Navigator.pop(context),
                  ),
                  ExpansionTile(
                    key: const PageStorageKey('menu-cadastros-mobile'),
                    iconColor: Colors.white70,
                    collapsedIconColor: Colors.white70,
                    leading: const Icon(
                      Icons.add_box_outlined,
                      color: Colors.white70,
                    ),
                    title: const Text(
                      'Cadastros',
                      style: TextStyle(color: Colors.white),
                    ),
                    children: [
                      _drawerItem(
                        'Novo cadastro',
                        Icons.add_circle_outline_rounded,
                        () {
                          Navigator.pop(context);
                          abrirTela(const CadastroHubPage(), 2);
                        },
                      ),
                      _drawerItem('Clientes', Icons.people_alt_outlined, () {
                        Navigator.pop(context);
                        abrirTela(ClientesPage(), 1);
                      }),
                      _drawerItem('Animais', Icons.pets_outlined, () {
                        Navigator.pop(context);
                        abrirTela(const CavalosListPage(), 3);
                      }),
                      _drawerItem('Funcionários', Icons.badge_outlined, () {
                        Navigator.pop(context);
                        abrirTela(const FuncionariosListPage(), 4);
                      }),
                      _drawerItem(
                        'Fornecedores',
                        Icons.storefront_outlined,
                        () {
                          Navigator.pop(context);
                          abrirTela(const FornecedoresListPage(), 5);
                        },
                      ),
                      _drawerItem('Remédios', Icons.medication_outlined, () {
                        Navigator.pop(context);
                        abrirTela(const MedicamentosPage(), 12);
                      }),
                      _drawerItem('Vacinas', Icons.vaccines_outlined, () {
                        Navigator.pop(context);
                        abrirTela(
                          const MedicamentosPage(tipo: TipoTratamento.vacina),
                          13,
                        );
                      }),
                      _drawerItem('Suplementos', Icons.grass_outlined, () {
                        Navigator.pop(context);
                        abrirTela(
                          const MedicamentosPage(
                            tipo: TipoTratamento.suplemento,
                          ),
                          14,
                        );
                      }),
                    ],
                  ),
                  const Divider(color: Colors.white12, height: 24),
                  ExpansionTile(
                    iconColor: Colors.white70,
                    collapsedIconColor: Colors.white70,
                    leading: const Icon(
                      Icons.account_balance_wallet_outlined,
                      color: Colors.white70,
                    ),
                    title: const Text(
                      'Gestão',
                      style: TextStyle(color: Colors.white),
                    ),
                    children: [
                      _drawerItem('Financeiro', Icons.bar_chart_outlined, () {
                        Navigator.pop(context);
                        abrirTela(const FinanceiroAnimaisPage(), 9);
                      }),
                      _drawerItem(
                        'Relatórios',
                        Icons.picture_as_pdf_outlined,
                        () {
                          Navigator.pop(context);
                          abrirTela(const RelatoriosAnimaisPage(), 15);
                        },
                      ),
                      _drawerItem('Dívidas', Icons.receipt_long_outlined, () {
                        Navigator.pop(context);
                        abrirTela(const FinanceiroPage(), 10);
                      }),
                      _drawerItem(
                        'Cadastrar dívida',
                        Icons.add_card_outlined,
                        () {
                          Navigator.pop(context);
                          abrirTela(const NovaContaPage(), 11);
                        },
                      ),
                    ],
                  ),
                  const Divider(color: Colors.white12, height: 24),
                  _drawerItem(
                    'Cavalos à Venda (site)',
                    Icons.sell_outlined,
                    () {
                      Navigator.pop(context);
                      abrirTela(const CavalosVendaListPage(), 6);
                    },
                  ),
                  _drawerItem(
                    'Galeria (site)',
                    Icons.photo_library_outlined,
                    () {
                      Navigator.pop(context);
                      abrirTela(const GaleriaPage(), 7);
                    },
                  ),
                  _drawerItem('Notícias (site)', Icons.campaign_outlined, () {
                    Navigator.pop(context);
                    abrirTela(const NoticiasPage(), 8);
                  }),
                ],
              ),
            ),
            const Divider(color: Colors.white12, height: 1),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.redAccent),
              title: const Text(
                'Sair',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              onTap: logout,
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _drawerItem(String titulo, IconData icon, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.white70, size: 20),
      title: Text(
        titulo,
        style: const TextStyle(
          fontWeight: FontWeight.w500,
          color: Colors.white,
          fontSize: 14,
        ),
      ),
      onTap: onTap,
    );
  }

  // =====================================================
  // HEADER (topo)
  // =====================================================

  PreferredSizeWidget _header() => AppBar(
    leading: IconButton(
      tooltip: 'Abrir menu',
      onPressed: () => scaffoldKey.currentState?.openDrawer(),
      icon: const Icon(Icons.menu_rounded),
    ),
    title: const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Gestor Haras'),
        Text(
          'Painel administrativo',
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w500,
            color: corTextoSecundario,
          ),
        ),
      ],
    ),
    actions: [
      IconButton(
        tooltip: 'Atualizar dados',
        onPressed: carregar,
        icon: const Icon(Icons.refresh_rounded),
      ),
      const SizedBox(width: 6),
    ],
  );

  // =====================================================
  // CABEÇALHO DE BOAS-VINDAS
  // =====================================================

  Widget _cabecalhoBoasVindas() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF111827), Color(0xFF312E81)],
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final pequeno = constraints.maxWidth < 600;

          final texto = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Gestor Haras',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Sistema completo de gestão administrativa, financeira e comercial.',
                style: TextStyle(
                  color: Colors.white.withOpacity(.65),
                  fontSize: 13.5,
                  height: 1.4,
                ),
              ),
            ],
          );

          if (pequeno) {
            return texto;
          }

          return Row(
            children: [
              Expanded(child: texto),
              _logo(tamanho: 52),
            ],
          );
        },
      ),
    );
  }

  // =====================================================
  // GRID DE RESUMO
  // =====================================================

  Widget _gridResumo() {
    return LayoutBuilder(
      builder: (context, constraints) {
        int colunas = 1;

        if (constraints.maxWidth >= 1000) {
          colunas = 3;
        } else if (constraints.maxWidth >= 600) {
          colunas = 2;
        }

        final cards = [
          _cardResumo(
            'Recebido',
            'R\$ ${recebido.toStringAsFixed(2)}',
            Icons.check_circle_outline,
            const Color(0xFF059669),
          ),
          _cardResumo(
            'Pendente',
            'R\$ ${pendente.toStringAsFixed(2)}',
            Icons.error_outline,
            const Color(0xFFD97706),
          ),
          _cardResumo(
            'Total',
            'R\$ ${total.toStringAsFixed(2)}',
            Icons.account_balance_wallet_outlined,
            const Color(0xFF334155),
          ),
        ];

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: cards.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: colunas,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            childAspectRatio: constraints.maxWidth < 600 ? 2.25 : 1.65,
          ),
          itemBuilder: (_, index) => cards[index],
        );
      },
    );
  }

  Widget _cardResumo(String titulo, String valor, IconData icon, Color cor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: corBorda),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: cor.withOpacity(.10),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: cor, size: 18),
          ),
          const Spacer(),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              valor,
              style: const TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.w700,
                color: corTextoPrimario,
              ),
            ),
          ),
          const SizedBox(height: 3),
          Text(
            titulo.toUpperCase(),
            style: const TextStyle(
              color: corTextoSecundario,
              fontWeight: FontWeight.w600,
              fontSize: 11,
              letterSpacing: .4,
            ),
          ),
        ],
      ),
    );
  }
}
