import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../models/cliente_model.dart';
import '../../models/divida_model.dart';
import '../../services/divida_service.dart';
import '../../widgets/app_dialogs.dart';
import '../../widgets/desktop_window.dart';

typedef CriarDividaCallback =
    Future<void> Function(
      DividaModel divida,
      List<Map<String, dynamic>> parcelas,
    );

class NovaContaPage extends StatefulWidget {
  const NovaContaPage({
    super.key,
    this.clienteIdInicial,
    this.clienteNomeInicial,
    this.clientes,
    this.criar,
  });

  final String? clienteIdInicial;
  final String? clienteNomeInicial;
  final Stream<List<ClienteModel>>? clientes;
  final CriarDividaCallback? criar;

  @override
  State<NovaContaPage> createState() => _NovaContaPageState();
}

class _NovaContaPageState extends State<NovaContaPage> {
  final _formKey = GlobalKey<FormState>();
  final _descricao = TextEditingController();
  final _valor = TextEditingController();
  final _moeda = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
  String? _clienteId;
  String? _clienteNome;
  String _categoria = 'Hospedagem';
  int _quantidadeParcelas = 1;
  DateTime _primeiroVencimento = DateTime.now().add(const Duration(days: 30));
  bool _salvando = false;

  static const _categorias = [
    'Hospedagem',
    'Serviços',
    'Compra',
    'Tratamento',
    'Transporte',
    'Outro',
  ];
  static const _borda = Color(0xFFE2E8F0);
  static const _textoSecundario = Color(0xFF64748B);
  static const _primaria = Color(0xFF4F46E5);

  @override
  void initState() {
    super.initState();
    _clienteId = widget.clienteIdInicial;
    _clienteNome = widget.clienteNomeInicial;
  }

  @override
  void dispose() {
    _descricao.dispose();
    _valor.dispose();
    super.dispose();
  }

  Stream<List<ClienteModel>> _clientes() =>
      widget.clientes ??
      FirebaseFirestore.instance
          .collection('clientes')
          .orderBy('nome')
          .snapshots()
          .map(
            (snapshot) => snapshot.docs
                .map((doc) => ClienteModel.fromMap(doc.data(), doc.id))
                .toList(),
          );

  int? _valorCentavos() {
    var texto = _valor.text.replaceAll(RegExp(r'[^0-9,.]'), '');
    if (texto.contains(',')) {
      texto = texto.replaceAll('.', '').replaceAll(',', '.');
    }
    final numero = double.tryParse(texto);
    if (numero == null || !numero.isFinite || numero <= 0) return null;
    return (numero * 100).round();
  }

  DateTime _vencimentoDaParcela(int indice) {
    final mesBase = _primeiroVencimento.month - 1 + indice;
    final ano = _primeiroVencimento.year + mesBase ~/ 12;
    final mes = mesBase % 12 + 1;
    final ultimoDia = DateTime(ano, mes + 1, 0).day;
    final dia = _primeiroVencimento.day.clamp(1, ultimoDia);
    return DateTime(ano, mes, dia);
  }

  Future<void> _escolherData() async {
    final data = await showAppDatePicker(
      context: context,
      initialDate: _primeiroVencimento,
      firstDate: DateTime(2020),
      lastDate: DateTime(DateTime.now().year + 15, 12, 31),
    );
    if (data != null && mounted) {
      setState(() => _primeiroVencimento = data);
    }
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;
    if (_clienteId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione o cliente da dívida.')),
      );
      return;
    }
    final centavos = _valorCentavos()!;
    setState(() => _salvando = true);
    try {
      final valorParcela = centavos / 100 / _quantidadeParcelas;
      final parcelas = [
        for (var i = 0; i < _quantidadeParcelas; i++)
          {
            'numero': i + 1,
            'valor': valorParcela,
            'vencimento': Timestamp.fromDate(_vencimentoDaParcela(i)),
            'status': 'pendente',
            'criadoEm': Timestamp.now(),
          },
      ];
      final divida = DividaModel(
        id: '',
        clienteId: _clienteId!,
        clienteNome: _clienteNome ?? '',
        valorTotal: centavos / 100,
        descricao: _descricao.text.trim(),
        categoria: _categoria,
        parcelas: _quantidadeParcelas,
        status: 'aberta',
        dataCriacao: Timestamp.now(),
      );
      if (widget.criar != null) {
        await widget.criar!(divida, parcelas);
      } else {
        await DividaService().criarDivida(divida, parcelas);
      }
      if (!mounted) return;
      if (Navigator.canPop(context)) {
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Dívida cadastrada com sucesso.')),
        );
      }
    } catch (erro) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Não foi possível cadastrar a dívida: $erro')),
      );
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  Widget _secao(String titulo, IconData icone, Widget child) => Card(
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF2FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icone, color: _primaria, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  titulo,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          child,
        ],
      ),
    ),
  );

  Widget _campoCliente() {
    if (widget.clienteIdInicial != null) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          border: Border.all(color: _borda),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            const CircleAvatar(
              backgroundColor: Color(0xFFE0E7FF),
              foregroundColor: _primaria,
              child: Icon(Icons.person_outline_rounded),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Cliente selecionado',
                    style: TextStyle(fontSize: 12, color: _textoSecundario),
                  ),
                  Text(
                    _clienteNome?.trim().isNotEmpty == true
                        ? _clienteNome!
                        : 'Cliente',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
    return StreamBuilder<List<ClienteModel>>(
      stream: _clientes(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text('Não foi possível carregar os clientes.');
        }
        if (!snapshot.hasData) return const LinearProgressIndicator();
        final clientes = snapshot.data!;
        return Autocomplete<ClienteModel>(
          displayStringForOption: (cliente) => cliente.nomeExibicao,
          optionsBuilder: (texto) {
            final busca = texto.text.trim().toLowerCase();
            if (busca.isEmpty) return clientes;
            return clientes.where(
              (cliente) =>
                  cliente.nomeExibicao.toLowerCase().contains(busca) ||
                  cliente.telefone.toLowerCase().contains(busca),
            );
          },
          onSelected: (cliente) => setState(() {
            _clienteId = cliente.id;
            _clienteNome = cliente.nomeExibicao;
          }),
          fieldViewBuilder: (context, controller, focusNode, onSubmit) =>
              TextFormField(
                key: const ValueKey('divida-cliente'),
                controller: controller,
                focusNode: focusNode,
                onChanged: (_) {
                  if (_clienteId != null) {
                    setState(() {
                      _clienteId = null;
                      _clienteNome = null;
                    });
                  }
                },
                decoration: InputDecoration(
                  labelText: 'Pesquisar cliente *',
                  hintText: 'Digite o nome ou telefone',
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: _clienteId == null
                      ? null
                      : const Icon(
                          Icons.check_circle,
                          color: Color(0xFF15803D),
                        ),
                ),
                validator: (_) => _clienteId == null
                    ? 'Pesquise e selecione um cliente da lista'
                    : null,
              ),
          optionsViewBuilder: (context, selecionar, opcoes) => Align(
            alignment: Alignment.topLeft,
            child: Material(
              elevation: 8,
              borderRadius: BorderRadius.circular(14),
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxHeight: 280,
                  maxWidth: 520,
                ),
                child: ListView(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  shrinkWrap: true,
                  children: [
                    for (final cliente in opcoes)
                      ListTile(
                        leading: const CircleAvatar(
                          child: Icon(Icons.person_outline, size: 19),
                        ),
                        title: Text(cliente.nomeExibicao),
                        subtitle: cliente.telefone.isEmpty
                            ? null
                            : Text(cliente.telefone),
                        onTap: () => selecionar(cliente),
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

  Widget _detalhes() => LayoutBuilder(
    builder: (context, constraints) {
      final descricao = TextFormField(
        key: const ValueKey('divida-descricao'),
        controller: _descricao,
        textCapitalization: TextCapitalization.sentences,
        decoration: const InputDecoration(
          labelText: 'Descrição *',
          hintText: 'Ex.: hospedagem mensal',
          prefixIcon: Icon(Icons.notes_rounded),
        ),
        validator: (texto) => texto == null || texto.trim().isEmpty
            ? 'Informe uma descrição'
            : null,
      );
      final categoria = DropdownButtonFormField<String>(
        key: const ValueKey('divida-categoria'),
        initialValue: _categoria,
        isExpanded: true,
        decoration: const InputDecoration(
          labelText: 'Categoria',
          prefixIcon: Icon(Icons.category_outlined),
        ),
        items: [
          for (final item in _categorias)
            DropdownMenuItem(value: item, child: Text(item)),
        ],
        onChanged: (item) => setState(() => _categoria = item ?? 'Outro'),
      );
      if (constraints.maxWidth < 680) {
        return Column(
          children: [descricao, const SizedBox(height: 14), categoria],
        );
      }
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 2, child: descricao),
          const SizedBox(width: 14),
          Expanded(child: categoria),
        ],
      );
    },
  );

  Widget _parcelamento() => LayoutBuilder(
    builder: (context, constraints) {
      final valor = TextFormField(
        key: const ValueKey('divida-valor'),
        controller: _valor,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'[0-9,.]')),
        ],
        onChanged: (_) => setState(() {}),
        decoration: const InputDecoration(
          labelText: 'Valor total *',
          prefixText: 'R\$ ',
        ),
        validator: (_) =>
            _valorCentavos() == null ? 'Informe um valor maior que zero' : null,
      );
      final quantidade = DropdownButtonFormField<int>(
        key: const ValueKey('divida-parcelas'),
        initialValue: _quantidadeParcelas,
        isExpanded: true,
        decoration: const InputDecoration(
          labelText: 'Parcelas',
          prefixIcon: Icon(Icons.view_week_outlined),
        ),
        items: [
          for (var item = 1; item <= 36; item++)
            DropdownMenuItem(value: item, child: Text('$item')),
        ],
        onChanged: (item) => setState(() => _quantidadeParcelas = item ?? 1),
      );
      final data = OutlinedButton.icon(
        key: const ValueKey('divida-vencimento'),
        onPressed: _escolherData,
        icon: const Icon(Icons.calendar_month_outlined),
        label: Text(
          '1º vencimento: ${DateFormat('dd/MM/yyyy').format(_primeiroVencimento)}',
        ),
      );
      final campos = [valor, quantidade, data];
      final conteudo = constraints.maxWidth >= 680
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var i = 0; i < campos.length; i++) ...[
                  Expanded(child: campos[i]),
                  if (i < campos.length - 1) const SizedBox(width: 14),
                ],
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var i = 0; i < campos.length; i++) ...[
                  campos[i],
                  if (i < campos.length - 1) const SizedBox(height: 14),
                ],
              ],
            );
      final centavos = _valorCentavos();
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          conteudo,
          if (centavos != null) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                border: Border.all(color: _borda),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                '$_quantidadeParcelas parcela(s) de aproximadamente '
                '${_moeda.format(centavos / 100 / _quantidadeParcelas)}',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ],
      );
    },
  );

  Widget _botaoSalvar() => FilledButton.icon(
    key: const ValueKey('salvar-divida'),
    onPressed: _salvando ? null : _salvar,
    icon: _salvando
        ? const SizedBox.square(
            dimension: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        : const Icon(Icons.save_outlined),
    label: Text(_salvando ? 'Salvando...' : 'Cadastrar dívida'),
  );

  @override
  Widget build(BuildContext context) {
    final desktop = MediaQuery.sizeOf(context).width >= 900;
    final dentroDaJanela = DesktopWindowScope.isInside(context);
    return Scaffold(
      appBar: dentroDaJanela
          ? null
          : AppBar(title: const Text('Cadastrar dívida')),
      bottomNavigationBar: desktop
          ? null
          : SafeArea(
              top: false,
              child: Container(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(top: BorderSide(color: _borda)),
                ),
                child: _botaoSalvar(),
              ),
            ),
      body: Form(
        key: _formKey,
        child: ListView(
          key: const PageStorageKey('cadastrar-divida-scroll'),
          padding: EdgeInsets.fromLTRB(16, 18, 16, desktop ? 28 : 110),
          children: [
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1050),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (desktop) ...[
                      const Text(
                        'Cadastrar dívida',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 5),
                    ],
                    const Text(
                      'Registre a cobrança e configure o parcelamento do cliente.',
                      style: TextStyle(color: _textoSecundario),
                    ),
                    const SizedBox(height: 20),
                    _secao(
                      'Cliente',
                      Icons.person_outline_rounded,
                      _campoCliente(),
                    ),
                    const SizedBox(height: 16),
                    _secao(
                      'Detalhes da dívida',
                      Icons.receipt_long_outlined,
                      _detalhes(),
                    ),
                    const SizedBox(height: 16),
                    _secao(
                      'Valor e parcelamento',
                      Icons.payments_outlined,
                      _parcelamento(),
                    ),
                    if (desktop) ...[
                      const SizedBox(height: 20),
                      Align(
                        alignment: Alignment.centerRight,
                        child: _botaoSalvar(),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
