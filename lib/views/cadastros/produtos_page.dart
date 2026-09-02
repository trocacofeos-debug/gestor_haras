// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../models/medicamento_model.dart';
import '../../models/produto_model.dart';
import '../../services/produto_service.dart';
import '../../widgets/desktop_window.dart';
import '../home/admin_top_bar.dart';

class ProdutosPage extends StatefulWidget {
  const ProdutosPage({super.key, this.repository});

  final ProdutoRepository? repository;
  String get titulo => 'Produtos';
  IconData get icone => Icons.inventory_2_rounded;

  @override
  State<ProdutosPage> createState() => _ProdutosPageState();
}

class _ProdutosPageState extends State<ProdutosPage> {
  late final ProdutoRepository repository =
      widget.repository ?? ProdutoService();
  final moeda = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

  Future<void> _novo() async {
    await openDesktopWindow<bool>(
      context,
      title: 'Novo produto',
      icon: widget.icone,
      width: 760,
      height: 650,
      builder: (_) => CadastroProdutoPage(repository: repository),
    );
  }

  Future<void> _editar(ProdutoModel produto) async {
    await openDesktopWindow<bool>(
      context,
      title: 'Editar produto',
      icon: Icons.edit_rounded,
      width: 760,
      height: 650,
      builder: (_) =>
          CadastroProdutoPage(repository: repository, produto: produto),
    );
  }

  @override
  Widget build(BuildContext context) {
    final desktop = MediaQuery.sizeOf(context).width >= 900;
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: desktop ? null : AppBar(title: const Text('Produtos')),
      body: Column(
        children: [
          if (desktop) const AdminTopBar(),
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1150),
                child: Padding(
                  padding: EdgeInsets.all(desktop ? 28 : 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (desktop)
                        Row(
                          children: [
                            const Expanded(
                              child: Text(
                                'Produtos',
                                style: TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            FilledButton.icon(
                              onPressed: _novo,
                              icon: const Icon(Icons.add),
                              label: const Text('Cadastrar produto'),
                            ),
                          ],
                        )
                      else
                        const Text(
                          'Cadastre aqui os produtos usados no haras.',
                          style: TextStyle(color: Color(0xFF64748B)),
                        ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: StreamBuilder<List<ProdutoModel>>(
                          stream: repository.observar(),
                          builder: (context, snapshot) {
                            if (snapshot.hasError) {
                              return Center(
                                child: Text(
                                  'Erro ao carregar produtos: ${snapshot.error}',
                                ),
                              );
                            }
                            if (!snapshot.hasData) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                            final produtos = snapshot.data!;
                            if (produtos.isEmpty) {
                              return const Center(
                                child: Text('Nenhum produto cadastrado.'),
                              );
                            }
                            return desktop
                                ? _tabela(produtos)
                                : _lista(produtos);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: desktop
          ? null
          : FloatingActionButton.extended(
              onPressed: _novo,
              icon: const Icon(Icons.add),
              label: const Text('Cadastrar produto'),
            ),
    );
  }

  Widget _tabela(List<ProdutoModel> produtos) => Card(
    clipBehavior: Clip.antiAlias,
    child: SingleChildScrollView(
      child: SizedBox(
        width: double.infinity,
        child: DataTable(
          columns: const [
            DataColumn(label: Text('Produto')),
            DataColumn(label: Text('Tipo')),
            DataColumn(label: Text('Quantidade / dose padrão')),
            DataColumn(label: Text('Valor padrão')),
            DataColumn(label: Text('Situação')),
            DataColumn(label: Text('')),
          ],
          rows: produtos.map(_linha).toList(),
        ),
      ),
    ),
  );

  DataRow _linha(ProdutoModel produto) => DataRow(
    cells: [
      DataCell(
        Text(produto.nome, style: const TextStyle(fontWeight: FontWeight.w600)),
      ),
      DataCell(Text(produto.tipo.singularCapital)),
      DataCell(Text(produto.quantidadePadrao)),
      DataCell(Text(moeda.format(produto.valor))),
      DataCell(_status(produto)),
      DataCell(
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              tooltip: 'Editar',
              onPressed: () => _editar(produto),
              icon: const Icon(Icons.edit_outlined),
            ),
            IconButton(
              tooltip: produto.ativo ? 'Inativar' : 'Reativar',
              onPressed: () =>
                  repository.definirAtivo(produto.id, !produto.ativo),
              icon: Icon(
                produto.ativo ? Icons.block_outlined : Icons.refresh_rounded,
              ),
            ),
          ],
        ),
      ),
    ],
  );

  Widget _lista(List<ProdutoModel> produtos) => ListView.separated(
    itemCount: produtos.length,
    separatorBuilder: (_, _) => const SizedBox(height: 10),
    itemBuilder: (_, index) {
      final produto = produtos[index];
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const CircleAvatar(child: Icon(Icons.inventory_2_outlined)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          produto.nome,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(produto.tipo.singularCapital),
                      ],
                    ),
                  ),
                  _status(produto),
                ],
              ),
              const SizedBox(height: 12),
              Text('Quantidade/dose: ${produto.quantidadePadrao}'),
              Text('Valor padrão: ${moeda.format(produto.valor)}'),
              if (produto.observacoes.isNotEmpty) Text(produto.observacoes),
              Wrap(
                alignment: WrapAlignment.end,
                spacing: 8,
                children: [
                  TextButton.icon(
                    onPressed: () => _editar(produto),
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text('Editar'),
                  ),
                  TextButton.icon(
                    onPressed: () =>
                        repository.definirAtivo(produto.id, !produto.ativo),
                    icon: Icon(
                      produto.ativo
                          ? Icons.block_outlined
                          : Icons.refresh_rounded,
                    ),
                    label: Text(produto.ativo ? 'Inativar' : 'Reativar'),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );

  Widget _status(ProdutoModel produto) => Chip(
    label: Text(produto.ativo ? 'Ativo' : 'Inativo'),
    side: BorderSide.none,
    backgroundColor: produto.ativo
        ? const Color(0xFFD1FAE5)
        : const Color(0xFFE5E7EB),
  );
}

class CadastroProdutoPage extends StatefulWidget {
  const CadastroProdutoPage({
    super.key,
    required this.repository,
    this.produto,
  });

  final ProdutoRepository repository;
  final ProdutoModel? produto;

  @override
  State<CadastroProdutoPage> createState() => _CadastroProdutoPageState();
}

class _CadastroProdutoPageState extends State<CadastroProdutoPage> {
  final formKey = GlobalKey<FormState>();
  final nome = TextEditingController();
  final quantidade = TextEditingController();
  final valor = TextEditingController();
  final observacoes = TextEditingController();
  TipoTratamento tipo = TipoTratamento.remedio;
  bool salvando = false;

  @override
  void initState() {
    super.initState();
    final produto = widget.produto;
    if (produto == null) return;
    tipo = produto.tipo;
    nome.text = produto.nome;
    quantidade.text = produto.quantidadePadrao;
    valor.text = produto.valor.toStringAsFixed(2).replaceAll('.', ',');
    observacoes.text = produto.observacoes;
  }

  int? _centavos(String texto) {
    var limpo = texto.replaceAll(RegExp(r'[^0-9,.]'), '');
    if (limpo.isEmpty) return null;
    if (limpo.contains(',')) {
      limpo = limpo.replaceAll('.', '').replaceAll(',', '.');
    }
    final numero = double.tryParse(limpo);
    return numero == null ? null : (numero * 100).round();
  }

  Future<void> _salvar() async {
    if (!(formKey.currentState?.validate() ?? false)) return;
    setState(() => salvando = true);
    try {
      await widget.repository.salvar(
        ProdutoModel(
          id: widget.produto?.id ?? '',
          nome: nome.text,
          tipo: tipo,
          quantidadePadrao: quantidade.text,
          valorCentavos: _centavos(valor.text)!,
          observacoes: observacoes.text,
          ativo: widget.produto?.ativo ?? true,
        ),
      );
      if (mounted) Navigator.pop(context, true);
    } catch (erro) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar produto: $erro')),
        );
      }
    } finally {
      if (mounted) setState(() => salvando = false);
    }
  }

  @override
  void dispose() {
    nome.dispose();
    quantidade.dispose();
    valor.dispose();
    observacoes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFFF3F4F6),
    appBar: DesktopWindowScope.isInside(context)
        ? null
        : AppBar(
            title: Text(
              widget.produto == null ? 'Novo produto' : 'Editar produto',
            ),
          ),
    body: Form(
      key: formKey,
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Text(
            'Dados do produto',
            style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 18),
          DropdownButtonFormField<TipoTratamento>(
            key: const ValueKey('tipo_produto'),
            initialValue: tipo,
            decoration: const InputDecoration(
              labelText: 'Tipo do produto',
              border: OutlineInputBorder(),
            ),
            items: TipoTratamento.values
                .map(
                  (item) => DropdownMenuItem(
                    value: item,
                    child: Text(item.singularCapital),
                  ),
                )
                .toList(),
            onChanged: (item) => setState(() => tipo = item!),
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: nome,
            decoration: const InputDecoration(
              labelText: 'Nome do produto *',
              border: OutlineInputBorder(),
            ),
            validator: (texto) => texto == null || texto.trim().isEmpty
                ? 'Informe o nome do produto'
                : null,
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: quantidade,
            decoration: const InputDecoration(
              labelText: 'Quantidade / dose padrão *',
              hintText: 'Ex.: 10 ml, 1 comprimido ou 2 kg',
              border: OutlineInputBorder(),
            ),
            validator: (texto) => texto == null || texto.trim().isEmpty
                ? 'Informe a quantidade ou dose padrão'
                : null,
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: valor,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9,.]')),
            ],
            decoration: const InputDecoration(
              labelText: 'Valor padrão por animal/aplicação *',
              prefixText: 'R\$ ',
              border: OutlineInputBorder(),
            ),
            validator: (texto) {
              final centavos = _centavos(texto ?? '');
              return centavos == null || centavos <= 0
                  ? 'Informe um valor maior que zero'
                  : null;
            },
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: observacoes,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Observações',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 22),
          Wrap(
            alignment: WrapAlignment.end,
            spacing: 12,
            runSpacing: 8,
            children: [
              OutlinedButton(
                onPressed: salvando ? null : () => Navigator.maybePop(context),
                child: const Text('Cancelar'),
              ),
              FilledButton.icon(
                onPressed: salvando ? null : _salvar,
                icon: salvando
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.save),
                label: Text(
                  widget.produto == null
                      ? 'Salvar produto'
                      : 'Salvar alterações',
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
