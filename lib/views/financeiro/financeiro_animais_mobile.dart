import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/financeiro_animais.dart';

/// Apresentação para celular; os dados e filtros continuam na página principal.
class FinanceiroAnimaisMobile extends StatelessWidget {
  final FinanceiroAnimaisDados dados;
  final List<MovimentoAnimal> movimentos;
  final String? animalId;
  final TipoMovimentoAnimal? tipo;
  final DateTimeRange? periodo;
  final ValueChanged<String?> onAnimal;
  final ValueChanged<TipoMovimentoAnimal?> onTipo;
  final VoidCallback onPeriodo;
  final VoidCallback onMes;
  final VoidCallback onLimpar;
  final Future<void> Function() onAtualizar;
  final ValueChanged<String> onAbrirAnimal;

  const FinanceiroAnimaisMobile({
    super.key,
    required this.dados,
    required this.movimentos,
    required this.animalId,
    required this.tipo,
    required this.periodo,
    required this.onAnimal,
    required this.onTipo,
    required this.onPeriodo,
    required this.onMes,
    required this.onLimpar,
    required this.onAtualizar,
    required this.onAbrirAnimal,
  });

  static const _borda = Color(0xFFE5E7EB);
  static const _cinza = Color(0xFF6B7280);
  static const _verde = Color(0xFF15803D);
  static const _vermelho = Color(0xFFB91C1C);

  String _moeda(int centavos) => NumberFormat.currency(
    locale: 'pt_BR',
    symbol: 'R\$',
  ).format(centavos / 100);
  String _data(DateTime data) => DateFormat('dd/MM/yyyy').format(data);

  Widget _total(String titulo, int valor, Color cor, IconData icon) =>
      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: _borda),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 20, color: cor),
            const SizedBox(height: 6),
            Text(titulo, style: const TextStyle(color: _cinza, fontSize: 13)),
            const SizedBox(height: 4),
            Text(
              _moeda(valor),
              style: TextStyle(
                color: cor,
                fontWeight: FontWeight.w600,
                fontSize: 18,
              ),
            ),
          ],
        ),
      );

  Widget _filtros() {
    final animais = dados.animais.entries.toList()
      ..sort((a, b) => a.value.toLowerCase().compareTo(b.value.toLowerCase()));
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: _borda),
      ),
      child: ExpansionTile(
        key: const PageStorageKey('financeiro-filtros-mobile'),
        leading: const Icon(Icons.tune, size: 20),
        title: const Text(
          'Filtros',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          '${animalId == null ? "Todos os animais" : dados.animais[animalId]} • ${periodo == null ? "Todo o período" : "Período selecionado"}',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 12, color: _cinza),
        ),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        children: [
          DropdownButtonFormField<String>(
            key: ValueKey('animal-${animalId ?? "todos"}'),
            initialValue: animalId ?? '',
            isExpanded: true,
            decoration: const InputDecoration(
              labelText: 'Animal',
              border: OutlineInputBorder(),
              isDense: true,
            ),
            items: [
              const DropdownMenuItem(
                value: '',
                child: Text('Todos os animais'),
              ),
              for (final animal in animais)
                DropdownMenuItem(
                  value: animal.key,
                  child: Text(animal.value, overflow: TextOverflow.ellipsis),
                ),
            ],
            onChanged: (value) => onAnimal(value == '' ? null : value),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onPeriodo,
              icon: const Icon(Icons.date_range_outlined, size: 18),
              label: Text(
                periodo == null
                    ? 'Todo o período'
                    : '${_data(periodo!.start)} a ${_data(periodo!.end)}',
              ),
            ),
          ),
          Wrap(
            spacing: 8,
            children: [
              TextButton(onPressed: onMes, child: const Text('Este mês')),
              TextButton(
                onPressed: onLimpar,
                child: const Text('Limpar filtros'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _lancamento(MovimentoAnimal m) {
    final receita = m.tipo == TipoMovimentoAnimal.receita;
    final cor = receita ? _verde : _vermelho;
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: _borda),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => onAbrirAnimal(m.animalId),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    receita ? Icons.south_west : Icons.north_east,
                    color: cor,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      receita ? 'Receita' : 'Despesa',
                      style: TextStyle(color: cor, fontWeight: FontWeight.w600),
                    ),
                  ),
                  const Icon(Icons.chevron_right, size: 20, color: _cinza),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                m.animalNome,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (m.descricao.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(m.descricao),
              ],
              const SizedBox(height: 6),
              Text(
                '${m.data == null ? "Sem data" : _data(m.data!)} • ${m.categoria}',
                style: const TextStyle(fontSize: 12, color: _cinza),
              ),
              const SizedBox(height: 8),
              Text(
                _moeda(m.centavos),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: cor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final resumo = ResumoFinanceiroAnimais.calcular(movimentos);
    final semData = dados.movimentos.where((m) => m.data == null).length;
    return RefreshIndicator(
      onRefresh: onAtualizar,
      child: CustomScrollView(
        key: const PageStorageKey('financeiro-scroll'),
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Saldo',
                          style: TextStyle(color: Colors.white70),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _moeda(resumo.saldo),
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          animalId == null
                              ? 'Todos os animais'
                              : dados.animais[animalId]!,
                          style: const TextStyle(color: Colors.white),
                        ),
                        Text(
                          periodo == null
                              ? 'Todo o período'
                              : '${_data(periodo!.start)} a ${_data(periodo!.end)}',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                        const Text(
                          'Totais dos filtros selecionados',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final receitas = _total(
                        'Receitas',
                        resumo.receitas,
                        _verde,
                        Icons.south_west,
                      );
                      final despesas = _total(
                        'Despesas',
                        resumo.despesas,
                        _vermelho,
                        Icons.north_east,
                      );
                      if (constraints.maxWidth < 320 ||
                          MediaQuery.textScalerOf(context).scale(18) > 24) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            receitas,
                            const SizedBox(height: 10),
                            despesas,
                          ],
                        );
                      }
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: receitas),
                          const SizedBox(width: 10),
                          Expanded(child: despesas),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  _filtros(),
                  if (animalId != null)
                    TextButton.icon(
                      onPressed: () => onAbrirAnimal(animalId!),
                      icon: const Icon(Icons.pets_outlined, size: 18),
                      label: const Text('Abrir ficha do animal'),
                    ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      ChoiceChip(
                        label: const Text('Todos'),
                        selected: tipo == null,
                        onSelected: (_) => onTipo(null),
                      ),
                      ChoiceChip(
                        label: const Text('Receitas'),
                        selected: tipo == TipoMovimentoAnimal.receita,
                        onSelected: (_) => onTipo(TipoMovimentoAnimal.receita),
                      ),
                      ChoiceChip(
                        label: const Text('Despesas'),
                        selected: tipo == TipoMovimentoAnimal.despesa,
                        onSelected: (_) => onTipo(TipoMovimentoAnimal.despesa),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Lançamentos das fichas dos animais. Contas e dívidas de clientes não entram nestes totais.',
                    style: TextStyle(color: _cinza, fontSize: 12),
                  ),
                  if (dados.registrosInvalidos > 0 || semData > 0)
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text(
                        [
                          if (dados.registrosInvalidos > 0)
                            '${dados.registrosInvalidos} lançamento(s) com valor inválido não foram somados. Revise as fichas.',
                          if (semData > 0)
                            '$semData lançamento(s) sem data aparecem apenas em Todo o período.',
                        ].join(' '),
                        style: const TextStyle(
                          color: Color(0xFF92400E),
                          fontSize: 12,
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),
                  const Text(
                    'Lançamentos',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  Text(
                    '${movimentos.length} lançamento(s) nos filtros selecionados',
                    style: const TextStyle(fontSize: 12, color: _cinza),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
          if (movimentos.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  dados.animais.isEmpty
                      ? 'Nenhum animal cadastrado.'
                      : 'Nenhum lançamento encontrado. Registre receitas e despesas na ficha do animal.',
                  textAlign: TextAlign.center,
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList.builder(
                itemCount: movimentos.length,
                itemBuilder: (_, index) => _lancamento(movimentos[index]),
              ),
            ),
          SliverToBoxAdapter(
            child: SizedBox(height: MediaQuery.paddingOf(context).bottom + 72),
          ),
        ],
      ),
    );
  }
}
