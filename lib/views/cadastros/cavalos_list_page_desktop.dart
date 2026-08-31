// ignore_for_file: deprecated_member_use

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../models/cavalo_model.dart';

import 'cavalo_detalhes_page.dart';
import 'cadastro_cavalo_page.dart';
import '../home/admin_top_bar.dart';
import '../../widgets/desktop_window.dart';

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
  State<CavalosListPageDesktop> createState() => _CavalosListPageDesktopState();
}

class _CavalosListPageDesktopState extends State<CavalosListPageDesktop> {
  String busca = '';
  final buscaController = TextEditingController();
  late final Stream<QuerySnapshot<Map<String, dynamic>>> _cavalosStream =
      FirebaseFirestore.instance
          .collection('cavalos')
          .orderBy('nome')
          .snapshots();

  @override
  void dispose() {
    buscaController.dispose();
    super.dispose();
  }

  static const Color primaria = Color(0xFF4F46E5);
  static const Color fundo = Color(0xFFF3F4F6);
  static const Color corTexto = Color(0xFF111827);
  static const Color corTextoSecundario = Color(0xFF6B7280);
  static const Color corBorda = Color(0xFFE5E7EB);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: fundo,
      body: SafeArea(
        child: Column(
          children: [
            const AdminTopBar(),
            Container(
              height: 60,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(bottom: BorderSide(color: corBorda)),
              ),
              child: Row(
                children: [
                  if (Navigator.canPop(context)) ...[
                    IconButton(
                      tooltip: 'Voltar',
                      onPressed: () => Navigator.maybePop(context),
                      icon: const Icon(
                        Icons.arrow_back,
                        color: corTexto,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  const Expanded(
                    child: Text(
                      'Animais',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: corTexto,
                      ),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      openDesktopWindow(
                        context,
                        title: 'Novo cavalo',
                        icon: Icons.pets_rounded,
                        width: 1100,
                        builder: (_) => const CadastroCavaloPage(),
                      );
                    },
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Novo cavalo'),
                    style: TextButton.styleFrom(foregroundColor: primaria),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: TextField(
                controller: buscaController,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: 'Buscar cavalo...',
                  helperText: 'Nome, raça ou proprietário',
                  prefixIcon: const Icon(
                    Icons.search,
                    color: corTextoSecundario,
                    size: 20,
                  ),
                  suffixIcon: buscaController.text.isEmpty
                      ? null
                      : IconButton(
                          tooltip: 'Limpar busca',
                          icon: const Icon(Icons.close, size: 18),
                          onPressed: () {
                            buscaController.clear();
                            setState(() => busca = '');
                          },
                        ),
                  isDense: true,
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: const BorderSide(color: corBorda),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: const BorderSide(color: corBorda),
                  ),
                ),
                onChanged: (value) =>
                    setState(() => busca = value.toLowerCase().trim()),
              ),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: _cavalosStream,
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
                      : todos
                            .where(
                              (c) =>
                                  c.nome.toLowerCase().contains(busca) ||
                                  c.raca.toLowerCase().contains(busca) ||
                                  c.proprietarioNome.toLowerCase().contains(
                                    busca,
                                  ),
                            )
                            .toList();
                  if (cavalos.isEmpty) {
                    return Center(
                      child: Text(
                        todos.isEmpty
                            ? 'Nenhum cavalo cadastrado'
                            : 'Nenhum resultado para "$busca"',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: corTextoSecundario),
                      ),
                    );
                  }
                  return _listaCavalos(cavalos);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _listaCavalos(List<CavaloModel> cavalos) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Align(
        alignment: Alignment.topCenter,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: corBorda),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                showCheckboxColumn: false,
                headingRowHeight: 40,
                dataRowMinHeight: 48,
                dataRowMaxHeight: 56,
                horizontalMargin: 16,
                columnSpacing: 24,
                headingRowColor: MaterialStateProperty.all(fundo),
                columns: const [
                  DataColumn(label: Text('Nome')),
                  DataColumn(label: Text('Raça')),
                  DataColumn(label: Text('Sexo')),
                  DataColumn(label: Text('Proprietário')),
                  DataColumn(label: Text('Status')),
                  DataColumn(label: Text('Ações')),
                ],
                rows: cavalos
                    .map(
                      (cavalo) => DataRow(
                        onSelectChanged: (_) =>
                            _abrirPopupCavalo(context, cavalo),
                        cells: [
                          DataCell(
                            Text(
                              cavalo.nome.isEmpty ? 'Sem nome' : cavalo.nome,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            onTap: () => _abrirPopupCavalo(context, cavalo),
                          ),
                          DataCell(
                            Text(cavalo.raca.isEmpty ? '—' : cavalo.raca),
                          ),
                          DataCell(
                            Text(cavalo.sexo.isEmpty ? '—' : cavalo.sexo),
                          ),
                          DataCell(
                            Text(
                              cavalo.proprietarioNome.isEmpty
                                  ? '—'
                                  : cavalo.proprietarioNome,
                            ),
                          ),
                          DataCell(
                            Text(
                              cavalo.ativo ? 'Ativo' : 'Inativo',
                              style: const TextStyle(
                                color: corTextoSecundario,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          DataCell(
                            IconButton(
                              tooltip: 'Ver detalhes',
                              icon: const Icon(
                                Icons.chevron_right,
                                color: corTextoSecundario,
                                size: 20,
                              ),
                              onPressed: () =>
                                  _abrirPopupCavalo(context, cavalo),
                            ),
                          ),
                        ],
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _abrirPopupCavalo(BuildContext context, CavaloModel cavalo) {
    return abrirPopupDetalhesCavalo(context, cavalo.id);
  }
}
