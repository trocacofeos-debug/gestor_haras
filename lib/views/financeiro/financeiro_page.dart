import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../services/divida_service.dart';
import '../../widgets/app_dialogs.dart';
import '../../widgets/desktop_window.dart';
import 'nova_conta_page.dart';

class FinanceiroPage extends StatefulWidget {
  const FinanceiroPage({super.key});

  @override
  State<FinanceiroPage> createState() => _FinanceiroPageState();
}

class _FinanceiroPageState extends State<FinanceiroPage> {
  final _service = DividaService();
  final _busca = TextEditingController();
  final _moeda = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
  final _data = DateFormat('dd/MM/yyyy');
  String? _expandida;

  static const _borda = Color(0xFFE2E8F0);
  static const _secundario = Color(0xFF64748B);
  static const _primaria = Color(0xFF4F46E5);
  static const _vermelho = Color(0xFFB91C1C);
  static const _verde = Color(0xFF15803D);

  @override
  void dispose() {
    _busca.dispose();
    super.dispose();
  }

  String _normalizar(Object? valor) => (valor ?? '')
      .toString()
      .toLowerCase()
      .replaceAll(RegExp('[áàâã]'), 'a')
      .replaceAll(RegExp('[éê]'), 'e')
      .replaceAll('í', 'i')
      .replaceAll(RegExp('[óôõ]'), 'o')
      .replaceAll('ú', 'u')
      .replaceAll('ç', 'c');

  Future<void> _novaDivida() async {
    if (DesktopWindowScope.isInside(context)) {
      await openDesktopWindow(
        context,
        title: 'Cadastrar dívida',
        icon: Icons.add_card_outlined,
        builder: (_) => const NovaContaPage(),
      );
    } else {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const NovaContaPage()),
      );
    }
  }

  Future<bool> _confirmar(String titulo, String mensagem) async =>
      await showAppDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(titulo),
          content: Text(mensagem),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Confirmar'),
            ),
          ],
        ),
      ) ??
      false;

  Future<void> _pagarParcela(String dividaId, String parcelaId) async {
    if (!await _confirmar(
      'Confirmar pagamento',
      'Deseja marcar esta parcela como paga?',
    )) {
      return;
    }
    try {
      await _service.pagarParcela(dividaId, parcelaId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Parcela marcada como paga.')),
      );
    } catch (erro) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Não foi possível pagar a parcela: $erro')),
      );
    }
  }

  Future<void> _quitar(String dividaId) async {
    if (!await _confirmar(
      'Quitar dívida',
      'A dívida sairá da lista de pendências.',
    )) {
      return;
    }
    try {
      await _service.quitarDivida(dividaId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Dívida quitada com sucesso.')),
      );
    } catch (erro) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Não foi possível quitar a dívida: $erro')),
      );
    }
  }

  Widget _resumo(int quantidade, double total) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [Color(0xFF1E293B), Color(0xFF312E81)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Total cadastrado',
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
              const SizedBox(height: 5),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  _moeda.format(total),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '$quantidade dívida(s) em aberto',
                style: const TextStyle(color: Colors.white70),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: .10),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(
            Icons.account_balance_wallet_outlined,
            color: Colors.white,
            size: 28,
          ),
        ),
      ],
    ),
  );

  Widget _cartaoDivida(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final dados = doc.data();
    final nome = (dados['clienteNome'] ?? 'Cliente').toString();
    final descricao = (dados['descricao'] ?? 'Dívida').toString();
    final categoria = (dados['categoria'] ?? '').toString();
    final valor = (dados['valorTotal'] as num?)?.toDouble() ?? 0;
    final parcelas = (dados['parcelas'] as num?)?.toInt() ?? 1;
    final criadaEm = dados['dataCriacao'];
    final expandida = _expandida == doc.id;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _expandida = expandida ? null : doc.id),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const CircleAvatar(
                        backgroundColor: Color(0xFFEEF2FF),
                        foregroundColor: _primaria,
                        child: Icon(Icons.person_outline_rounded),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              nome,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              descricao,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: _secundario),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            _moeda.format(valor),
                            style: const TextStyle(
                              color: _vermelho,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Icon(
                            expandida
                                ? Icons.keyboard_arrow_up_rounded
                                : Icons.keyboard_arrow_down_rounded,
                            color: _secundario,
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _etiqueta(
                        categoria.isEmpty ? 'Sem categoria' : categoria,
                        Icons.category_outlined,
                      ),
                      _etiqueta(
                        '$parcelas parcela(s)',
                        Icons.view_week_outlined,
                      ),
                      if (criadaEm is Timestamp)
                        _etiqueta(
                          _data.format(criadaEm.toDate()),
                          Icons.calendar_today_outlined,
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 180),
            crossFadeState: expandida
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            firstChild: const SizedBox(width: double.infinity),
            secondChild: _parcelas(doc.id),
          ),
        ],
      ),
    );
  }

  Widget _etiqueta(String texto, IconData icone) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
    decoration: BoxDecoration(
      color: const Color(0xFFF8FAFC),
      border: Border.all(color: _borda),
      borderRadius: BorderRadius.circular(999),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icone, size: 14, color: _secundario),
        const SizedBox(width: 5),
        Text(texto, style: const TextStyle(fontSize: 12, color: _secundario)),
      ],
    ),
  );

  Widget _parcelas(String dividaId) => Container(
    width: double.infinity,
    decoration: const BoxDecoration(
      color: Color(0xFFF8FAFC),
      border: Border(top: BorderSide(color: _borda)),
    ),
    padding: const EdgeInsets.all(14),
    child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _service.parcelas(dividaId),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text('Não foi possível carregar as parcelas.');
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final parcelas = snapshot.data!.docs;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < parcelas.length; i++) ...[
              _linhaParcela(dividaId, parcelas[i], i + 1),
              if (i < parcelas.length - 1) const Divider(height: 17),
            ],
            const SizedBox(height: 14),
            OutlinedButton.icon(
              onPressed: () => _quitar(dividaId),
              icon: const Icon(Icons.done_all_rounded),
              label: const Text('Quitar dívida completa'),
            ),
          ],
        );
      },
    ),
  );

  Widget _linhaParcela(
    String dividaId,
    QueryDocumentSnapshot<Map<String, dynamic>> parcela,
    int indice,
  ) {
    final dados = parcela.data();
    final paga = dados['status'] == 'pago';
    final valor = (dados['valor'] as num?)?.toDouble() ?? 0;
    final vencimento = dados['vencimento'];
    return Row(
      children: [
        Icon(
          paga ? Icons.check_circle_rounded : Icons.schedule_rounded,
          color: paga ? _verde : const Color(0xFFD97706),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Parcela ${dados['numero'] ?? indice} • ${_moeda.format(valor)}',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              Text(
                vencimento is Timestamp
                    ? 'Vencimento: ${_data.format(vencimento.toDate())}'
                    : 'Sem vencimento',
                style: const TextStyle(fontSize: 12, color: _secundario),
              ),
            ],
          ),
        ),
        if (paga)
          const Text(
            'Paga',
            style: TextStyle(color: _verde, fontWeight: FontWeight.w700),
          )
        else
          TextButton(
            onPressed: () => _pagarParcela(dividaId, parcela.id),
            child: const Text('Pagar'),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final dentroDaJanela = DesktopWindowScope.isInside(context);
    return Scaffold(
      appBar: dentroDaJanela
          ? null
          : AppBar(
              title: const Text('Dívidas'),
              actions: [
                IconButton(
                  tooltip: 'Cadastrar dívida',
                  onPressed: _novaDivida,
                  icon: const Icon(Icons.add_card_outlined),
                ),
              ],
            ),
      floatingActionButton: MediaQuery.sizeOf(context).width < 900
          ? FloatingActionButton.extended(
              onPressed: _novaDivida,
              icon: const Icon(Icons.add),
              label: const Text('Cadastrar dívida'),
            )
          : null,
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _service.listarDividas(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text('Não foi possível carregar as dívidas.'),
            );
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final todos = snapshot.data!.docs;
          final busca = _normalizar(_busca.text);
          final filtrados = todos.where((doc) {
            final dados = doc.data();
            return [
              dados['clienteNome'],
              dados['descricao'],
              dados['categoria'],
            ].any((valor) => _normalizar(valor).contains(busca));
          }).toList();
          final total = todos.fold<double>(
            0,
            (soma, doc) =>
                soma + ((doc.data()['valorTotal'] as num?)?.toDouble() ?? 0),
          );
          return ListView(
            key: const PageStorageKey('dividas-scroll'),
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 100),
            children: [
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1050),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (MediaQuery.sizeOf(context).width >= 900)
                        Row(
                          children: [
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Dívidas',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  Text(
                                    'Acompanhe parcelas e pagamentos dos clientes.',
                                    style: TextStyle(color: _secundario),
                                  ),
                                ],
                              ),
                            ),
                            FilledButton.icon(
                              onPressed: _novaDivida,
                              icon: const Icon(Icons.add_card_outlined),
                              label: const Text('Cadastrar dívida'),
                            ),
                          ],
                        )
                      else
                        const Text(
                          'Acompanhe parcelas e pagamentos dos clientes.',
                          style: TextStyle(color: _secundario),
                        ),
                      const SizedBox(height: 18),
                      _resumo(todos.length, total),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _busca,
                        onChanged: (_) => setState(() {}),
                        decoration: InputDecoration(
                          hintText:
                              'Buscar por cliente, descrição ou categoria',
                          prefixIcon: const Icon(Icons.search_rounded),
                          suffixIcon: _busca.text.isEmpty
                              ? null
                              : IconButton(
                                  tooltip: 'Limpar busca',
                                  onPressed: () => setState(_busca.clear),
                                  icon: const Icon(Icons.close_rounded),
                                ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (filtrados.isEmpty)
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 42,
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  todos.isEmpty
                                      ? Icons.check_circle_outline_rounded
                                      : Icons.search_off_rounded,
                                  size: 46,
                                  color: todos.isEmpty ? _verde : _secundario,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  todos.isEmpty
                                      ? 'Nenhuma dívida em aberto'
                                      : 'Nenhuma dívida encontrada',
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        for (final divida in filtrados) _cartaoDivida(divida),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
