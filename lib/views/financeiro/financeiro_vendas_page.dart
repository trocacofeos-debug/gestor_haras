import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/financeiro_vendas.dart';
import '../../services/financeiro_vendas_service.dart';

class FinanceiroVendasPage extends StatefulWidget {
  const FinanceiroVendasPage({super.key, this.carregar});

  final Future<FinanceiroVendasDados> Function()? carregar;

  @override
  State<FinanceiroVendasPage> createState() => _FinanceiroVendasPageState();
}

class _FinanceiroVendasPageState extends State<FinanceiroVendasPage> {
  late Future<FinanceiroVendasDados> dados = _carregar();
  final moeda = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
  final data = DateFormat('dd/MM/yyyy');

  Future<FinanceiroVendasDados> _carregar() =>
      widget.carregar?.call() ?? const FinanceiroVendasService().carregar();

  void _atualizar() => setState(() => dados = _carregar());

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFFF3F4F6),
    body: FutureBuilder<FinanceiroVendasDados>(
      future: dados,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError || !snapshot.hasData) {
          return Center(
            child: OutlinedButton.icon(
              onPressed: _atualizar,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Tentar novamente'),
            ),
          );
        }
        return _conteudo(snapshot.data!);
      },
    ),
  );

  Widget _conteudo(FinanceiroVendasDados dados) => RefreshIndicator(
    onRefresh: () async => _atualizar(),
    child: ListView(
      padding: const EdgeInsets.all(12),
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Financeiro das vendas',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            IconButton(
              tooltip: 'Atualizar',
              onPressed: _atualizar,
              icon: const Icon(Icons.refresh_rounded),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LayoutBuilder(
          builder: (context, constraints) {
            final largura = (constraints.maxWidth - 24) / 4;
            return Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _resumo(
                  largura,
                  'Vendas',
                  '${dados.quantidadeVendas}',
                  Icons.shopping_cart_outlined,
                  const Color(0xFF4338CA),
                ),
                _resumo(
                  largura,
                  'Total vendido',
                  moeda.format(dados.totalCentavos / 100),
                  Icons.receipt_long_outlined,
                  const Color(0xFF1D4ED8),
                ),
                _resumo(
                  largura,
                  'Já pago',
                  moeda.format(dados.pagoCentavos / 100),
                  Icons.check_circle_outline,
                  const Color(0xFF15803D),
                ),
                _resumo(
                  largura,
                  'Pendente',
                  moeda.format(dados.pendenteCentavos / 100),
                  Icons.schedule_outlined,
                  const Color(0xFFB45309),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 10),
        if (dados.quantidadeVendas > 0)
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              minHeight: 8,
              value: dados.totalCentavos == 0
                  ? 0
                  : dados.pagoCentavos / dados.totalCentavos,
              backgroundColor: const Color(0xFFFDE68A),
              color: const Color(0xFF16A34A),
            ),
          ),
        const SizedBox(height: 6),
        Text(
          '${dados.vendasQuitadas} venda(s) totalmente paga(s)',
          style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
        ),
        if (dados.registrosInvalidos > 0)
          Text(
            '${dados.registrosInvalidos} registro(s) inválido(s) não foram somados.',
            style: const TextStyle(color: Color(0xFF92400E), fontSize: 12),
          ),
        const SizedBox(height: 8),
        if (dados.vendas.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                'Nenhuma venda ou conta a receber cadastrada.',
                textAlign: TextAlign.center,
              ),
            ),
          )
        else
          SizedBox(
            height: MediaQuery.sizeOf(context).width < 600 ? 330 : 380,
            child: Card(
              margin: EdgeInsets.zero,
              child: ListView.separated(
                padding: const EdgeInsets.all(8),
                itemCount: dados.vendas.length,
                separatorBuilder: (_, _) => const Divider(height: 6),
                itemBuilder: (_, indice) => _venda(dados.vendas[indice]),
              ),
            ),
          ),
      ],
    ),
  );

  Widget _resumo(
    double largura,
    String titulo,
    String valor,
    IconData icone,
    Color cor,
  ) => Container(
    width: largura,
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 7),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: const Color(0xFFE5E7EB)),
    ),
    child: Row(
      children: [
        Icon(icone, size: 17, color: cor),
        const SizedBox(width: 5),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                titulo,
                maxLines: 2,
                style: const TextStyle(fontSize: 10, height: 1.05),
              ),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  valor,
                  style: TextStyle(
                    color: cor,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _venda(VendaFinanceira venda) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 5),
    child: Row(
      children: [
        Icon(
          venda.quitada ? Icons.check_circle_rounded : Icons.schedule_rounded,
          color: venda.quitada
              ? const Color(0xFF15803D)
              : const Color(0xFFB45309),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                venda.clienteNome,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              Text(
                '${venda.descricao}${venda.data == null ? '' : ' • ${data.format(venda.data!)}'}',
                style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              moeda.format(venda.totalCentavos / 100),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              'Pago: ${moeda.format(venda.pagoCentavos / 100)}',
              style: const TextStyle(color: Color(0xFF15803D), fontSize: 11),
            ),
          ],
        ),
      ],
    ),
  );
}
