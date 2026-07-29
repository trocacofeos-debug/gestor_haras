import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../models/cavalo_model.dart';
import '../../widgets/cavalo_card.dart';

import 'cavalo_detalhes_page.dart';
import 'cadastro_cavalo_page.dart';

class CavalosListPage extends StatefulWidget {
  const CavalosListPage({super.key});

  @override
  State<CavalosListPage> createState() => _CavalosListPageState();
}

class _CavalosListPageState extends State<CavalosListPage> {
  String busca = '';

  static const Color primaria = Color(0xFF4F46E5);
  static const Color fundo = Color(0xFFF3F4F6);
  static const Color corTextoSecundario = Color(0xFF6B7280);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: fundo,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: const Color(0xFF111827),
        title: const Text(
          'Cavalos',
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
              builder: (_) => const CadastroCavaloPage(),
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
                  .collection('cavalos')
                  .orderBy('nome')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text('Erro: ${snapshot.error}'),
                  );
                }

                final todos = (snapshot.data?.docs ?? [])
                    .map((doc) => CavaloModel.fromMap(doc.data(), doc.id))
                    .toList();

                final cavalos = busca.isEmpty
                    ? todos
                    : todos.where((c) {
                        return c.nome.toLowerCase().contains(busca) ||
                            c.raca.toLowerCase().contains(busca) ||
                            c.proprietarioNome.toLowerCase().contains(busca);
                      }).toList();

                if (cavalos.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.pets_outlined,
                          size: 50,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          todos.isEmpty
                              ? 'Nenhum cavalo cadastrado'
                              : 'Nenhum resultado para "$busca"',
                          style: const TextStyle(color: corTextoSecundario),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 90),
                  itemCount: cavalos.length,
                  itemBuilder: (context, index) {
                    final cavalo = cavalos[index];

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: CavaloCard(
                        cavalo: cavalo,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CavaloDetalhesPage(
                                cavaloId: cavalo.id,
                              ),
                            ),
                          );
                        },
                      ),
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