// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

import '../auth/register_page.dart';
import 'cadastro_cavalo_page.dart';
import 'cadastro_fornecedor_page.dart';
import 'cadastro_funcionario_page.dart';
import 'produtos_page.dart';
import '../home/admin_top_bar.dart';
import '../../widgets/desktop_window.dart';

class CadastroHubPageDesktop extends StatelessWidget {
  const CadastroHubPageDesktop({super.key});

  static const Color primaria = Color(0xFF4F46E5);
  static const Color fundo = Color(0xFFF3F4F6);
  static const Color corTextoPrimario = Color(0xFF111827);
  static const Color corTextoSecundario = Color(0xFF6B7280);
  static const Color corBorda = Color(0xFFE5E7EB);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: fundo,
      body: Column(
        children: [
          const AdminTopBar(),
          Container(
            height: 56,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            color: Colors.white,
            alignment: Alignment.centerLeft,
            child: const Text(
              'Cadastro',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ),
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 900),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'O que você deseja cadastrar?',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: corTextoPrimario,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Escolha uma das opções abaixo',
                        style: TextStyle(
                          color: corTextoSecundario,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 28),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final colunas = constraints.maxWidth >= 700 ? 2 : 1;

                          final cards = [
                            _cardCadastro(
                              context: context,
                              titulo: 'Cliente',
                              descricao:
                                  'Cadastrar um novo cliente (pessoa física, jurídica ou rural)',
                              icon: Icons.person_add_alt_1_rounded,
                              cor: const Color(0xFF2563EB),
                              pagina: const RegisterPage(),
                            ),
                            _cardCadastro(
                              context: context,
                              titulo: 'Cavalo',
                              descricao:
                                  'Cadastrar um novo animal e vincular ao proprietário',
                              icon: Icons.pets_rounded,
                              cor: const Color(0xFF7C3AED),
                              pagina: const CadastroCavaloPage(),
                            ),
                            _cardCadastro(
                              context: context,
                              titulo: 'Fornecedor',
                              descricao:
                                  'Cadastrar fornecedores de produtos e serviços',
                              icon: Icons.storefront_rounded,
                              cor: const Color(0xFF059669),
                              pagina: const CadastroFornecedorPage(),
                            ),
                            _cardCadastro(
                              context: context,
                              titulo: 'Funcionário',
                              descricao: 'Cadastrar funcionários da equipe',
                              icon: Icons.badge_rounded,
                              cor: const Color(0xFFD97706),
                              pagina: const CadastroFuncionarioPage(),
                            ),
                            _cardCadastro(
                              context: context,
                              titulo: 'Produtos',
                              descricao:
                                  'Cadastrar remédios, vacinas, suplementos e ração',
                              icon: Icons.inventory_2_rounded,
                              cor: const Color(0xFFDC2626),
                              pagina: const ProdutosPage(),
                            ),
                          ];

                          return GridView.count(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisCount: colunas,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 3.4,
                            children: cards,
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _cardCadastro({
    required BuildContext context,
    required String titulo,
    required String descricao,
    required IconData icon,
    required Color cor,
    required Widget pagina,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        openDesktopWindow(
          context,
          title: 'Novo $titulo',
          icon: icon,
          width: 1100,
          builder: (_) => pagina,
        );
      },
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: corBorda),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.03),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: cor.withOpacity(.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: cor, size: 28),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: corTextoPrimario,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    descricao,
                    style: const TextStyle(
                      color: corTextoSecundario,
                      fontSize: 12.5,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: corTextoSecundario,
            ),
          ],
        ),
      ),
    );
  }
}
