// ignore_for_file: deprecated_member_use

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../models/cavalo_model.dart';
import '../../models/despesa_cavalo_model.dart';
import '../../widgets/campos_grid.dart';
import 'cadastro_cavalo_page.dart';
import '../../widgets/desktop_window.dart';

class CavaloDetalhesPageDesktop extends StatelessWidget {
  final String cavaloId;

  const CavaloDetalhesPageDesktop({super.key, required this.cavaloId});

  static const Color primaria = Color(0xFF4F46E5);
  static const Color fundo = Color(0xFFF3F4F6);

  Widget _header(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 45, 20, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(.05), blurRadius: 10),
        ],
      ),
      child: Row(
        children: [
          InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: primaria.withOpacity(.10),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.arrow_back_rounded, color: primaria),
            ),
          ),
          const SizedBox(width: 15),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: primaria.withOpacity(.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.pets_rounded, color: primaria, size: 30),
          ),
          const SizedBox(width: 15),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Detalhes do Cavalo',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4),
                Text(
                  'Informações do animal',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _titulo(String texto, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: primaria.withOpacity(.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: primaria),
          ),
          const SizedBox(width: 10),
          Text(
            texto,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _campo(String titulo, String valor, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(.03), blurRadius: 8),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: primaria.withOpacity(.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: primaria, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  valor.trim().isEmpty ? '-' : valor,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _iconeCategoria(CategoriaDespesa categoria) {
    switch (categoria) {
      case CategoriaDespesa.remedio:
        return Icons.medication_outlined;
      case CategoriaDespesa.vacina:
        return Icons.vaccines_outlined;
      case CategoriaDespesa.alimento:
        return Icons.grass_outlined;
      case CategoriaDespesa.ferrageamento:
        return Icons.build_outlined;
      case CategoriaDespesa.veterinario:
        return Icons.local_hospital_outlined;
      case CategoriaDespesa.outro:
        return Icons.receipt_long_outlined;
    }
  }

  Color _corCategoria(CategoriaDespesa categoria) {
    switch (categoria) {
      case CategoriaDespesa.remedio:
        return Colors.redAccent;
      case CategoriaDespesa.vacina:
        return Colors.teal;
      case CategoriaDespesa.alimento:
        return Colors.orange;
      case CategoriaDespesa.ferrageamento:
        return Colors.brown;
      case CategoriaDespesa.veterinario:
        return Colors.indigo;
      case CategoriaDespesa.outro:
        return Colors.grey;
    }
  }

  String _formatarData(Timestamp ts) {
    final d = ts.toDate();
    return '${d.day.toString().padLeft(2, '0')}/'
        '${d.month.toString().padLeft(2, '0')}/'
        '${d.year}';
  }

  CollectionReference<Map<String, dynamic>> _despesasRef() {
    return FirebaseFirestore.instance
        .collection('cavalos')
        .doc(cavaloId)
        .collection('despesas');
  }

  // =====================================================
  // NOVA DESPESA
  // =====================================================

  Future<void> _abrirFormularioDespesa(BuildContext context) async {
    final descricaoController = TextEditingController();
    final valorController = TextEditingController();
    CategoriaDespesa categoria = CategoriaDespesa.remedio;
    DateTime data = DateTime.now();

    final salvar = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            final campoData = InkWell(
              onTap: () async {
                final novaData = await showDatePicker(
                  context: context,
                  initialDate: data,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );

                if (novaData != null) {
                  setStateDialog(() {
                    data = novaData;
                  });
                }
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 14,
                  horizontal: 12,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.event, size: 20),
                    const SizedBox(width: 10),
                    Text(
                      'Data: '
                      '${data.day.toString().padLeft(2, '0')}/'
                      '${data.month.toString().padLeft(2, '0')}/'
                      '${data.year}',
                    ),
                  ],
                ),
              ),
            );

            return AlertDialog(
              title: const Text('Nova Despesa'),
              content: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.85,
                ),
                child: SingleChildScrollView(
                  child: SizedBox(
                    width: 560,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<CategoriaDespesa>(
                                value: categoria,
                                decoration: const InputDecoration(
                                  labelText: 'Categoria',
                                ),
                                items: CategoriaDespesa.values
                                    .map(
                                      (c) => DropdownMenuItem(
                                        value: c,
                                        child: Text(c.label),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (v) {
                                  setStateDialog(() {
                                    categoria = v ?? CategoriaDespesa.remedio;
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextField(
                                controller: valorController,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                decoration: const InputDecoration(
                                  labelText: 'Valor',
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: campoData),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextField(
                                controller: descricaoController,
                                decoration: const InputDecoration(
                                  labelText: 'Descrição',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Salvar'),
                ),
              ],
            );
          },
        );
      },
    );

    if (salvar != true) {
      return;
    }

    final valor =
        double.tryParse(
          valorController.text.replaceAll('.', '').replaceAll(',', '.'),
        ) ??
        0;

    try {
      final despesa = DespesaCavaloModel(
        id: '',
        categoria: categoria,
        descricao: descricaoController.text.trim(),
        valor: valor,
        data: Timestamp.fromDate(data),
      );

      await _despesasRef().add(despesa.toMap());

      if (!context.mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Despesa adicionada')));
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro: $e')));
    }
  }

  Future<void> _confirmarExcluirDespesa(
    BuildContext context,
    String despesaId,
  ) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir despesa'),
        content: const Text('Deseja realmente excluir esta despesa?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    await _despesasRef().doc(despesaId).delete();
  }

  // =====================================================
  // SEÇÃO DE DESPESAS
  // =====================================================

  Widget _despesasSection(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _despesasRef().orderBy('data', descending: true).snapshots(),
      builder: (context, snapshot) {
        final despesas = (snapshot.data?.docs ?? [])
            .map((doc) => DespesaCavaloModel.fromMap(doc.data(), doc.id))
            .toList();

        final total = despesas.fold<double>(0, (soma, d) => soma + d.valor);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: _titulo('Despesas', Icons.receipt_long_rounded),
                ),
                InkWell(
                  onTap: () => _abrirFormularioDespesa(context),
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: primaria.withOpacity(.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.add, color: primaria, size: 20),
                  ),
                ),
              ],
            ),

            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: primaria.withOpacity(.08),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  const Icon(Icons.attach_money_rounded, color: primaria),
                  const SizedBox(width: 10),
                  const Text(
                    'Total gasto',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const Spacer(),
                  Text(
                    'R\$ ${total.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: primaria,
                    ),
                  ),
                ],
              ),
            ),

            if (snapshot.connectionState == ConnectionState.waiting)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (despesas.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Center(
                  child: Text(
                    'Nenhuma despesa registrada',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              )
            else
              ...despesas.map((d) {
                final cor = _corCategoria(d.categoria);

                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(.03),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: cor.withOpacity(.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          _iconeCategoria(d.categoria),
                          color: cor,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              d.categoria.label,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            if (d.descricao.isNotEmpty)
                              Text(
                                d.descricao,
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12.5,
                                ),
                              ),
                            Text(
                              _formatarData(d.data),
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        'R\$ ${d.valor.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: primaria,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.grey,
                          size: 20,
                        ),
                        onPressed: () =>
                            _confirmarExcluirDespesa(context, d.id),
                      ),
                    ],
                  ),
                );
              }),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: fundo,
      body: Column(
        children: [
          _header(context),
          Expanded(
            child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection('cavalos')
                  .doc(cavaloId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || !snapshot.data!.exists) {
                  return const Center(child: Text('Cavalo não encontrado'));
                }

                final cavalo = CavaloModel.fromMap(
                  snapshot.data!.data()!,
                  snapshot.data!.id,
                );

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  physics: const BouncingScrollPhysics(),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1440),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Coluna esquerda: foto + card com nome/valor
                          SizedBox(
                            width: 360,
                            child: Column(
                              children: [
                                if (cavalo.fotos.isNotEmpty)
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(20),
                                    child: Image.network(
                                      cavalo.fotos.first,
                                      height: 220,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                else
                                  Container(
                                    height: 180,
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color: primaria.withOpacity(.08),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Icon(
                                      Icons.pets_rounded,
                                      size: 60,
                                      color: primaria.withOpacity(.4),
                                    ),
                                  ),

                                const SizedBox(height: 20),

                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(24),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFF4F46E5),
                                        Color(0xFF7C7AF0),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(24),
                                    boxShadow: [
                                      BoxShadow(
                                        color: primaria.withOpacity(.25),
                                        blurRadius: 18,
                                        offset: const Offset(0, 8),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              cavalo.nome.isEmpty
                                                  ? 'Cavalo'
                                                  : cavalo.nome,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 22,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          InkWell(
                                            onTap: () {
                                              openDesktopWindow(
                                                context,
                                                title: 'Editar cavalo',
                                                icon: Icons.edit_rounded,
                                                builder: (_) =>
                                                    CadastroCavaloPage(
                                                      cavaloParaEditar: cavalo,
                                                    ),
                                              );
                                            },
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                            child: Container(
                                              padding: const EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                color: Colors.white.withOpacity(
                                                  .20,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              child: const Icon(
                                                Icons.edit_rounded,
                                                color: Colors.white,
                                                size: 20,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        cavalo.raca.isEmpty
                                            ? 'Raça não informada'
                                            : cavalo.raca,
                                        style: const TextStyle(
                                          color: Colors.white70,
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Total em despesas',
                                            style: TextStyle(
                                              color: Colors.white70,
                                              fontSize: 12,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          StreamBuilder<
                                            QuerySnapshot<Map<String, dynamic>>
                                          >(
                                            stream: _despesasRef().snapshots(),
                                            builder: (context, despesasSnapshot) {
                                              final total =
                                                  (despesasSnapshot
                                                              .data
                                                              ?.docs ??
                                                          [])
                                                      .map(
                                                        (doc) =>
                                                            DespesaCavaloModel.fromMap(
                                                              doc.data(),
                                                              doc.id,
                                                            ),
                                                      )
                                                      .fold<double>(
                                                        0,
                                                        (soma, d) =>
                                                            soma + d.valor,
                                                      );

                                              return Text(
                                                'R\$ ${total.toStringAsFixed(2)}',
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(width: 24),

                          // Coluna direita: dados, proprietário, despesas
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _titulo(
                                  'Dados do Animal',
                                  Icons.info_outline_rounded,
                                ),
                                CamposGrid(
                                  campos: [
                                    _campo(
                                      'Raça',
                                      cavalo.raca,
                                      Icons.category_outlined,
                                    ),
                                    _campo('Sexo', cavalo.sexo, Icons.male),
                                    _campo(
                                      'Pelagem',
                                      cavalo.pelagem,
                                      Icons.palette_outlined,
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 15),

                                _titulo(
                                  'Proprietário',
                                  Icons.person_outline_rounded,
                                ),
                                _campo(
                                  'Nome',
                                  cavalo.proprietarioNome,
                                  Icons.person_rounded,
                                ),

                                if (cavalo.observacoes.isNotEmpty) ...[
                                  const SizedBox(height: 15),
                                  _titulo('Observações', Icons.notes_rounded),
                                  _campo(
                                    'Notas',
                                    cavalo.observacoes,
                                    Icons.notes_rounded,
                                  ),
                                ],

                                const SizedBox(height: 15),

                                _campo(
                                  'Status',
                                  cavalo.ativo ? 'Ativo' : 'Inativo',
                                  cavalo.ativo
                                      ? Icons.check_circle_outline
                                      : Icons.cancel_outlined,
                                ),

                                const SizedBox(height: 15),

                                _despesasSection(context),

                                const SizedBox(height: 30),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
