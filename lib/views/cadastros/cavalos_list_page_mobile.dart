import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../models/cavalo_model.dart';

import 'cavalo_detalhes_page.dart';
import 'cadastro_cavalo_page.dart';

// =====================================================
// CavalosListPageMobile
// =====================================================
//
// Versão mobile: lista compacta com busca fixa no topo.

class CavalosListPageMobile extends StatefulWidget {
  const CavalosListPageMobile({super.key});

  @override
  State<CavalosListPageMobile> createState() => _CavalosListPageMobileState();
}

class _CavalosListPageMobileState extends State<CavalosListPageMobile> {
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
  static const Color corBorda = Color(0xFFE5E7EB);
  static const Color corTextoSecundario = Color(0xFF6B7280);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: fundo,
      appBar: AppBar(
        title: const Text('Animais'),
        actions: [
          IconButton(
            tooltip: 'Cadastrar animal',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CadastroCavaloPage()),
            ),
            icon: const Icon(Icons.add_rounded, color: primaria),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
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
    );
  }

  Widget _listaCavalos(List<CavaloModel> cavalos) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      itemCount: cavalos.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final cavalo = cavalos[index];
        return Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CavaloDetalhesPage(cavaloId: cavalo.id),
              ),
            ),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: corBorda),
              ),
              child: Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: primaria.withValues(alpha: .10),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.pets_outlined, color: primaria),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          cavalo.nome.isEmpty ? 'Sem nome' : cavalo.nome,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: corTexto,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          [
                            cavalo.raca.isEmpty
                                ? 'Raça não informada'
                                : cavalo.raca,
                            if (cavalo.sexo.isNotEmpty) cavalo.sexo,
                          ].join(' · '),
                          style: const TextStyle(
                            fontSize: 13,
                            color: corTextoSecundario,
                          ),
                        ),
                        Text(
                          cavalo.proprietarioNome.isEmpty
                              ? 'Proprietário não informado'
                              : cavalo.proprietarioNome,
                          style: const TextStyle(
                            fontSize: 12,
                            color: corTextoSecundario,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: cavalo.ativo
                          ? const Color(0xFFDCFCE7)
                          : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      cavalo.ativo ? 'Ativo' : 'Inativo',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: cavalo.ativo
                            ? const Color(0xFF166534)
                            : corTextoSecundario,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.chevron_right,
                    color: corTextoSecundario,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
