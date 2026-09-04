import 'package:flutter/material.dart';
import '../../widgets/app_dialogs.dart';
import 'package:intl/intl.dart';
import '../../models/financeiro_animais.dart';
import '../../services/financeiro_animais_service.dart';
import '../../widgets/campos_grid.dart';
import '../cadastros/cavalo_detalhes_page.dart';
import '../home/admin_top_bar.dart';
import 'cadastro_movimento_animal_dialog.dart';
import 'financeiro_animais_mobile.dart';

class FinanceiroAnimaisPage extends StatefulWidget {
  final Future<FinanceiroAnimaisDados> Function()? carregar;
  final Future<void> Function(NovoMovimentoAnimal movimento)? salvar;
  final bool embedded;
  const FinanceiroAnimaisPage({
    super.key,
    this.carregar,
    this.salvar,
    this.embedded = false,
  });

  @override
  State<FinanceiroAnimaisPage> createState() => _FinanceiroAnimaisPageState();
}

class _FinanceiroAnimaisPageState extends State<FinanceiroAnimaisPage> {
  late Future<FinanceiroAnimaisDados> _dados;
  String? _animalId;
  TipoMovimentoAnimal? _tipo;
  DateTimeRange? _periodo;
  final _moeda = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
  final _data = DateFormat('dd/MM/yyyy');
  static const _borda = Color(0xFFE5E7EB);
  static const _cinza = Color(0xFF6B7280);

  @override
  void initState() {
    super.initState();
    _dados = _carregar();
  }

  Future<FinanceiroAnimaisDados> _carregar() =>
      widget.carregar?.call() ?? const FinanceiroAnimaisService().carregar();

  Future<void> _atualizar() async {
    final atualizacao = _carregar();
    setState(() {
      _dados = atualizacao;
    });
    try {
      await atualizacao;
    } catch (_) {
      // A falha é mostrada pelo FutureBuilder, inclusive após puxar para atualizar.
    }
  }

  Future<void> _selecionarPeriodo() async {
    final agora = DateTime.now();
    final periodo = await showAppDateRangePicker(
      context: context,
      firstDate: DateTime(1900),
      lastDate: DateTime(agora.year + 10, 12, 31),
      initialDateRange: _periodo,
      helpText: 'Selecione o período',
      saveText: 'Aplicar',
      cancelText: 'Cancelar',
      confirmText: 'Aplicar',
      fieldStartLabelText: 'Data inicial',
      fieldEndLabelText: 'Data final',
    );
    if (periodo != null && mounted) setState(() => _periodo = periodo);
  }

  Future<void> _abrirAnimal(String id) async {
    await abrirPopupDetalhesCavalo(context, id);
    if (mounted) _atualizar();
  }

  Future<void> _novoLancamento(FinanceiroAnimaisDados dados) async {
    if (dados.animais.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cadastre um animal antes de criar um lançamento.'),
        ),
      );
      return;
    }
    final movimento = await showAppDialog<NovoMovimentoAnimal>(
      context: context,
      builder: (_) => CadastroMovimentoAnimalDialog(
        animais: dados.animais,
        animalInicial: dados.animais.containsKey(_animalId) ? _animalId : null,
      ),
    );
    if (movimento == null || !mounted) return;
    try {
      if (widget.salvar != null) {
        await widget.salvar!(movimento);
      } else {
        await const FinanceiroAnimaisService().cadastrar(movimento);
      }
      if (!mounted) return;
      setState(() {
        _animalId = movimento.animalId;
        _tipo = movimento.tipo;
      });
      await _atualizar();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            movimento.tipo == TipoMovimentoAnimal.receita
                ? 'Receita adicionada ao animal.'
                : 'Despesa adicionada ao animal.',
          ),
        ),
      );
    } catch (erro) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Não foi possível salvar: $erro')));
    }
  }

  Widget _cartao(String titulo, int centavos, Color cor) => Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(color: _borda),
      borderRadius: BorderRadius.circular(6),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(titulo, style: const TextStyle(color: _cinza)),
        const SizedBox(height: 8),
        Text(
          _moeda.format(centavos / 100),
          style: TextStyle(
            color: cor,
            fontWeight: FontWeight.w600,
            fontSize: 23,
          ),
        ),
      ],
    ),
  );

  InputDecoration _decoracao(String label) => InputDecoration(
    labelText: label,
    isDense: true,
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
  );

  Widget _conteudo(FinanceiroAnimaisDados dados, double largura) {
    final animalId = dados.animais.containsKey(_animalId) ? _animalId : null;
    final animais = dados.animais.entries.toList()
      ..sort((a, b) => a.value.toLowerCase().compareTo(b.value.toLowerCase()));
    final movimentos = dados.filtrar(
      animalId: animalId,
      tipo: _tipo,
      inicio: _periodo?.start,
      fim: _periodo?.end,
    );
    final resumo = ResumoFinanceiroAnimais.calcular(movimentos);
    final semData = dados.movimentos.where((m) => m.data == null).length;

    if (widget.embedded) {
      return _conteudoCompacto(
        dados: dados,
        animais: animais,
        animalId: animalId,
        movimentos: movimentos,
        resumo: resumo,
        semData: semData,
      );
    }

    if (largura < 900) {
      return FinanceiroAnimaisMobile(
        dados: dados,
        movimentos: movimentos,
        animalId: animalId,
        tipo: _tipo,
        periodo: _periodo,
        onAnimal: (id) => setState(() => _animalId = id),
        onTipo: (tipo) => setState(() => _tipo = tipo),
        onPeriodo: _selecionarPeriodo,
        onMes: () {
          final hoje = DateTime.now();
          setState(
            () => _periodo = DateTimeRange(
              start: DateTime(hoje.year, hoje.month),
              end: DateTime(hoje.year, hoje.month + 1, 0),
            ),
          );
        },
        onLimpar: () => setState(() {
          _animalId = null;
          _tipo = null;
          _periodo = null;
        }),
        onAtualizar: _atualizar,
        onAbrirAnimal: _abrirAnimal,
        onNovoLancamento: () => _novoLancamento(dados),
      );
    }

    return ListView(
      key: const PageStorageKey('financeiro-scroll'),
      padding: const EdgeInsets.all(20),
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Receitas e despesas dos animais',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Lançamentos registrados nas fichas dos animais. Contas e dívidas de clientes não entram nestes totais.',
                    style: TextStyle(color: _cinza),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            FilledButton.icon(
              key: const ValueKey('novo-lancamento-financeiro'),
              onPressed: () => _novoLancamento(dados),
              icon: const Icon(Icons.add_card_rounded),
              label: const Text('Novo lançamento'),
            ),
          ],
        ),
        const SizedBox(height: 20),
        CamposGrid(
          maximoColunas: 2,
          larguraMinimaColuna: 260,
          campos: [
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: DropdownButtonFormField<String>(
                key: ValueKey('animal-${animalId ?? "todos"}'),
                initialValue: animalId ?? '',
                isExpanded: true,
                decoration: _decoracao('Animal'),
                items: [
                  const DropdownMenuItem(
                    value: '',
                    child: Text('Todos os animais'),
                  ),
                  for (final animal in animais)
                    DropdownMenuItem(
                      value: animal.key,
                      child: Text(
                        animal.value,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
                onChanged: (v) =>
                    setState(() => _animalId = v == '' ? null : v),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: DropdownButtonFormField<String>(
                key: ValueKey('tipo-${_tipo?.name ?? "todos"}'),
                initialValue: _tipo?.name ?? '',
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
                onChanged: (v) => setState(
                  () => _tipo = switch (v) {
                    'receita' => TipoMovimentoAnimal.receita,
                    'despesa' => TipoMovimentoAnimal.despesa,
                    _ => null,
                  },
                ),
              ),
            ),
          ],
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            OutlinedButton.icon(
              onPressed: _selecionarPeriodo,
              icon: const Icon(Icons.date_range_outlined, size: 18),
              label: Text(
                _periodo == null
                    ? 'Todo o período'
                    : '${_data.format(_periodo!.start)} a ${_data.format(_periodo!.end)}',
              ),
            ),
            TextButton(
              onPressed: () {
                final hoje = DateTime.now();
                setState(
                  () => _periodo = DateTimeRange(
                    start: DateTime(hoje.year, hoje.month),
                    end: DateTime(hoje.year, hoje.month + 1, 0),
                  ),
                );
              },
              child: const Text('Este mês'),
            ),
            TextButton(
              onPressed: () => setState(() {
                _animalId = null;
                _tipo = null;
                _periodo = null;
              }),
              child: const Text('Limpar filtros'),
            ),
            if (animalId != null)
              TextButton.icon(
                onPressed: () => _abrirAnimal(animalId),
                icon: const Icon(Icons.pets_outlined, size: 18),
                label: const Text('Abrir ficha do animal'),
              ),
          ],
        ),
        const SizedBox(height: 16),
        if (dados.registrosInvalidos > 0 || semData > 0)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text(
              [
                if (dados.registrosInvalidos > 0)
                  '${dados.registrosInvalidos} lançamento(s) com valor inválido não foram somados. Revise as fichas.',
                if (semData > 0)
                  '$semData lançamento(s) sem data aparecem apenas em Todo o período.',
              ].join(' '),
              style: const TextStyle(color: Color(0xFF92400E)),
            ),
          ),
        CamposGrid(
          larguraMinimaColuna: 240,
          campos: [
            _cartao('Receitas', resumo.receitas, const Color(0xFF15803D)),
            _cartao('Despesas', resumo.despesas, const Color(0xFFB91C1C)),
            _cartao(
              'Saldo',
              resumo.saldo,
              resumo.saldo < 0
                  ? const Color(0xFFB91C1C)
                  : const Color(0xFF111827),
            ),
          ],
        ),
        Text(
          '${movimentos.length} lançamento(s) nos filtros selecionados',
          style: const TextStyle(color: _cinza),
        ),
        const SizedBox(height: 12),
        if (movimentos.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 32),
            child: Text(
              dados.animais.isEmpty
                  ? 'Nenhum animal cadastrado.'
                  : 'Nenhum lançamento encontrado. As receitas e despesas podem ser registradas na ficha do animal.',
              textAlign: TextAlign.center,
            ),
          )
        else
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: _borda),
              borderRadius: BorderRadius.circular(6),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                showCheckboxColumn: false,
                headingRowHeight: 40,
                dataRowMinHeight: 48,
                dataRowMaxHeight: 64,
                columnSpacing: 24,
                columns: const [
                  DataColumn(label: Text('Data')),
                  DataColumn(label: Text('Animal')),
                  DataColumn(label: Text('Tipo')),
                  DataColumn(label: Text('Categoria')),
                  DataColumn(label: Text('Descrição')),
                  DataColumn(label: Text('Valor'), numeric: true),
                  DataColumn(label: Text('Ficha')),
                ],
                rows: movimentos
                    .map(
                      (m) => DataRow(
                        cells: [
                          DataCell(
                            Text(
                              m.data == null
                                  ? 'Sem data'
                                  : _data.format(m.data!),
                            ),
                          ),
                          DataCell(
                            SizedBox(
                              width: 160,
                              child: Text(
                                m.animalNome,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          DataCell(
                            Text(
                              m.tipo == TipoMovimentoAnimal.receita
                                  ? 'Receita'
                                  : 'Despesa',
                            ),
                          ),
                          DataCell(Text(m.categoria)),
                          DataCell(
                            SizedBox(
                              width: 200,
                              child: Tooltip(
                                message: m.descricao,
                                child: Text(
                                  m.descricao.isEmpty ? '—' : m.descricao,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ),
                          DataCell(Text(_moeda.format(m.centavos / 100))),
                          DataCell(
                            IconButton(
                              tooltip: 'Abrir ficha do animal',
                              onPressed: () => _abrirAnimal(m.animalId),
                              icon: const Icon(Icons.open_in_new, size: 18),
                            ),
                          ),
                        ],
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
      ],
    );
  }

  Widget _conteudoCompacto({
    required FinanceiroAnimaisDados dados,
    required List<MapEntry<String, String>> animais,
    required String? animalId,
    required List<MovimentoAnimal> movimentos,
    required ResumoFinanceiroAnimais resumo,
    required int semData,
  }) => Padding(
    padding: const EdgeInsets.all(10),
    child: Column(
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Receitas e despesas dos animais',
                style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
              ),
            ),
            IconButton(
              visualDensity: VisualDensity.compact,
              tooltip: 'Atualizar',
              onPressed: _atualizar,
              icon: const Icon(Icons.refresh_rounded),
            ),
            const SizedBox(width: 3),
            FilledButton.icon(
              key: const ValueKey('novo-lancamento-financeiro'),
              onPressed: () => _novoLancamento(dados),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Novo'),
            ),
          ],
        ),
        const SizedBox(height: 7),
        Material(
          color: Colors.white,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: const BorderSide(color: _borda),
          ),
          child: ExpansionTile(
            tilePadding: const EdgeInsets.symmetric(horizontal: 12),
            childrenPadding: const EdgeInsets.fromLTRB(10, 0, 10, 8),
            leading: const Icon(Icons.filter_alt_outlined, size: 20),
            title: Text(
              animalId == null && _tipo == null && _periodo == null
                  ? 'Filtros'
                  : 'Filtros ativos',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  final ladoALado = constraints.maxWidth >= 650;
                  final largura = ladoALado
                      ? (constraints.maxWidth - 8) / 2
                      : constraints.maxWidth;
                  return Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      SizedBox(
                        width: largura,
                        child: DropdownButtonFormField<String>(
                          key: ValueKey('animal-${animalId ?? "todos"}'),
                          initialValue: animalId ?? '',
                          isExpanded: true,
                          decoration: _decoracao('Animal'),
                          items: [
                            const DropdownMenuItem(
                              value: '',
                              child: Text('Todos os animais'),
                            ),
                            for (final animal in animais)
                              DropdownMenuItem(
                                value: animal.key,
                                child: Text(
                                  animal.value,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                          ],
                          onChanged: (valor) => setState(
                            () => _animalId = valor == '' ? null : valor,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: largura,
                        child: DropdownButtonFormField<String>(
                          key: ValueKey('tipo-${_tipo?.name ?? "todos"}'),
                          initialValue: _tipo?.name ?? '',
                          isExpanded: true,
                          decoration: _decoracao('Tipo'),
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
                          onChanged: (valor) => setState(
                            () => _tipo = switch (valor) {
                              'receita' => TipoMovimentoAnimal.receita,
                              'despesa' => TipoMovimentoAnimal.despesa,
                              _ => null,
                            },
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 7),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: [
                  OutlinedButton.icon(
                    onPressed: _selecionarPeriodo,
                    icon: const Icon(Icons.date_range_outlined, size: 17),
                    label: Text(
                      _periodo == null
                          ? 'Todo o período'
                          : '${_data.format(_periodo!.start)} a ${_data.format(_periodo!.end)}',
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      final hoje = DateTime.now();
                      setState(
                        () => _periodo = DateTimeRange(
                          start: DateTime(hoje.year, hoje.month),
                          end: DateTime(hoje.year, hoje.month + 1, 0),
                        ),
                      );
                    },
                    child: const Text('Este mês'),
                  ),
                  TextButton(
                    onPressed: () => setState(() {
                      _animalId = null;
                      _tipo = null;
                      _periodo = null;
                    }),
                    child: const Text('Limpar'),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 7),
        Row(
          children: [
            Expanded(
              child: _cartaoCompacto(
                'Receitas',
                resumo.receitas,
                const Color(0xFF15803D),
              ),
            ),
            const SizedBox(width: 7),
            Expanded(
              child: _cartaoCompacto(
                'Despesas',
                resumo.despesas,
                const Color(0xFFB91C1C),
              ),
            ),
            const SizedBox(width: 7),
            Expanded(
              child: _cartaoCompacto(
                'Saldo',
                resumo.saldo,
                resumo.saldo < 0
                    ? const Color(0xFFB91C1C)
                    : const Color(0xFF111827),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: Text(
                '${movimentos.length} lançamento(s)',
                style: const TextStyle(color: _cinza, fontSize: 12),
              ),
            ),
            if (dados.registrosInvalidos > 0 || semData > 0)
              const Tooltip(
                message: 'Existem lançamentos inválidos ou sem data.',
                child: Icon(
                  Icons.warning_amber_rounded,
                  size: 18,
                  color: Color(0xFFB45309),
                ),
              ),
          ],
        ),
        const SizedBox(height: 4),
        Expanded(
          child: Card(
            margin: EdgeInsets.zero,
            child: movimentos.isEmpty
                ? Center(
                    child: Text(
                      dados.animais.isEmpty
                          ? 'Nenhum animal cadastrado.'
                          : 'Nenhum lançamento encontrado.',
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _atualizar,
                    child: ListView.separated(
                      padding: const EdgeInsets.all(8),
                      itemCount: movimentos.length,
                      separatorBuilder: (_, _) => const Divider(height: 6),
                      itemBuilder: (_, indice) =>
                          _movimentoCompacto(movimentos[indice]),
                    ),
                  ),
          ),
        ),
      ],
    ),
  );

  Widget _cartaoCompacto(String titulo, int centavos, Color cor) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(color: _borda),
      borderRadius: BorderRadius.circular(9),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(titulo, style: const TextStyle(color: _cinza, fontSize: 11)),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            _moeda.format(centavos / 100),
            style: TextStyle(
              color: cor,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ],
    ),
  );

  Widget _movimentoCompacto(MovimentoAnimal movimento) {
    final receita = movimento.tipo == TipoMovimentoAnimal.receita;
    return InkWell(
      onTap: () => _abrirAnimal(movimento.animalId),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 5),
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
                    movimento.descricao.isEmpty
                        ? movimento.categoria
                        : movimento.descricao,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    '${movimento.animalNome} • ${movimento.categoria} • ${movimento.data == null ? 'Sem data' : _data.format(movimento.data!)}',
                    style: const TextStyle(color: _cinza, fontSize: 11),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              _moeda.format(movimento.centavos / 100),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: receita
                    ? const Color(0xFF15803D)
                    : const Color(0xFFB91C1C),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFFF3F4F6),
    appBar: widget.embedded
        ? null
        : AppBar(
            title: const Text(
              'Financeiro',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.transparent,
            actions: [
              IconButton(
                tooltip: 'Atualizar lançamentos',
                onPressed: _atualizar,
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
    body: Column(
      children: [
        if (!widget.embedded && MediaQuery.sizeOf(context).width >= 1000)
          const AdminTopBar(),
        Expanded(
          child: FutureBuilder<FinanceiroAnimaisDados>(
            future: _dados,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Não foi possível carregar todos os lançamentos. Os totais não foram exibidos para evitar um resultado incompleto.',
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton(
                          onPressed: _atualizar,
                          child: const Text('Tentar novamente'),
                        ),
                      ],
                    ),
                  ),
                );
              }
              return LayoutBuilder(
                builder: (context, constraints) =>
                    _conteudo(snapshot.data!, constraints.maxWidth),
              );
            },
          ),
        ),
      ],
    ),
  );
}
