// ignore_for_file: unused_field, deprecated_member_use

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../widgets/app_dialogs.dart';

import '../../models/cavalo_venda_model.dart';

import 'cadastro_cavalo_venda_page.dart';

class CavalosVendaListPageMobile extends StatefulWidget {
  const CavalosVendaListPageMobile({super.key});

  @override
  State<CavalosVendaListPageMobile> createState() => _CavalosVendaListPageMobileState();
}

class _CavalosVendaListPageMobileState extends State<CavalosVendaListPageMobile> {
  String busca = '';

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
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: corTextoPrimario,
        title: const Text(
          'Cavalos à Venda (site)',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: primaria,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Novo Cavalo',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const CadastroCavaloVendaPage(),
            ),
          );
        },
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Buscar por nome ou raça...',
                prefixIcon: const Icon(Icons.search),
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
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 90),
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
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => CadastroCavaloVendaPage(
                                  cavaloParaEditar: cavalo,
                                ),
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
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: corBorda),
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
                  Text(
                    cavalo.nome.isEmpty ? 'Sem nome' : cavalo.nome,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: corTextoPrimario,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
