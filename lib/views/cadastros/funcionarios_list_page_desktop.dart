// ignore_for_file: deprecated_member_use

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../models/funcionario_model.dart';

import 'funcionario_detalhes_page.dart';
import 'cadastro_funcionario_page.dart';
import '../home/admin_top_bar.dart';
import '../../widgets/desktop_window.dart';

// =====================================================
// FuncionariosListPageDesktop
// =====================================================
//
// Versão desktop: tabela em vez de lista. Clicar numa
// linha abre um popup compacto com os dados do
// funcionário, sem navegar nem rolar a tela.

class FuncionariosListPageDesktop extends StatefulWidget {
  const FuncionariosListPageDesktop({super.key});

  @override
  State<FuncionariosListPageDesktop> createState() =>
      _FuncionariosListPageDesktopState();
}

class _FuncionariosListPageDesktopState
    extends State<FuncionariosListPageDesktop> {
  String busca = '';

  static const Color primaria = Color(0xFF4F46E5);
  static const Color fundo = Color(0xFFF3F4F6);
  static const Color corTexto = Color(0xFF111827);
  static const Color corTextoSecundario = Color(0xFF6B7280);
  static const Color corBorda = Color(0xFFE5E7EB);

  String _formatarData(Timestamp? ts) {
    if (ts == null) return '-';
    final d = ts.toDate();
    return '${d.day.toString().padLeft(2, '0')}/'
        '${d.month.toString().padLeft(2, '0')}/'
        '${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: fundo,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: primaria,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Novo Funcionário',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        onPressed: () {
          openDesktopWindow(
            context,
            title: 'Novo funcionário',
            icon: Icons.badge_rounded,
            width: 1100,
            builder: (_) => const CadastroFuncionarioPage(),
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
              'Funcionários',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ),
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

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1440),
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
                              headingRowColor: MaterialStateProperty.all(fundo),
                              columns: const [
                                DataColumn(label: Text('Nome')),
                                DataColumn(label: Text('Cargo')),
                                DataColumn(label: Text('Telefone')),
                                DataColumn(label: Text('Salário')),
                                DataColumn(label: Text('Status')),
                                DataColumn(label: Text('Ações')),
                              ],
                              rows: funcionarios.map((funcionario) {
                                return DataRow(
                                  cells: [
                                    DataCell(
                                      Text(
                                        funcionario.nome.isEmpty
                                            ? 'Sem nome'
                                            : funcionario.nome,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      Text(
                                        funcionario.cargo.isEmpty
                                            ? '-'
                                            : funcionario.cargo,
                                      ),
                                    ),
                                    DataCell(
                                      Text(
                                        funcionario.telefone.isEmpty
                                            ? '-'
                                            : funcionario.telefone,
                                      ),
                                    ),
                                    DataCell(
                                      Text(
                                        'R\$ ${funcionario.salario.toStringAsFixed(2)}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: primaria,
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color:
                                              (funcionario.ativo
                                                      ? Colors.green
                                                      : Colors.red)
                                                  .withOpacity(.12),
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                        child: Text(
                                          funcionario.ativo
                                              ? 'Ativo'
                                              : 'Inativo',
                                          style: TextStyle(
                                            color: funcionario.ativo
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
                                        onPressed: () => _abrirPopupFuncionario(
                                          context,
                                          funcionario,
                                        ),
                                      ),
                                    ),
                                  ],
                                  onSelectChanged: (_) =>
                                      _abrirPopupFuncionario(
                                        context,
                                        funcionario,
                                      ),
                                );
                              }).toList(),
                            ),
                          ),
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
  // POPUP DE FUNCIONÁRIO (SEM SCROLL)
  // =====================================================

  Future<void> _abrirPopupFuncionario(
    BuildContext context,
    FuncionarioModel funcionario,
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
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.85,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 28,
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
                              fontSize: 22,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                funcionario.nome.isEmpty
                                    ? 'Funcionário'
                                    : funcionario.nome,
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
                                    funcionario.cargo.isEmpty
                                        ? 'Cargo não informado'
                                        : funcionario.cargo,
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
                                      color:
                                          (funcionario.ativo
                                                  ? Colors.green
                                                  : Colors.red)
                                              .withOpacity(.12),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      funcionario.ativo ? 'Ativo' : 'Inativo',
                                      style: TextStyle(
                                        color: funcionario.ativo
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
                          icon: const Icon(
                            Icons.close,
                            color: corTextoSecundario,
                          ),
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
                              _campoPopup('CPF', funcionario.cpf),
                              _campoPopup('Telefone', funcionario.telefone),
                              _campoPopup('Email', funcionario.email),
                            ],
                          ),
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _campoPopup(
                                'Salário',
                                'R\$ ${funcionario.salario.toStringAsFixed(2)}',
                              ),
                              _campoPopup(
                                'Data de admissão',
                                _formatarData(funcionario.dataAdmissao),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    if (funcionario.observacoes.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      _campoPopup('Observações', funcionario.observacoes),
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
                            openDesktopWindow(
                              context,
                              title: 'Perfil do funcionário',
                              icon: Icons.badge_rounded,
                              builder: (_) => FuncionarioDetalhesPage(
                                funcionarioId: funcionario.id,
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
            style: const TextStyle(color: corTextoSecundario, fontSize: 12),
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
