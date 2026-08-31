// ignore_for_file: unused_field, deprecated_member_use

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../widgets/app_dialogs.dart';

import '../../models/cavalo_venda_model.dart';

import 'cadastro_cavalo_venda_page.dart';
import '../home/admin_top_bar.dart';
import '../../widgets/desktop_window.dart';
import '../../widgets/site_admin_header.dart';

class CavalosVendaListPageDesktop extends StatefulWidget {
  const CavalosVendaListPageDesktop({super.key});

  @override
  State<CavalosVendaListPageDesktop> createState() =>
      _CavalosVendaListPageDesktopState();
}

class _CavalosVendaListPageDesktopState
    extends State<CavalosVendaListPageDesktop> {
  String busca = '';
  final TextEditingController buscaController = TextEditingController();

  @override
  void dispose() {
    buscaController.dispose();
    super.dispose();
  }

  static const Color primaria = Color(0xFF4F46E5);
  static const Color fundo = Color(0xFFF3F4F6);
  static const Color corTextoPrimario = Color(0xFF111827);
  static const Color corTextoSecundario = Color(0xFF6B7280);
  static const Color corBorda = Color(0xFFE5E7EB);

  Future<void> _excluir(BuildContext context, CavaloVendaModel cavalo) async {
    final confirmar = await showAppDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remover do site'),
        content: Text(
          'Remover "${cavalo.nome}" da vitrine de cavalos à venda?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Remover'),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    await FirebaseFirestore.instance
        .collection('cavalos_venda')
        .doc(cavalo.id)
        .delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: fundo,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: primaria,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Novo Cavalo',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        onPressed: () {
          openDesktopWindow(
            context,
            title: 'Novo cavalo à venda',
            icon: Icons.add_business_rounded,
            builder: (_) => const CadastroCavaloVendaPage(),
          );
        },
      ),
      body: Column(
        children: [
          const AdminTopBar(),
          const SiteAdminHeader(
            title: 'Cavalos à venda',
            subtitle: 'Gerencie os animais exibidos na vitrine pública',
            icon: Icons.pets_rounded,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 18, 24, 16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: TextField(
                controller: buscaController,
                decoration: InputDecoration(
                  hintText: 'Buscar por nome ou raça...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: busca.isEmpty
                      ? null
                      : IconButton(
                          icon: const Icon(Icons.close_rounded),
                          onPressed: () {
                            buscaController.clear();
                            setState(() => busca = '');
                          },
                        ),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    busca = value.toLowerCase().trim();
                  });
                },
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection('cavalos_venda')
                  .orderBy('dataCadastro', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Erro: ${snapshot.error}'));
                }

                final todos = (snapshot.data?.docs ?? [])
                    .map((doc) => CavaloVendaModel.fromMap(doc.data(), doc.id))
                    .toList();

                final cavalos = busca.isEmpty
                    ? todos
                    : todos.where((c) {
                        return c.nome.toLowerCase().contains(busca) ||
                            c.raca.toLowerCase().contains(busca);
                      }).toList();

                if (cavalos.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.storefront_outlined,
                          size: 50,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          todos.isEmpty
                              ? 'Nenhum cavalo publicado ainda'
                              : 'Nenhum resultado para "$busca"',
                          style: const TextStyle(color: corTextoSecundario),
                        ),
                      ],
                    ),
                  );
                }

                return LayoutBuilder(
                  builder: (context, constraints) {
                    final colunas = constraints.maxWidth >= 1200
                        ? 4
                        : constraints.maxWidth >= 900
                        ? 3
                        : constraints.maxWidth >= 600
                        ? 2
                        : 1;

                    return GridView.builder(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 96),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: colunas,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 0.85,
                      ),
                      itemCount: cavalos.length,
                      itemBuilder: (context, index) {
                        final cavalo = cavalos[index];

                        return _CavaloVendaCard(
                          cavalo: cavalo,
                          onEditar: () {
                            openDesktopWindow(
                              context,
                              title: 'Editar anúncio: ${cavalo.nome}',
                              icon: Icons.edit_rounded,
                              builder: (_) => CadastroCavaloVendaPage(
                                cavaloParaEditar: cavalo,
                              ),
                            );
                          },
                          onExcluir: () => _excluir(context, cavalo),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _CavaloVendaCard extends StatelessWidget {
  final CavaloVendaModel cavalo;
  final VoidCallback onEditar;
  final VoidCallback onExcluir;

  const _CavaloVendaCard({
    required this.cavalo,
    required this.onEditar,
    required this.onExcluir,
  });

  static const Color primaria = Color(0xFF4F46E5);
  static const Color corBorda = Color(0xFFE5E7EB);
  static const Color corTextoPrimario = Color(0xFF111827);
  static const Color corTextoSecundario = Color(0xFF6B7280);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onEditar,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: corBorda),
          boxShadow: const [
            BoxShadow(
              color: Color(0x120F172A),
              blurRadius: 18,
              offset: Offset(0, 7),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: cavalo.fotos.isNotEmpty
                    ? Image.network(
                        cavalo.fotos.first,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        width: double.infinity,
                        color: primaria.withOpacity(.08),
                        child: Icon(
                          Icons.pets_rounded,
                          size: 40,
                          color: primaria.withOpacity(.4),
                        ),
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          cavalo.nome.isEmpty ? 'Sem nome' : cavalo.nome,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: corTextoPrimario,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const Icon(
                        Icons.edit_outlined,
                        size: 16,
                        color: primaria,
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'R\$ ${cavalo.valor.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: primaria,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          cavalo.raca.isEmpty ? '-' : cavalo.raca,
                          style: const TextStyle(
                            color: corTextoSecundario,
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: const Icon(
                          Icons.delete_outline,
                          size: 18,
                          color: Colors.redAccent,
                        ),
                        onPressed: onExcluir,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

