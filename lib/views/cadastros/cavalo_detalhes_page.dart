// ignore_for_file: deprecated_member_use

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../widgets/app_dialogs.dart';

import '../../models/cavalo_model.dart';
import '../../models/ficha_abccmm.dart';
import '../../widgets/genealogia_abccmm_view.dart';
import '../../widgets/campos_grid.dart';
import '../../widgets/desktop_window.dart';
import '../../models/despesa_cavalo_model.dart';
import 'cadastro_cavalo_page.dart';

Future<void> abrirPopupDetalhesCavalo(BuildContext context, String cavaloId) {
  return showAppDialog<void>(
    context: context,
      title: 'Detalhes do animal',
    builder: (dialogContext) => Dialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1160, maxHeight: 800),
        child: SizedBox(
          width: double.infinity,
          height: MediaQuery.sizeOf(dialogContext).height * .92,
          child: DesktopWindowScope(
            child: CavaloDetalhesPage(cavaloId: cavaloId),
          ),
        ),
      ),
    ),
  );
}

class CavaloDetalhesPage extends StatelessWidget {
  final String cavaloId;

  const CavaloDetalhesPage({super.key, required this.cavaloId});

  static const Color primaria = Color(0xFF374151);
  static const Color fundo = Colors.white;

  Widget _header(BuildContext context, [CavaloModel? cavalo]) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
      ),
      child: Row(
        children: [
          IconButton(
            tooltip: DesktopWindowScope.isInside(context) ? 'Fechar' : 'Voltar',
            onPressed: () => Navigator.pop(context),
            icon: Icon(
              DesktopWindowScope.isInside(context)
                  ? Icons.close
                  : Icons.arrow_back,
              size: 20,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              cavalo == null || cavalo.nome.isEmpty
                  ? 'Detalhes do cavalo'
                  : cavalo.nome,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ),
          if (cavalo != null)
            TextButton.icon(
              onPressed: () => openDesktopWindow(
                context,
                title: 'Editar cavalo',
                icon: Icons.edit_outlined,
                builder: (_) => CadastroCavaloPage(cavaloParaEditar: cavalo),
              ),
              icon: const Icon(Icons.edit_outlined, size: 18),
              label: const Text('Editar'),
              style: TextButton.styleFrom(foregroundColor: primaria),
            ),
        ],
      ),
    );
  }

  Widget _titulo(String texto, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        texto,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: primaria,
        ),
      ),
    );
  }

  Widget _campo(String titulo, String valor, IconData icon) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
          ),
          const SizedBox(height: 2),
          SelectableText(
            valor.trim().isEmpty ? '—' : valor,
            style: const TextStyle(fontSize: 13, color: Color(0xFF111827)),
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

  CollectionReference<Map<String, dynamic>> _receitasRef() {
    return FirebaseFirestore.instance
        .collection('cavalos')
        .doc(cavaloId)
        .collection('receitas');
  }

  // =====================================================
  // NOVA DESPESA
  // =====================================================

  Future<void> _abrirFormularioDespesa(BuildContext context) async {
    final descricaoController = TextEditingController();
    final valorController = TextEditingController();
    CategoriaDespesa categoria = CategoriaDespesa.remedio;
    DateTime data = DateTime.now();

    final salvar = await showAppDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text('Nova Despesa'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DropdownButtonFormField<CategoriaDespesa>(
                      value: categoria,
                      decoration: const InputDecoration(labelText: 'Categoria'),
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
                    const SizedBox(height: 12),
                    TextField(
                      controller: descricaoController,
                      decoration: const InputDecoration(labelText: 'Descrição'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: valorController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(labelText: 'Valor'),
                    ),
                    const SizedBox(height: 12),
                    InkWell(
                      onTap: () async {
                        final novaData = await showAppDatePicker(
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
                    ),
                  ],
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
    final confirmar = await showAppDialog<bool>(
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
                  borderRadius: BorderRadius.circular(4),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: primaria.withOpacity(.12),
                      borderRadius: BorderRadius.circular(4),
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
                borderRadius: BorderRadius.circular(4),
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
                  borderRadius: BorderRadius.circular(4),
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
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: cor.withOpacity(.12),
                          borderRadius: BorderRadius.circular(4),
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

  Future<void> _abrirFormularioReceita(BuildContext context) async {
    final descricaoController = TextEditingController();
    final valorController = TextEditingController();
    DateTime data = DateTime.now();

    final salvar = await showAppDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          title: const Text('Nova Receita'),
          content: SingleChildScrollView(
            child: SizedBox(
              width: 460,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: descricaoController,
                    decoration: const InputDecoration(
                      labelText: 'Descrição',
                      hintText: 'Ex.: prêmio, aluguel ou venda',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: valorController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(labelText: 'Valor'),
                  ),
                  const SizedBox(height: 12),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.event_outlined),
                    title: Text(
                      'Data: ${data.day.toString().padLeft(2, '0')}/'
                      '${data.month.toString().padLeft(2, '0')}/${data.year}',
                    ),
                    onTap: () async {
                      final selecionada = await showAppDatePicker(
                        context: context,
                        initialDate: data,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (selecionada != null) {
                        setStateDialog(() => data = selecionada);
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Salvar'),
            ),
          ],
        ),
      ),
    );

    if (salvar != true) return;

    final valor =
        double.tryParse(
          valorController.text.replaceAll('.', '').replaceAll(',', '.'),
        ) ??
        0;
    if (valor <= 0) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Informe um valor válido para a receita'),
          ),
        );
      }
      return;
    }

    await _receitasRef().add({
      'descricao': descricaoController.text.trim(),
      'valor': valor,
      'data': Timestamp.fromDate(data),
    });

    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Receita adicionada')));
    }
  }

  Future<void> _confirmarExcluirReceita(
    BuildContext context,
    String receitaId,
  ) async {
    final confirmar = await showAppDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir receita'),
        content: const Text('Deseja realmente excluir esta receita?'),
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
    if (confirmar == true) await _receitasRef().doc(receitaId).delete();
  }

  Widget _receitasSection(BuildContext context) {
    const verde = Color(0xFF059669);
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _receitasRef().orderBy('data', descending: true).snapshots(),
      builder: (context, snapshot) {
        final receitas = snapshot.data?.docs ?? [];
        final total = receitas.fold<double>(
          0,
          (soma, doc) => soma + ((doc.data()['valor'] ?? 0) as num).toDouble(),
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: _titulo('Receitas', Icons.trending_up_rounded)),
                InkWell(
                  onTap: () => _abrirFormularioReceita(context),
                  borderRadius: BorderRadius.circular(4),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: verde.withOpacity(.12),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Icon(Icons.add, color: verde, size: 20),
                  ),
                ),
              ],
            ),
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: verde.withOpacity(.08),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                children: [
                  const Icon(Icons.payments_outlined, color: verde),
                  const SizedBox(width: 10),
                  const Text(
                    'Total recebido',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const Spacer(),
                  Text(
                    'R\$ ${total.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: verde,
                    ),
                  ),
                ],
              ),
            ),
            if (snapshot.connectionState == ConnectionState.waiting)
              const Center(child: CircularProgressIndicator())
            else if (receitas.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Center(
                  child: Text(
                    'Nenhuma receita registrada',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              )
            else
              ...receitas.map((doc) {
                final dados = doc.data();
                final valor = ((dados['valor'] ?? 0) as num).toDouble();
                final data = dados['data'] is Timestamp
                    ? dados['data'] as Timestamp
                    : Timestamp.now();
                final descricao = (dados['descricao'] ?? '').toString();
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: verde.withOpacity(.12),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Icon(
                          Icons.arrow_upward_rounded,
                          color: verde,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              descricao.isEmpty ? 'Receita' : descricao,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              _formatarData(data),
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        'R\$ ${valor.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: verde,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        onPressed: () =>
                            _confirmarExcluirReceita(context, doc.id),
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.grey,
                          size: 20,
                        ),
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

  Widget _resumoFinanceiro() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _despesasRef().snapshots(),
      builder: (context, despesasSnapshot) {
        final despesas = (despesasSnapshot.data?.docs ?? []).fold<double>(
          0,
          (soma, doc) => soma + ((doc.data()['valor'] ?? 0) as num).toDouble(),
        );
        return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: _receitasRef().snapshots(),
          builder: (context, receitasSnapshot) {
            final receitas = (receitasSnapshot.data?.docs ?? []).fold<double>(
              0,
              (soma, doc) =>
                  soma + ((doc.data()['valor'] ?? 0) as num).toDouble(),
            );
            final saldo = receitas - despesas;
            Widget item(String titulo, double valor, Color cor) => Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo,
                    style: const TextStyle(
                      color: Color(0xFF6B7280),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 2),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'R\$ ${valor.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: cor,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            );
            return Row(
              children: [
                item('Despesas', despesas, primaria),
                const SizedBox(width: 16),
                item('Receitas', receitas, primaria),
                const SizedBox(width: 16),
                item('Saldo', saldo, primaria),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _abrirHistorico(BuildContext context, bool despesas) {
    return showAppDialog<void>(
      context: context,
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        child: SizedBox(
          width: 720,
          height: MediaQuery.sizeOf(dialogContext).height * .8,
          child: Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              title: Text(
                despesas ? 'Histórico de despesas' : 'Histórico de receitas',
              ),
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.transparent,
              leading: IconButton(
                tooltip: 'Fechar histórico',
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(dialogContext),
              ),
            ),
            body: Builder(
              builder: (historyContext) => SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: despesas
                    ? _despesasSection(historyContext)
                    : _receitasSection(historyContext),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _dados(CavaloModel cavalo, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _titulo('Dados do animal', Icons.info_outline),
        CamposGrid(
          larguraMinimaColuna: 220,
          maximoColunas: 2,
          campos: [
            _campo('Raça', cavalo.raca, Icons.category_outlined),
            _campo('Sexo', cavalo.sexo, Icons.pets_outlined),
            _campo('Pelagem', cavalo.pelagem, Icons.palette_outlined),
            if (cavalo.registroAbccmm.isNotEmpty)
              _campo(
                'Registro ABCCMM',
                cavalo.registroAbccmm,
                Icons.badge_outlined,
              ),
            if (cavalo.pai.isNotEmpty)
              _campo('Pai', cavalo.pai, Icons.account_tree_outlined),
            if (cavalo.mae.isNotEmpty)
              _campo('Mãe', cavalo.mae, Icons.account_tree_outlined),
            _campo(
              'Altura',
              cavalo.altura == null
                  ? '—'
                  : '${cavalo.altura!.toString().replaceAll('.', ',')} m',
              Icons.height,
            ),
            _campo(
              'Peso',
              cavalo.peso == null
                  ? '—'
                  : '${cavalo.peso!.toString().replaceFirst(RegExp(r'\.0$'), '').replaceAll('.', ',')} kg',
              Icons.monitor_weight_outlined,
            ),
            _campo(
              'Status',
              cavalo.ativo ? 'Ativo' : 'Inativo',
              Icons.check_circle_outline,
            ),
          ],
        ),
        const SizedBox(height: 12),
        _campo('Proprietário', cavalo.proprietarioNome, Icons.person_outline),
        if (cavalo.genealogiaAbccmm != null ||
            cavalo.fichaAbccmm.toMap().values.any((v) => v != null && v != ''))
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              icon: const Icon(Icons.badge_outlined),
              label: const Text('Ver ficha ABCCMM'),
              onPressed: () => _mostrarFichaAbccmm(context, cavalo),
            ),
          ),
        if (cavalo.observacoes.isNotEmpty) ...[
          const SizedBox(height: 12),
          _titulo('Observações', Icons.notes_outlined),
          Text(
            cavalo.observacoes,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 13, color: Color(0xFF374151)),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: () => showAppDialog<void>(
                context: context,
                builder: (noteContext) => AlertDialog(
                  title: const Text('Observações'),
                  content: SingleChildScrollView(
                    child: SelectableText(cavalo.observacoes),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(noteContext),
                      child: const Text('Fechar'),
                    ),
                  ],
                ),
              ),
              child: const Text('Ler observações completas'),
            ),
          ),
        ],
      ],
    );
  }

  void _mostrarFichaAbccmm(BuildContext context, CavaloModel cavalo) {
    final ficha = cavalo.fichaAbccmm;
    final mapa = ficha.toMap();
    final dados = <String, String>{
      'Nome': cavalo.nome,
      'Registro ABCCMM': cavalo.registroAbccmm,
      'Data de nascimento': FichaAbccmm.formatarData(ficha.dataNascimento),
      'Idade': ficha.idadeEm(DateTime.now()),
      'Sexo': cavalo.sexo,
      'Pelagem': cavalo.pelagem,
      'Registrado': ficha.registrado == null
          ? ''
          : (ficha.registrado! ? 'Sim' : 'Não'),
      'Vivo': ficha.vivo == null ? '' : (ficha.vivo! ? 'Sim' : 'Não'),
      'Bloqueado': ficha.bloqueado == null
          ? ''
          : (ficha.bloqueado! ? 'Sim' : 'Não'),
      'Pai': cavalo.pai,
      'Mãe': cavalo.mae,
      for (final e in FichaAbccmm.rotulos.entries)
        e.value: mapa[e.key] as String,
    };
    showAppDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Ficha ABCCMM'),
        content: SizedBox(
          width: 560,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Dados informados no haras. Esta ficha não substitui o certificado oficial.',
                ),
                const SizedBox(height: 16),
                for (final e in dados.entries.where((e) => e.value.isNotEmpty))
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: SelectableText('${e.key}: ${e.value}'),
                  ),
                if (cavalo.genealogiaAbccmm != null) ...[
                  const Text(
                    'Genealogia',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  GenealogiaAbccmmView(genealogia: cavalo.genealogiaAbccmm!),
                ],
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  Widget _foto(CavaloModel cavalo) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: SizedBox(
        height: 140,
        width: double.infinity,
        child: cavalo.fotos.isEmpty
            ? const ColoredBox(
                color: Color(0xFFF3F4F6),
                child: Icon(
                  Icons.pets_outlined,
                  color: Color(0xFF9CA3AF),
                  size: 32,
                ),
              )
            : Image.network(
                cavalo.fotos.first,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => const ColoredBox(
                  color: Color(0xFFF3F4F6),
                  child: Icon(
                    Icons.broken_image_outlined,
                    color: Color(0xFF9CA3AF),
                  ),
                ),
              ),
      ),
    );
  }

  Widget _financeiro(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _titulo('Resumo financeiro', Icons.account_balance_wallet_outlined),
        _resumoFinanceiro(),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          onPressed: () => _abrirHistorico(context, true),
          icon: const Icon(Icons.receipt_long_outlined, size: 18),
          label: const Text('Ver despesas'),
          style: OutlinedButton.styleFrom(foregroundColor: primaria),
        ),
        const SizedBox(height: 6),
        OutlinedButton.icon(
          onPressed: () => _abrirHistorico(context, false),
          icon: const Icon(Icons.payments_outlined, size: 18),
          label: const Text('Ver receitas'),
          style: OutlinedButton.styleFrom(foregroundColor: primaria),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: fundo,
      body: SafeArea(
        child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection('cavalos')
              .doc(cavaloId)
              .snapshots(),
          builder: (context, snapshot) {
            final cavalo = snapshot.hasData && snapshot.data!.exists
                ? CavaloModel.fromMap(snapshot.data!.data()!, snapshot.data!.id)
                : null;
            return Column(
              children: [
                _header(context, cavalo),
                Expanded(
                  child: cavalo == null
                      ? Center(
                          child: snapshot.hasError
                              ? const Text('Não foi possível carregar o cavalo')
                              : snapshot.connectionState ==
                                    ConnectionState.waiting
                              ? const CircularProgressIndicator()
                              : const Text('Cavalo não encontrado'),
                        )
                      : LayoutBuilder(
                          builder: (context, constraints) {
                            if (constraints.maxWidth < 900) {
                              return SingleChildScrollView(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    _foto(cavalo),
                                    const SizedBox(height: 16),
                                    _dados(cavalo, context),
                                    const SizedBox(height: 16),
                                    _financeiro(context),
                                  ],
                                ),
                              );
                            }
                            return Padding(
                              padding: const EdgeInsets.all(16),
                              child: Align(
                                alignment: Alignment.topCenter,
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  alignment: Alignment.topCenter,
                                  child: SizedBox(
                                    width: constraints.maxWidth - 32,
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          flex: 2,
                                          child: _dados(cavalo, context),
                                        ),
                                        const SizedBox(width: 24),
                                        Expanded(
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              _foto(cavalo),
                                              const SizedBox(height: 16),
                                              _financeiro(context),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}


