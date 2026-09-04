// ignore_for_file: deprecated_member_use

import 'dart:ui' as ui;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/fornecedor_model.dart';
import '../../models/medicamento_model.dart';
import '../../models/produto_model.dart';
import '../../services/produto_service.dart';
import '../../services/cloudflare_r2_service.dart';
import '../../widgets/desktop_window.dart';
import '../../widgets/produto_foto.dart';
import '../home/admin_top_bar.dart';

class ProdutosPage extends StatefulWidget {
  const ProdutosPage({
    super.key,
    this.repository,
    this.fornecedores,
    this.uploadService,
    this.seletorFoto,
  });

  final ProdutoRepository? repository;
  final Stream<List<FornecedorModel>>? fornecedores;
  final CloudflareR2Service? uploadService;
  final Future<PlatformFile?> Function()? seletorFoto;
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
      builder: (_) => CadastroProdutoPage(
        repository: repository,
        fornecedores: widget.fornecedores,
        uploadService: widget.uploadService,
        seletorFoto: widget.seletorFoto,
      ),
    );
  }

  Future<void> _editar(ProdutoModel produto) async {
    await openDesktopWindow<bool>(
      context,
      title: 'Editar produto',
      icon: Icons.edit_rounded,
      width: 760,
      height: 650,
      builder: (_) => CadastroProdutoPage(
        repository: repository,
        produto: produto,
        fornecedores: widget.fornecedores,
        uploadService: widget.uploadService,
        seletorFoto: widget.seletorFoto,
      ),
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
            DataColumn(label: Text('Categoria')),
            DataColumn(label: Text('Quantidade / dose padrão')),
            DataColumn(label: Text('Estoque')),
            DataColumn(label: Text('Fornecedor')),
            DataColumn(label: Text('Preço')),
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
        Row(
          children: [
            ProdutoFoto(url: produto.fotoUrl, tamanho: 34),
            const SizedBox(width: 10),
            Text(
              produto.nome,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
      DataCell(Text(produto.tipo.singularCapital)),
      DataCell(Text(produto.quantidadePadrao)),
      DataCell(Text(_formatarEstoque(produto.quantidadeEstoque))),
      DataCell(
        Text(produto.fornecedorNome.isEmpty ? '—' : produto.fornecedorNome),
      ),
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
                  ProdutoFoto(url: produto.fotoUrl, tamanho: 48),
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
              Text('Estoque: ${_formatarEstoque(produto.quantidadeEstoque)}'),
              if (produto.fornecedorNome.isNotEmpty)
                Text('Fornecedor: ${produto.fornecedorNome}'),
              Text('Preço do produto: ${moeda.format(produto.valor)}'),
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

  String _formatarEstoque(double valor) => valor == valor.roundToDouble()
      ? valor.toInt().toString()
      : NumberFormat.decimalPattern('pt_BR').format(valor);
}

class CadastroProdutoPage extends StatefulWidget {
  const CadastroProdutoPage({
    super.key,
    required this.repository,
    this.produto,
    this.fornecedores,
    this.uploadService,
    this.seletorFoto,
  });

  final ProdutoRepository repository;
  final ProdutoModel? produto;
  final Stream<List<FornecedorModel>>? fornecedores;
  final CloudflareR2Service? uploadService;
  final Future<PlatformFile?> Function()? seletorFoto;

  @override
  State<CadastroProdutoPage> createState() => _CadastroProdutoPageState();
}

class _CadastroProdutoPageState extends State<CadastroProdutoPage> {
  final formKey = GlobalKey<FormState>();
  final nome = TextEditingController();
  final quantidade = TextEditingController();
  final estoque = TextEditingController(text: '0');
  final valor = TextEditingController();
  final observacoes = TextEditingController();
  TipoTratamento tipo = TipoTratamento.remedio;
  String fornecedorId = '';
  String fornecedorNome = '';
  PlatformFile? foto;
  String? fotoEnviada;
  bool removerFotoExistente = false;
  bool selecionandoFoto = false;
  late final Stream<List<FornecedorModel>> fornecedores;
  late final CloudflareR2Service upload =
      widget.uploadService ?? CloudflareR2Service();
  bool salvando = false;
  bool get ocupado => salvando || selecionandoFoto;

  @override
  void initState() {
    super.initState();
    fornecedores =
        widget.fornecedores ??
        FirebaseFirestore.instance
            .collection('fornecedores')
            .orderBy('nome')
            .snapshots()
            .map(
              (snapshot) => snapshot.docs
                  .map((doc) => FornecedorModel.fromMap(doc.data(), doc.id))
                  .toList(),
            );
    final produto = widget.produto;
    if (produto == null) return;
    tipo = produto.tipo;
    nome.text = produto.nome;
    quantidade.text = produto.quantidadePadrao;
    estoque.text = produto.quantidadeEstoque
        .toStringAsFixed(
          produto.quantidadeEstoque == produto.quantidadeEstoque.roundToDouble()
              ? 0
              : 2,
        )
        .replaceAll('.', ',');
    fornecedorId = produto.fornecedorId;
    fornecedorNome = produto.fornecedorNome;
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

  double? _numero(String texto) {
    var limpo = texto.replaceAll(RegExp(r'[^0-9,.]'), '');
    if (limpo.isEmpty) return null;
    if (limpo.contains(',')) {
      limpo = limpo.replaceAll('.', '').replaceAll(',', '.');
    }
    return double.tryParse(limpo);
  }

  Future<void> _selecionarFoto() async {
    if (ocupado) return;
    setState(() => selecionandoFoto = true);
    try {
      final arquivo = widget.seletorFoto != null
          ? await widget.seletorFoto!()
          : (await FilePicker.platform.pickFiles(
              type: FileType.custom,
              allowedExtensions: const ['jpg', 'jpeg', 'png'],
              allowMultiple: false,
              withData: true,
            ))?.files.singleOrNull;
      if (!mounted || arquivo == null) return;
      final bytes = arquivo.bytes;
      final extensao = arquivo.extension?.toLowerCase();
      if (bytes == null ||
          bytes.isEmpty ||
          bytes.length > 10 * 1024 * 1024 ||
          !['jpg', 'jpeg', 'png'].contains(extensao)) {
        throw const FormatException('Foto inválida');
      }
      final codec = await ui.instantiateImageCodec(bytes, targetWidth: 700);
      try {
        final frame = await codec.getNextFrame();
        frame.image.dispose();
      } finally {
        codec.dispose();
      }
      if (mounted) {
        setState(() {
          foto = arquivo;
          fotoEnviada = null;
          removerFotoExistente = false;
        });
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Não foi possível abrir a foto. Use JPG ou PNG de até 10 MB.',
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => selecionandoFoto = false);
    }
  }

  Future<void> _salvar() async {
    if (ocupado || !(formKey.currentState?.validate() ?? false)) return;
    setState(() => salvando = true);
    try {
      var fotoUrl = removerFotoExistente ? '' : widget.produto?.fotoUrl ?? '';
      if (foto != null) {
        fotoEnviada ??= await upload.uploadArquivo(
          arquivo: foto!,
          pasta: 'produtos',
        );
        if (fotoEnviada!.trim().isEmpty) {
          fotoEnviada = null;
          throw Exception('O envio da foto não retornou uma URL.');
        }
        fotoUrl = fotoEnviada!;
      }
      await widget.repository.salvar(
        ProdutoModel(
          id: widget.produto?.id ?? '',
          nome: nome.text,
          tipo: tipo,
          quantidadePadrao: quantidade.text,
          valorCentavos: _centavos(valor.text)!,
          quantidadeEstoque: _numero(estoque.text)!,
          fornecedorId: fornecedorId,
          fornecedorNome: fornecedorNome,
          fotoUrl: fotoUrl,
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
    estoque.dispose();
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
          _fotoProduto(),
          const SizedBox(height: 14),
          DropdownButtonFormField<TipoTratamento>(
            key: const ValueKey('categoria_produto'),
            initialValue: tipo,
            decoration: const InputDecoration(
              labelText: 'Categoria',
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
            key: const ValueKey('quantidade_estoque'),
            controller: estoque,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9,.]')),
            ],
            decoration: const InputDecoration(
              labelText: 'Quantidade em estoque *',
              hintText: 'Ex.: 10, 25 ou 2,5',
              border: OutlineInputBorder(),
            ),
            validator: (texto) {
              final numero = _numero(texto ?? '');
              return numero == null || numero < 0
                  ? 'Informe uma quantidade válida'
                  : null;
            },
          ),
          const SizedBox(height: 14),
          StreamBuilder<List<FornecedorModel>>(
            stream: fornecedores,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Text('Erro ao carregar fornecedores: ${snapshot.error}');
              }
              if (!snapshot.hasData) {
                return const LinearProgressIndicator();
              }
              final lista = snapshot.data!
                  .where((item) => item.ativo || item.id == fornecedorId)
                  .toList();
              if (fornecedorId.isNotEmpty &&
                  !lista.any((item) => item.id == fornecedorId)) {
                lista.add(
                  FornecedorModel(
                    id: fornecedorId,
                    nome: fornecedorNome.isEmpty
                        ? 'Fornecedor não encontrado'
                        : fornecedorNome,
                    ativo: false,
                  ),
                );
              }
              final fornecedorExiste = lista.any(
                (item) => item.id == fornecedorId,
              );
              return DropdownButtonFormField<String>(
                key: const ValueKey('fornecedor_produto'),
                initialValue: fornecedorExiste ? fornecedorId : '',
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Fornecedor (opcional)',
                  border: OutlineInputBorder(),
                ),
                items: [
                  const DropdownMenuItem(
                    value: '',
                    child: Text('Nenhum fornecedor selecionado'),
                  ),
                  ...lista.map(
                    (item) => DropdownMenuItem(
                      value: item.id,
                      child: Text(
                        item.nome.isEmpty ? 'Fornecedor sem nome' : item.nome,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
                onChanged: (id) => setState(() {
                  fornecedorId = id ?? '';
                  fornecedorNome =
                      lista
                          .where((item) => item.id == id)
                          .map((item) => item.nome)
                          .firstOrNull ??
                      '';
                }),
              );
            },
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
              labelText: 'Preço do produto *',
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
                onPressed: ocupado ? null : () => Navigator.maybePop(context),
                child: const Text('Cancelar'),
              ),
              FilledButton.icon(
                onPressed: ocupado ? null : _salvar,
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

  Widget _fotoProduto() {
    final fotoAtual = removerFotoExistente ? '' : widget.produto?.fotoUrl ?? '';
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (foto != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.memory(
                  foto!.bytes!,
                  width: 96,
                  height: 96,
                  fit: BoxFit.cover,
                ),
              )
            else
              ProdutoFoto(url: fotoAtual, tamanho: 96),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Foto do produto',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'JPG ou PNG · até 10 MB',
                    style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                  ),
                  const SizedBox(height: 6),
                  TextButton.icon(
                    key: const ValueKey('selecionar_foto_produto'),
                    onPressed: ocupado ? null : _selecionarFoto,
                    icon: const Icon(Icons.add_photo_alternate_outlined),
                    label: Text(
                      selecionandoFoto ? 'Abrindo...' : 'Selecionar foto',
                    ),
                  ),
                  if (foto != null || fotoAtual.isNotEmpty)
                    TextButton.icon(
                      key: const ValueKey('remover_foto_produto'),
                      onPressed: ocupado
                          ? null
                          : () => setState(() {
                              foto = null;
                              fotoEnviada = null;
                              removerFotoExistente = true;
                            }),
                      icon: const Icon(Icons.delete_outline),
                      label: const Text('Remover foto'),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
