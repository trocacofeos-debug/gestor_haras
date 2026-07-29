// ignore_for_file: deprecated_member_use

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../models/funcionario_model.dart';

import 'funcionario_detalhes_page.dart';
import 'cadastro_funcionario_page.dart';

class FuncionariosListPage extends StatefulWidget {
  const FuncionariosListPage({super.key});

  @override
  State<FuncionariosListPage> createState() => _FuncionariosListPageState();
}

class _FuncionariosListPageState extends State<FuncionariosListPage> {
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
          'Funcionários',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: primaria,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Novo Funcionário',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const CadastroFuncionarioPage(),
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
                hintText: 'Buscar por nome ou cargo...',
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
                  .collection('funcionarios')
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
                    .map((doc) => FuncionarioModel.fromMap(doc.data(), doc.id))
                    .toList();

                final funcionarios = busca.isEmpty
                    ? todos
                    : todos.where((f) {
                        return f.nome.toLowerCase().contains(busca) ||
                            f.cargo.toLowerCase().contains(busca);
                      }).toList();

                if (funcionarios.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.badge_outlined,
                          size: 50,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          todos.isEmpty
                              ? 'Nenhum funcionário cadastrado'
                              : 'Nenhum resultado para "$busca"',
                          style: const TextStyle(color: corTextoSecundario),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 90),
                  itemCount: funcionarios.length,
                  itemBuilder: (context, index) {
                    final funcionario = funcionarios[index];

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
                          child: Text(
                            funcionario.nome.isEmpty
                                ? '?'
                                : funcionario.nome
                                    .substring(0, 1)
                                    .toUpperCase(),
                            style: const TextStyle(
                              color: primaria,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(
                          funcionario.nome.isEmpty
                              ? 'Funcionário'
                              : funcionario.nome,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: corTextoPrimario,
                          ),
                        ),
                        subtitle: Text(
                          funcionario.cargo.isEmpty
                              ? 'Cargo não informado'
                              : funcionario.cargo,
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
                              builder: (_) => FuncionarioDetalhesPage(
                                funcionarioId: funcionario.id,
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