// ignore_for_file: deprecated_member_use

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../models/fornecedor_model.dart';

import 'fornecedor_detalhes_page.dart';
import 'cadastro_fornecedor_page.dart';
import '../home/admin_top_bar.dart';

// =====================================================
// FornecedoresListPageDesktop
// =====================================================
//
// Versão desktop: tabela em vez de lista. Clicar numa
// linha abre um popup compacto com os dados do
// fornecedor, sem navegar nem rolar a tela.

class FornecedoresListPageDesktop extends StatefulWidget {
  const FornecedoresListPageDesktop({super.key});

  @override
  State<FornecedoresListPageDesktop> createState() =>
      _FornecedoresListPageDesktopState();
}

class _FornecedoresListPageDesktopState
    extends State<FornecedoresListPageDesktop> {
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
          const AdminTopBar(),
          Container(
            height: 56,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            color: Colors.white,
            alignment: Alignment.centerLeft,
            child: const Text(
              'Fornecedores',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ),
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
                            DataColumn(label: Text('Categoria')),
                            DataColumn(label: Text('Telefone')),
                            DataColumn(label: Text('Email')),
                            DataColumn(label: Text('Status')),
                            DataColumn(label: Text('Ações')),
                          ],
                          rows: fornecedores.map((fornecedor) {
                            return DataRow(
                              cells: [
                                DataCell(
                                  Text(
                                    fornecedor.nome.isEmpty
                                        ? 'Sem nome'
                                        : fornecedor.nome,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    fornecedor.categoria.isEmpty
                                        ? '-'
                                        : fornecedor.categoria,
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    fornecedor.telefone.isEmpty
                                        ? '-'
                                        : fornecedor.telefone,
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    fornecedor.email.isEmpty
                                        ? '-'
                                        : fornecedor.email,
                                  ),
                                ),
                                DataCell(
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: (fornecedor.ativo
                                              ? Colors.green
                                              : Colors.red)
                                          .withOpacity(.12),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      fornecedor.ativo ? 'Ativo' : 'Inativo',
                                      style: TextStyle(
                                        color: fornecedor.ativo
                                            ? Colors.green
                                            : Colors.red,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
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
                                    onPressed: () => _abrirPopupFornecedor(
                                      context,
                                      fornecedor,
                                    ),
                                  ),
                                ),
                              ],
                              onSelectChanged: (_) => _abrirPopupFornecedor(
                                context,
                                fornecedor,
                              ),
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
  // POPUP DE FORNECEDOR (SEM SCROLL)
  // =====================================================

  Future<void> _abrirPopupFornecedor(
    BuildContext context,
    FornecedorModel fornecedor,
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
                      ),
                      child: const Icon(
                        Icons.storefront_rounded,
                        color: primaria,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            fornecedor.nome.isEmpty
                                ? 'Fornecedor'
                                : fornecedor.nome,
                            style: const TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.bold,
                              color: corTexto,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Text(
                                fornecedor.categoria.isEmpty
                                    ? 'Categoria não informada'
                                    : fornecedor.categoria,
                                style: const TextStyle(
                                  color: primaria,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: (fornecedor.ativo
                                          ? Colors.green
                                          : Colors.red)
                                      .withOpacity(.12),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  fornecedor.ativo ? 'Ativo' : 'Inativo',
                                  style: TextStyle(
                                    color: fornecedor.ativo
                                        ? Colors.green
                                        : Colors.red,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11.5,
                                  ),
                                ),
                              ),
                            ],
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
                          _campoPopup('CPF / CNPJ', fornecedor.cpfCnpj),
                          _campoPopup('Telefone', fornecedor.telefone),
                          _campoPopup('Email', fornecedor.email),
                        ],
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _campoPopup('Endereço', fornecedor.endereco),
                          _campoPopup('Categoria', fornecedor.categoria),
                        ],
                      ),
                    ),
                  ],
                ),

                if (fornecedor.observacoes.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  _campoPopup('Observações', fornecedor.observacoes),
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
                            builder: (_) => FornecedorDetalhesPage(
                              fornecedorId: fornecedor.id,
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