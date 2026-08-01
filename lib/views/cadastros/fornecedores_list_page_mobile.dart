// ignore_for_file: deprecated_member_use

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../models/fornecedor_model.dart';

import 'fornecedor_detalhes_page.dart';
import 'cadastro_fornecedor_page.dart';

// =====================================================
// FornecedoresListPageMobile
// =====================================================
//
// Versão mobile: lista de cards, igual já funcionava
// antes de separar Desktop/Mobile.

class FornecedoresListPageMobile extends StatefulWidget {
  const FornecedoresListPageMobile({super.key});

  @override
  State<FornecedoresListPageMobile> createState() =>
      _FornecedoresListPageMobileState();
}

class _FornecedoresListPageMobileState
    extends State<FornecedoresListPageMobile> {
  String busca = '';

  static const Color primaria = Color(0xFF4F46E5);
  static const Color fundo = Color(0xFFF3F4F6);
  static const Color corTextoPrimario = Color(0xFF111827);
  static const Color corTextoSecundario = Color(0xFF6B7280);
  static const Color corBorda = Color(0xFFE5E7EB);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: fundo,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: corTextoPrimario,
        title: const Text(
          'Fornecedores',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: primaria,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Novo Fornecedor',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const CadastroFornecedorPage(),
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
                hintText: 'Buscar por nome ou categoria...',
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
                  .collection('fornecedores')
                  .orderBy('nome')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Erro: ${snapshot.error}'));
                }

                final todos = (snapshot.data?.docs ?? [])
                    .map((doc) => FornecedorModel.fromMap(doc.data(), doc.id))
                    .toList();

                final fornecedores = busca.isEmpty
                    ? todos
                    : todos.where((f) {
                        return f.nome.toLowerCase().contains(busca) ||
                            f.categoria.toLowerCase().contains(busca);
                      }).toList();

                if (fornecedores.isEmpty) {
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
                              ? 'Nenhum fornecedor cadastrado'
                              : 'Nenhum resultado para "$busca"',
                          style: const TextStyle(color: corTextoSecundario),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 90),
                  itemCount: fornecedores.length,
                  itemBuilder: (context, index) {
                    final fornecedor = fornecedores[index];

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: corBorda),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        leading: CircleAvatar(
                          radius: 22,
                          backgroundColor: primaria.withOpacity(.10),
                          child: Icon(
                            Icons.storefront_rounded,
                            color: primaria,
                          ),
                        ),
                        title: Text(
                          fornecedor.nome.isEmpty
                              ? 'Fornecedor'
                              : fornecedor.nome,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: corTextoPrimario,
                          ),
                        ),
                        subtitle: Text(
                          fornecedor.categoria.isEmpty
                              ? 'Categoria não informada'
                              : fornecedor.categoria,
                          style: const TextStyle(color: corTextoSecundario),
                        ),
                        trailing: const Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 14,
                          color: corTextoSecundario,
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => FornecedorDetalhesPage(
                                fornecedorId: fornecedor.id,
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