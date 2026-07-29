// ignore_for_file: deprecated_member_use

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../services/dashboard_service.dart';

import '../auth/login_page.dart';
import '../auth/register_page.dart';
import '../clientes/clientes_page.dart';
import '../clientes/cliente_detalhes_page.dart';
import '../../models/cliente_model.dart';
import '../cadastros/cadastro_hub_page.dart';
import '../cadastros/cavalos_list_page.dart';
import '../cadastros/funcionarios_list_page.dart';
import '../cadastros/fornecedores_list_page.dart';
import '../cadastros/cadastro_cavalo_page.dart';
import '../cadastros/cadastro_funcionario_page.dart';
import '../cadastros/cadastro_fornecedor_page.dart';

class AdminHome extends StatefulWidget {
  const AdminHome({super.key});

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  final DashboardService service = DashboardService();

  // Paleta profissional (slate + indigo), substitui o tema
  // marrom/farm anterior.
  static const Color corSidebar = Color(0xFF111827); // slate-900
  static const Color corSidebarAtivo = Color(0xFF1F2937); // slate-800
  static const Color corPrimaria = Color(0xFF4F46E5); // indigo-600
  static const Color corTextoPrimario = Color(0xFF111827);
  static const Color corTextoSecundario = Color(0xFF6B7280);
  static const Color corFundo = Color(0xFFF3F4F6);
  static const Color corBorda = Color(0xFFE5E7EB);

  int menuSelecionado = 0;

  double clientes = 0;
  double cavalos = 0;
  double propostas = 0;

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
        clientes = (data['clientes'] ?? 0).toDouble();
        cavalos = (data['cavalos'] ?? 0).toDouble();
        propostas = (data['propostas'] ?? 0).toDouble();

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
      MaterialPageRoute(
        builder: (_) => const LoginPage(),
      ),
      (route) => false,
    );
  }

  void abrirTela(Widget pagina, int menu) {
    setState(() {
      menuSelecionado = menu;
    });

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => pagina,
      ),
    );
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> ultimosClientes() {
    return FirebaseFirestore.instance
        .collection('clientes')
        .orderBy('criadoEm', descending: true)
        .limit(5)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    final desktop = MediaQuery.of(context).size.width >= 1000;

    return Scaffold(
      backgroundColor: corFundo,
      drawer: desktop ? null : _drawer(),
      body: Row(
        children: [
          if (desktop) _sidebar(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: carregar,
              color: corPrimaria,
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: _header(desktop),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _cabecalhoBoasVindas(),
                          const SizedBox(height: 28),
                          _tituloSecao('Ações Rápidas'),
                          const SizedBox(height: 14),
                          _acoesRapidas(),
                          const SizedBox(height: 32),
                          _tituloSecao('Visão Geral'),
                          const SizedBox(height: 14),
                          _gridResumo(),
                          const SizedBox(height: 32),
                          _tituloSecao('Últimos Clientes'),
                          const SizedBox(height: 14),
                          _listaClientes(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
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
  // AÇÕES RÁPIDAS
  // =====================================================
  //
  // Atalhos de um clique só para as ações mais comuns,
  // sem precisar passar pelo menu "Cadastro".

  Widget _acoesRapidas() {
    return LayoutBuilder(
      builder: (context, constraints) {
        int colunas = 2;

        if (constraints.maxWidth >= 900) {
          colunas = 4;
        } else if (constraints.maxWidth >= 600) {
          colunas = 3;
        }

        final acoes = [
          _AcaoRapida(
            titulo: 'Novo Cliente',
            icon: Icons.person_add_alt_1_rounded,
            cor: const Color(0xFF2563EB),
            pagina: const RegisterPage(),
          ),
          _AcaoRapida(
            titulo: 'Novo Cavalo',
            icon: Icons.pets_rounded,
            cor: const Color(0xFF7C3AED),
            pagina: const CadastroCavaloPage(),
          ),
          _AcaoRapida(
            titulo: 'Novo Funcionário',
            icon: Icons.badge_rounded,
            cor: const Color(0xFFD97706),
            pagina: const CadastroFuncionarioPage(),
          ),
          _AcaoRapida(
            titulo: 'Novo Fornecedor',
            icon: Icons.storefront_rounded,
            cor: const Color(0xFF059669),
            pagina: const CadastroFornecedorPage(),
          ),
        ];

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: acoes.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: colunas,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            childAspectRatio: 2.4,
          ),
          itemBuilder: (_, index) {
            final acao = acoes[index];

            return InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => acao.pagina),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: corBorda),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: acao.cor.withOpacity(.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(acao.icon, color: acao.cor, size: 18),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        acao.titulo,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: corTextoPrimario,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // =====================================================
  // LOGO (monograma, sem ícone grande de mascote)
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
  // SIDEBAR
  // =====================================================
  //
  // Por enquanto só Dashboard e Clientes. Os outros itens
  // (Cavalos, Financeiro, Nova Conta, Propostas) foram
  // removidos temporariamente do menu.

  Widget _sidebar() {
    return Container(
      width: 260,
      color: corSidebar,
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 28),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
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
                          'Painel Administrativo',
                          style: TextStyle(
                            color: Colors.white54,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            const Divider(color: Colors.white12, height: 1),
            const SizedBox(height: 12),
            _sidebarItem(
              0,
              'Dashboard',
              Icons.grid_view_rounded,
              () {},
            ),
            _sidebarItem(
              1,
              'Clientes',
              Icons.people_alt_outlined,
              () => abrirTela(ClientesPage(), 1),
            ),
            _sidebarItem(
              2,
              'Cadastro',
              Icons.add_box_outlined,
              () => abrirTela(const CadastroHubPage(), 2),
            ),
            _sidebarItem(
              3,
              'Cavalos',
              Icons.pets_outlined,
              () => abrirTela(const CavalosListPage(), 3),
            ),
            _sidebarItem(
              4,
              'Funcionários',
              Icons.badge_outlined,
              () => abrirTela(const FuncionariosListPage(), 4),
            ),
            _sidebarItem(
              5,
              'Fornecedores',
              Icons.storefront_outlined,
              () => abrirTela(const FornecedoresListPage(), 5),
            ),
            const Spacer(),
            const Divider(color: Colors.white12, height: 1),
            _sidebarItem(
              99,
              'Sair',
              Icons.logout,
              logout,
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _sidebarItem(
    int index,
    String titulo,
    IconData icon,
    VoidCallback onTap,
  ) {
    final ativo = menuSelecionado == index;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 3,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
            decoration: BoxDecoration(
              color: ativo ? corSidebarAtivo : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: ativo
                  ? const Border(
                      left: BorderSide(color: corPrimaria, width: 3),
                    )
                  : null,
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: ativo ? Colors.white : Colors.white70,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    titulo,
                    style: TextStyle(
                      color: ativo ? Colors.white : Colors.white70,
                      fontWeight: ativo ? FontWeight.w600 : FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // =====================================================
  // DRAWER (mobile)
  // =====================================================
  //
  // Mesma redução: só Dashboard e Clientes por enquanto.

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
                          style: TextStyle(
                            color: Colors.white54,
                            fontSize: 12,
                          ),
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
                  _drawerItem(
                    'Clientes',
                    Icons.people_alt_outlined,
                    () {
                      Navigator.pop(context);
                      abrirTela(ClientesPage(), 1);
                    },
                  ),
                  _drawerItem(
                    'Cadastro',
                    Icons.add_box_outlined,
                    () {
                      Navigator.pop(context);
                      abrirTela(const CadastroHubPage(), 2);
                    },
                  ),
                  _drawerItem(
                    'Cavalos',
                    Icons.pets_outlined,
                    () {
                      Navigator.pop(context);
                      abrirTela(const CavalosListPage(), 3);
                    },
                  ),
                  _drawerItem(
                    'Funcionários',
                    Icons.badge_outlined,
                    () {
                      Navigator.pop(context);
                      abrirTela(const FuncionariosListPage(), 4);
                    },
                  ),
                  _drawerItem(
                    'Fornecedores',
                    Icons.storefront_outlined,
                    () {
                      Navigator.pop(context);
                      abrirTela(const FornecedoresListPage(), 5);
                    },
                  ),
                ],
              ),
            ),
            const Divider(color: Colors.white12, height: 1),
            ListTile(
              leading: const Icon(
                Icons.logout,
                color: Colors.redAccent,
              ),
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

  Widget _drawerItem(
    String titulo,
    IconData icon,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(
        icon,
        color: Colors.white70,
        size: 20,
      ),
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

  Widget _header(bool desktop) {
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: corBorda),
        ),
      ),
      child: Builder(
        builder: (context) {
          return Row(
            children: [
              if (!desktop)
                IconButton(
                  icon: const Icon(Icons.menu, color: corTextoPrimario),
                  onPressed: () {
                    Scaffold.of(context).openDrawer();
                  },
                ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Dashboard Administrativo',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: corTextoPrimario,
                      ),
                    ),
                    const Text(
                      'Gestão completa do seu haras',
                      style: TextStyle(
                        color: corTextoSecundario,
                        fontSize: 12.5,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Atualizar dados',
                onPressed: carregar,
                icon: const Icon(
                  Icons.refresh_rounded,
                  color: corTextoSecundario,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 38,
                height: 38,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: corFundo,
                  shape: BoxShape.circle,
                  border: Border.all(color: corBorda),
                ),
                child: const Icon(
                  Icons.person_outline,
                  color: corTextoSecundario,
                  size: 20,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // =====================================================
  // CABEÇALHO DE BOAS-VINDAS (substitui o banner com mascote)
  // =====================================================

  Widget _cabecalhoBoasVindas() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: corSidebar,
        borderRadius: BorderRadius.circular(12),
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

        if (constraints.maxWidth >= 1400) {
          colunas = 6;
        } else if (constraints.maxWidth >= 1000) {
          colunas = 3;
        } else if (constraints.maxWidth >= 600) {
          colunas = 2;
        }

        final cards = [
          _cardResumo(
            'Clientes',
            clientes.toInt().toString(),
            Icons.people_alt_outlined,
            const Color(0xFF2563EB),
          ),
          _cardResumo(
            'Cavalos',
            cavalos.toInt().toString(),
            Icons.pets_outlined,
            const Color(0xFF7C3AED),
          ),
          _cardResumo(
            'Propostas',
            propostas.toInt().toString(),
            Icons.description_outlined,
            const Color(0xFF4F46E5),
          ),
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
            childAspectRatio: 1.65,
          ),
          itemBuilder: (_, index) => cards[index],
        );
      },
    );
  }

  Widget _cardResumo(
    String titulo,
    String valor,
    IconData icon,
    Color cor,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
            child: Icon(
              icon,
              color: cor,
              size: 18,
            ),
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

  // =====================================================
  // LISTA DE CLIENTES
  // =====================================================

  Widget _listaClientes() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: ultimosClientes(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 30),
            child: Center(
              child: CircularProgressIndicator(color: corPrimaria),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: corBorda),
            ),
            child: const Column(
              children: [
                Icon(
                  Icons.people_outline,
                  size: 40,
                  color: corTextoSecundario,
                ),
                SizedBox(height: 10),
                Text(
                  'Nenhum cliente cadastrado',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: corTextoPrimario,
                  ),
                ),
              ],
            ),
          );
        }

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: corBorda),
          ),
          child: Column(
            children: snapshot.data!.docs.asMap().entries.map((entry) {
              final index = entry.key;
              final doc = entry.value;
              final data = doc.data();

              final nome = data['nome'] ?? 'Cliente';
              final email = data['email'] ?? '';
              final telefone = data['telefone'] ?? '';
              final ultimo = index == snapshot.data!.docs.length - 1;

              return Container(
                decoration: BoxDecoration(
                  border: ultimo
                      ? null
                      : const Border(
                          bottom: BorderSide(color: corBorda),
                        ),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  leading: CircleAvatar(
                    radius: 20,
                    backgroundColor: corPrimaria.withOpacity(.10),
                    child: Text(
                      nome.toString().substring(0, 1).toUpperCase(),
                      style: const TextStyle(
                        color: corPrimaria,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  title: Text(
                    nome,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: corTextoPrimario,
                      fontSize: 14,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (email.toString().isNotEmpty)
                        Text(
                          email,
                          style: const TextStyle(
                            color: corTextoSecundario,
                            fontSize: 12.5,
                          ),
                        ),
                      if (telefone.toString().isNotEmpty)
                        Text(
                          telefone,
                          style: const TextStyle(
                            color: corTextoSecundario,
                            fontSize: 12.5,
                          ),
                        ),
                    ],
                  ),
                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    size: 13,
                    color: corTextoSecundario,
                  ),
                  onTap: () {
                    final cliente = ClienteModel.fromMap(
                      data,
                      doc.id,
                    );

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ClienteDetalhesPage(
                          cliente: cliente,
                        ),
                      ),
                    );
                  },
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}

// =====================================================
// MODELO SIMPLES PARA UMA AÇÃO RÁPIDA DO DASHBOARD
// =====================================================

class _AcaoRapida {
  final String titulo;
  final IconData icon;
  final Color cor;
  final Widget pagina;

  const _AcaoRapida({
    required this.titulo,
    required this.icon,
    required this.cor,
    required this.pagina,
  });
}