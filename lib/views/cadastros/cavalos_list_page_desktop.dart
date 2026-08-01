// ignore_for_file: deprecated_member_use

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../models/cavalo_model.dart';
import '../../models/despesa_cavalo_model.dart';

import 'cavalo_detalhes_page.dart';
import 'cadastro_cavalo_page.dart';
import '../home/admin_top_bar.dart';

// =====================================================
// CavalosListPageDesktop
// =====================================================
//
// Versão desktop: tabela (estilo planilha) em vez de
// cards. Clicar numa linha abre um popup compacto com os
// dados do cavalo, sem precisar navegar pra outra tela
// nem rolar a tela.

class CavalosListPageDesktop extends StatefulWidget {
  const CavalosListPageDesktop({super.key});

  @override
  State<CavalosListPageDesktop> createState() =>
      _CavalosListPageDesktopState();
}

class _CavalosListPageDesktopState extends State<CavalosListPageDesktop> {
  String busca = '';

  static const Color primaria = Color(0xFF4F46E5);
  static const Color fundo = Color(0xFFF3F4F6);
  static const Color corTexto = Color(0xFF111827);
  static const Color corTextoSecundario = Color(0xFF6B7280);
  static const Color corBorda = Color(0xFFE5E7EB);

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
          const AdminTopBar(),
          Container(
            height: 56,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            color: Colors.white,
            alignment: Alignment.centerLeft,
            child: const Text(
              'Cavalos',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Buscar por nome, raça ou proprietário...',
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
                  return Center(child: Text('Erro: ${snapshot.error}'));
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

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: corBorda),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          headingRowColor:
                              MaterialStateProperty.all(fundo),
                          columns: const [
                            DataColumn(label: Text('Nome')),
                            DataColumn(label: Text('Raça')),
                            DataColumn(label: Text('Sexo')),
                            DataColumn(label: Text('Proprietário')),
                            DataColumn(label: Text('Ações')),
                          ],
                          rows: cavalos.map((cavalo) {
                            return DataRow(
                              cells: [
                                DataCell(
                                  Text(
                                    cavalo.nome.isEmpty
                                        ? 'Sem nome'
                                        : cavalo.nome,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    cavalo.raca.isEmpty ? '-' : cavalo.raca,
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    cavalo.sexo.isEmpty ? '-' : cavalo.sexo,
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    cavalo.proprietarioNome.isEmpty
                                        ? '-'
                                        : cavalo.proprietarioNome,
                                  ),
                                ),
                                DataCell(
                                  IconButton(
                                    icon: const Icon(
                                      Icons.arrow_forward_ios_rounded,
                                      size: 15,
                                      color: primaria,
                                    ),
                                    tooltip: 'Ver detalhes',
                                    onPressed: () =>
                                        _abrirPopupCavalo(context, cavalo),
                                  ),
                                ),
                              ],
                              onSelectChanged: (_) =>
                                  _abrirPopupCavalo(context, cavalo),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // =====================================================
  // POPUP DE CAVALO (SEM SCROLL)
  // =====================================================

  Future<void> _abrirPopupCavalo(
    BuildContext context,
    CavaloModel cavalo,
  ) async {
    await showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          child: Container(
            width: 720,
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: primaria.withOpacity(.10),
                        borderRadius: BorderRadius.circular(12),
                        image: cavalo.fotos.isNotEmpty
                            ? DecorationImage(
                                image: NetworkImage(cavalo.fotos.first),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: cavalo.fotos.isEmpty
                          ? const Icon(
                              Icons.pets_rounded,
                              color: primaria,
                            )
                          : null,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            cavalo.nome.isEmpty ? 'Cavalo' : cavalo.nome,
                            style: const TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.bold,
                              color: corTexto,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            cavalo.raca.isEmpty
                                ? 'Raça não informada'
                                : cavalo.raca,
                            style: const TextStyle(
                              color: primaria,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: corTextoSecundario),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),

                const SizedBox(height: 20),
                const Divider(color: corBorda, height: 1),
                const SizedBox(height: 20),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _campoPopup('Sexo', cavalo.sexo),
                          _campoPopup('Pelagem', cavalo.pelagem),
                        ],
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _campoPopup(
                            'Proprietário',
                            cavalo.proprietarioNome,
                          ),
                          _campoPopup(
                            'Status',
                            cavalo.ativo ? 'Ativo' : 'Inativo',
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Total em despesas',
                                  style: TextStyle(
                                    color: corTextoSecundario,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                StreamBuilder<
                                    QuerySnapshot<Map<String, dynamic>>>(
                                  stream: FirebaseFirestore.instance
                                      .collection('cavalos')
                                      .doc(cavalo.id)
                                      .collection('despesas')
                                      .snapshots(),
                                  builder: (context, despesasSnapshot) {
                                    final total = (despesasSnapshot
                                                .data?.docs ??
                                            [])
                                        .map(
                                          (doc) => DespesaCavaloModel.fromMap(
                                            doc.data(),
                                            doc.id,
                                          ),
                                        )
                                        .fold<double>(
                                          0,
                                          (soma, d) => soma + d.valor,
                                        );

                                    return Text(
                                      'R\$ ${total.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        fontSize: 14.5,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.redAccent,
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                if (cavalo.observacoes.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  _campoPopup('Observações', cavalo.observacoes),
                ],

                const SizedBox(height: 12),

                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Fechar'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaria,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CavaloDetalhesPage(
                              cavaloId: cavalo.id,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(
                        Icons.open_in_new,
                        size: 16,
                        color: Colors.white,
                      ),
                      label: const Text(
                        'Ver perfil completo',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _campoPopup(String titulo, String valor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: const TextStyle(
              color: corTextoSecundario,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            valor.trim().isEmpty ? '-' : valor,
            style: const TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.w600,
              color: corTexto,
            ),
          ),
        ],
      ),
    );
  }
}