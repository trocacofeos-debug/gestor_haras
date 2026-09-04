// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/financeiro_animais.dart';
import '../../models/relatorio_animais.dart';
import '../../services/financeiro_animais_service.dart';
import '../../services/relatorio_animais_pdf_service.dart';
import '../../widgets/app_dialogs.dart';
import '../../widgets/campos_grid.dart';
import '../../widgets/desktop_window.dart';
import '../home/admin_top_bar.dart';
import 'relatorio_pdf_preview_page.dart';

typedef VisualizarRelatorioAnimais =
    Future<void> Function(
      FinanceiroAnimaisDados dados,
      FiltrosRelatorioAnimais filtros,
    );

class RelatoriosAnimaisPage extends StatefulWidget {
  const RelatoriosAnimaisPage({super.key, this.carregar, this.visualizar});

  final Future<FinanceiroAnimaisDados> Function()? carregar;
  final VisualizarRelatorioAnimais? visualizar;

  @override
  State<RelatoriosAnimaisPage> createState() => _RelatoriosAnimaisPageState();
}

class _RelatoriosAnimaisPageState extends State<RelatoriosAnimaisPage> {
  late Future<FinanceiroAnimaisDados> dados;
  final animaisSelecionados = <String>{};
  TipoMovimentoAnimal? tipo;
  String? categoria;
  DateTimeRange? periodo;
  bool preparando = false;
  final moeda = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
  final data = DateFormat('dd/MM/yyyy');

  @override
  void initState() {
    super.initState();
    dados = _carregar();
  }

  Future<FinanceiroAnimaisDados> _carregar() =>
      widget.carregar?.call() ?? const FinanceiroAnimaisService().carregar();

  FiltrosRelatorioAnimais get filtros => FiltrosRelatorioAnimais(
    animalIds: Set.unmodifiable(animaisSelecionados),
    tipo: tipo,
    categoria: categoria,
    inicio: periodo?.start,
    fim: periodo?.end,
  );

  Future<void> _atualizar() async {
    final futuro = _carregar();
    setState(() => dados = futuro);
    try {
      await futuro;
    } catch (_) {}
  }

  Future<void> _selecionarPeriodo() async {
    final hoje = DateTime.now();
    final valor = await showAppDateRangePicker(
      context: context,
      firstDate: DateTime(1900),
      lastDate: DateTime(hoje.year + 10, 12, 31),
      initialDateRange: periodo,
      helpText: 'Período do relatório',
      saveText: 'Aplicar',
      cancelText: 'Cancelar',
      confirmText: 'Aplicar',
      fieldStartLabelText: 'Data inicial',
      fieldEndLabelText: 'Data final',
    );
    if (valor != null && mounted) setState(() => periodo = valor);
  }

  Future<void> _selecionarAnimais(Map<String, String> animais) async {
    final temporarios = {...animaisSelecionados};
    final ordenados = animais.entries.toList()
      ..sort((a, b) => a.value.toLowerCase().compareTo(b.value.toLowerCase()));
    final resultado = await showAppDialog<Set<String>>(
      context: context,
      title: 'Selecionar animais',
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, atualizar) => AlertDialog(
          title: const Text('Animais do relatório'),
          content: SizedBox(
            width: 520,
            height: 430,
            child: Column(
              children: [
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Selecionar todos'),
                  value:
                      ordenados.isNotEmpty &&
                      ordenados.every((item) => temporarios.contains(item.key)),
                  onChanged: ordenados.isEmpty
                      ? null
                      : (marcado) => atualizar(() {
                          if (marcado == true) {
                            temporarios.addAll(
                              ordenados.map((item) => item.key),
                            );
                          } else {
                            temporarios.clear();
                          }
                        }),
                ),
                const Divider(height: 1),
                Expanded(
                  child: ordenados.isEmpty
                      ? const Center(child: Text('Nenhum animal cadastrado.'))
                      : ListView.builder(
                          itemCount: ordenados.length,
                          itemBuilder: (_, indice) {
                            final animal = ordenados[indice];
                            return CheckboxListTile(
                              key: ValueKey('relatorio-animal-${animal.key}'),
                              title: Text(animal.value),
                              value: temporarios.contains(animal.key),
                              onChanged: (marcado) => atualizar(() {
                                if (marcado == true) {
                                  temporarios.add(animal.key);
                                } else {
                                  temporarios.remove(animal.key);
                                }
                              }),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, temporarios),
              child: Text('Aplicar (${temporarios.length})'),
            ),
          ],
        ),
      ),
    );
    if (resultado != null && mounted) {
      setState(() {
        animaisSelecionados
          ..clear()
          ..addAll(resultado);
      });
    }
  }

  Future<void> _visualizar(FinanceiroAnimaisDados conteudo) async {
    final movimentos = filtros.aplicar(conteudo.movimentos);
    if (movimentos.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não há lançamentos para visualizar.')),
      );
      return;
    }
    setState(() => preparando = true);
    try {
      if (widget.visualizar != null) {
        await widget.visualizar!(conteudo, filtros);
      } else {
        final bytes = await const RelatorioAnimaisPdfService().gerar(
          dados: conteudo,
          filtros: filtros,
        );
        if (!mounted) return;
        await openDesktopWindow<void>(
          context,
          title: 'Pré-visualização do relatório',
          icon: Icons.picture_as_pdf_outlined,
          width: 1080,
          height: 790,
          builder: (_) => RelatorioPdfPreviewPage(bytes: bytes),
        );
      }
    } catch (erro) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Não foi possível abrir a pré-visualização: $erro'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => preparando = false);
    }
  }

  void _limpar() => setState(() {
    animaisSelecionados.clear();
    tipo = null;
    categoria = null;
    periodo = null;
  });

  InputDecoration _decoracao(String label) => InputDecoration(
    labelText: label,
    isDense: true,
    filled: true,
    fillColor: Colors.white,
    border: const OutlineInputBorder(),
  );

  Widget _resumo(String titulo, int centavos, Color cor) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(color: const Color(0xFFE5E7EB)),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(titulo, style: const TextStyle(color: Color(0xFF6B7280))),
        const SizedBox(height: 2),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            moeda.format(centavos / 100),
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: cor,
            ),
          ),
        ),
      ],
    ),
  );

  Widget _botaoVisualizar(FinanceiroAnimaisDados conteudo) => FilledButton.icon(
    key: const ValueKey('visualizar-relatorio-pdf'),
    onPressed: preparando ? null : () => _visualizar(conteudo),
    icon: preparando
        ? const SizedBox.square(
            dimension: 15,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white,
            ),
          )
        : const Icon(Icons.picture_as_pdf_outlined, size: 18),
    label: const Text('Visualizar relatório'),
  );

  Widget _conteudo(FinanceiroAnimaisDados conteudo, bool desktop) {
    animaisSelecionados.removeWhere((id) => !conteudo.animais.containsKey(id));
    final categorias =
        conteudo.movimentos
            .where((item) => item.tipo == TipoMovimentoAnimal.despesa)
            .map((item) => item.categoria)
            .toSet()
            .toList()
          ..sort();
    if (categoria != null && !categorias.contains(categoria)) categoria = null;
    final movimentos = filtros.aplicar(conteudo.movimentos);
    final resumo = ResumoFinanceiroAnimais.calcular(movimentos);
    final porAnimal = resumirPorAnimal(movimentos);

    return RefreshIndicator(
      onRefresh: _atualizar,
      child: ListView(
        key: const PageStorageKey('relatorios-animais-scroll'),
        padding: EdgeInsets.all(desktop ? 14 : 10),
        children: [
          if (desktop)
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Relatórios dos animais',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  tooltip: 'Atualizar dados',
                  onPressed: _atualizar,
                  icon: const Icon(Icons.refresh),
                ),
                const SizedBox(width: 4),
                _botaoVisualizar(conteudo),
              ],
            )
          else
            Column(
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Relatórios dos animais',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      tooltip: 'Atualizar dados',
                      onPressed: _atualizar,
                      icon: const Icon(Icons.refresh),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                SizedBox(
                  width: double.infinity,
                  height: 40,
                  child: _botaoVisualizar(conteudo),
                ),
              ],
            ),
          const SizedBox(height: 8),
          Material(
            color: Colors.white,
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            child: ExpansionTile(
              tilePadding: const EdgeInsets.symmetric(horizontal: 12),
              childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
              leading: const Icon(Icons.filter_alt_outlined, size: 20),
              title: Text(
                animaisSelecionados.isEmpty &&
                        tipo == null &&
                        categoria == null &&
                        periodo == null
                    ? 'Filtros do relatório'
                    : 'Filtros ativos',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              children: [
                CamposGrid(
                  maximoColunas: desktop ? 2 : 1,
                  larguraMinimaColuna: 260,
                  campos: [
                    OutlinedButton.icon(
                      key: const ValueKey('selecionar-animais-relatorio'),
                      onPressed: () => _selecionarAnimais(conteudo.animais),
                      icon: const Icon(Icons.pets_outlined),
                      label: Text(
                        animaisSelecionados.isEmpty
                            ? 'Todos os animais'
                            : '${animaisSelecionados.length} animal(is) selecionado(s)',
                      ),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(46),
                        alignment: Alignment.centerLeft,
                      ),
                    ),
                    DropdownButtonFormField<String>(
                      key: ValueKey('relatorio-tipo-${tipo?.name ?? 'todos'}'),
                      initialValue: tipo?.name ?? '',
                      isExpanded: true,
                      decoration: _decoracao('Tipo de lançamento'),
                      items: const [
                        DropdownMenuItem(
                          value: '',
                          child: Text('Receitas e despesas'),
                        ),
                        DropdownMenuItem(
                          value: 'receita',
                          child: Text('Somente receitas'),
                        ),
                        DropdownMenuItem(
                          value: 'despesa',
                          child: Text('Somente despesas'),
                        ),
                      ],
                      onChanged: (valor) => setState(() {
                        tipo = switch (valor) {
                          'receita' => TipoMovimentoAnimal.receita,
                          'despesa' => TipoMovimentoAnimal.despesa,
                          _ => null,
                        };
                        if (tipo == TipoMovimentoAnimal.receita) {
                          categoria = null;
                        }
                      }),
                    ),
                    DropdownButtonFormField<String>(
                      key: ValueKey(
                        'relatorio-categoria-${categoria ?? 'todas'}',
                      ),
                      initialValue: categoria ?? '',
                      isExpanded: true,
                      decoration: _decoracao('Categoria'),
                      items: [
                        const DropdownMenuItem(
                          value: '',
                          child: Text('Todas as categorias'),
                        ),
                        for (final item in categorias)
                          DropdownMenuItem(value: item, child: Text(item)),
                      ],
                      onChanged: tipo == TipoMovimentoAnimal.receita
                          ? null
                          : (valor) => setState(
                              () => categoria = valor == '' ? null : valor,
                            ),
                    ),
                    OutlinedButton.icon(
                      key: const ValueKey('periodo-relatorio'),
                      onPressed: _selecionarPeriodo,
                      icon: const Icon(Icons.date_range_outlined),
                      label: Text(
                        periodo == null
                            ? 'Todo o período'
                            : '${data.format(periodo!.start)} a ${data.format(periodo!.end)}',
                      ),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(46),
                        alignment: Alignment.centerLeft,
                      ),
                    ),
                  ],
                ),
                Wrap(
                  spacing: 8,
                  children: [
                    TextButton(
                      onPressed: () {
                        final hoje = DateTime.now();
                        setState(
                          () => periodo = DateTimeRange(
                            start: DateTime(hoje.year, hoje.month),
                            end: DateTime(hoje.year, hoje.month + 1, 0),
                          ),
                        );
                      },
                      child: const Text('Este mês'),
                    ),
                    TextButton(
                      onPressed: _limpar,
                      child: const Text('Limpar filtros'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _resumo(
                  'Receitas',
                  resumo.receitas,
                  const Color(0xFF15803D),
                ),
              ),
              const SizedBox(width: 7),
              Expanded(
                child: _resumo(
                  'Despesas',
                  resumo.despesas,
                  const Color(0xFFB91C1C),
                ),
              ),
              const SizedBox(width: 7),
              Expanded(
                child: _resumo(
                  'Saldo',
                  resumo.saldo,
                  resumo.saldo < 0
                      ? const Color(0xFFB91C1C)
                      : const Color(0xFF111827),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${movimentos.length} lançamento(s) de ${porAnimal.length} animal(is)',
            style: const TextStyle(color: Color(0xFF6B7280)),
          ),
          const SizedBox(height: 6),
          _painelResultados(porAnimal, movimentos, desktop),
        ],
      ),
    );
  }

  Widget _painelResultados(
    List<ResumoAnimalRelatorio> porAnimal,
    List<MovimentoAnimal> movimentos,
    bool desktop,
  ) => DefaultTabController(
    length: 2,
    child: Column(
      children: [
        const Material(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(10)),
          child: TabBar(
            tabs: [
              Tab(height: 40, text: 'Resumo por animal'),
              Tab(height: 40, text: 'Lançamentos detalhados'),
            ],
          ),
        ),
        const SizedBox(height: 6),
        SizedBox(
          height: desktop ? 310 : 270,
          child: TabBarView(
            children: [_listaResumos(porAnimal), _listaMovimentos(movimentos)],
          ),
        ),
      ],
    ),
  );

  Widget _listaResumos(List<ResumoAnimalRelatorio> itens) {
    if (itens.isEmpty) return _vazioResultados();
    return Card(
      margin: EdgeInsets.zero,
      child: ListView.separated(
        padding: const EdgeInsets.all(8),
        itemCount: itens.length,
        separatorBuilder: (_, _) => const Divider(height: 8),
        itemBuilder: (_, indice) {
          final animal = itens[indice];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 17,
                  child: Icon(Icons.pets_outlined, size: 17),
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        animal.animalNome,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      Text(
                        '${animal.lancamentos} lançamento(s) • Receitas ${moeda.format(animal.receitas / 100)} • Despesas ${moeda.format(animal.despesas / 100)}',
                        style: const TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  moeda.format(animal.saldo / 100),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: animal.saldo < 0
                        ? const Color(0xFFB91C1C)
                        : const Color(0xFF15803D),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _listaMovimentos(List<MovimentoAnimal> itens) {
    if (itens.isEmpty) return _vazioResultados();
    return Card(
      margin: EdgeInsets.zero,
      child: ListView.separated(
        padding: const EdgeInsets.all(8),
        itemCount: itens.length,
        separatorBuilder: (_, _) => const Divider(height: 8),
        itemBuilder: (_, indice) {
          final item = itens[indice];
          final receita = item.tipo == TipoMovimentoAnimal.receita;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
            child: Row(
              children: [
                Icon(
                  receita
                      ? Icons.arrow_upward_rounded
                      : Icons.arrow_downward_rounded,
                  size: 18,
                  color: receita
                      ? const Color(0xFF15803D)
                      : const Color(0xFFB91C1C),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.descricao,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        '${item.animalNome} • ${item.categoria} • ${item.data == null ? 'Sem data' : data.format(item.data!)}',
                        style: const TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  moeda.format(item.centavos / 100),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: receita
                        ? const Color(0xFF15803D)
                        : const Color(0xFFB91C1C),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _vazioResultados() => const Card(
    margin: EdgeInsets.zero,
    child: Center(
      child: Text('Nenhum lançamento encontrado para os filtros selecionados.'),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final desktop = MediaQuery.sizeOf(context).width >= 900;
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: desktop ? null : AppBar(title: const Text('Relatórios')),
      body: Column(
        children: [
          if (desktop) const AdminTopBar(),
          Expanded(
            child: FutureBuilder<FinanceiroAnimaisDados>(
              future: dados,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError || !snapshot.hasData) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.cloud_off_outlined,
                          size: 42,
                          color: Color(0xFF6B7280),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Não foi possível carregar o relatório completo.',
                        ),
                        const SizedBox(height: 10),
                        OutlinedButton(
                          onPressed: _atualizar,
                          child: const Text('Tentar novamente'),
                        ),
                      ],
                    ),
                  );
                }
                return _conteudo(snapshot.data!, desktop);
              },
            ),
          ),
        ],
      ),
    );
  }
}
