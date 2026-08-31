import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../models/fornecedor_model.dart';
import '../../widgets/campos_grid.dart';
import '../../widgets/desktop_fit_viewport.dart';
import '../home/admin_top_bar.dart';

class CadastroFornecedorPage extends StatefulWidget {
  final FornecedorModel? fornecedorParaEditar;

  const CadastroFornecedorPage({super.key, this.fornecedorParaEditar});

  @override
  State<CadastroFornecedorPage> createState() => _CadastroFornecedorPageState();
}

class _CadastroFornecedorPageState extends State<CadastroFornecedorPage> {
  final _formKey = GlobalKey<FormState>();

  final nomeController = TextEditingController();
  final cpfCnpjController = TextEditingController();
  final categoriaController = TextEditingController();
  final telefoneController = TextEditingController();
  final emailController = TextEditingController();
  final enderecoController = TextEditingController();
  final observacoesController = TextEditingController();

  bool salvando = false;
  bool ativo = true;

  bool get editando => widget.fornecedorParaEditar != null;

  static const Color fundo = Color(0xFFF4F6FB);

  @override
  void initState() {
    super.initState();

    final f = widget.fornecedorParaEditar;

    if (f != null) {
      ativo = f.ativo;
      nomeController.text = f.nome;
      cpfCnpjController.text = f.cpfCnpj;
      categoriaController.text = f.categoria;
      telefoneController.text = f.telefone;
      emailController.text = f.email;
      enderecoController.text = f.endereco;
      observacoesController.text = f.observacoes;
    }
  }

  @override
  void dispose() {
    nomeController.dispose();
    cpfCnpjController.dispose();
    categoriaController.dispose();
    telefoneController.dispose();
    emailController.dispose();
    enderecoController.dispose();
    observacoesController.dispose();
    super.dispose();
  }

  Future<void> salvar() async {
    if (salvando || !_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      salvando = true;
    });

    try {
      final fornecedor = FornecedorModel(
        id: widget.fornecedorParaEditar?.id ?? '',
        nome: nomeController.text.trim(),
        cpfCnpj: cpfCnpjController.text.trim(),
        categoria: categoriaController.text.trim(),
        telefone: telefoneController.text.trim(),
        email: emailController.text.trim(),
        endereco: enderecoController.text.trim(),
        observacoes: observacoesController.text.trim(),
        ativo: ativo,
        dataCadastro:
            widget.fornecedorParaEditar?.dataCadastro ?? Timestamp.now(),
      );

      if (editando) {
        await FirebaseFirestore.instance
            .collection('fornecedores')
            .doc(fornecedor.id)
            .update(fornecedor.toMap());
      } else {
        await FirebaseFirestore.instance
            .collection('fornecedores')
            .add(fornecedor.toMap());
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            editando
                ? 'Fornecedor atualizado com sucesso'
                : 'Fornecedor cadastrado com sucesso',
          ),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro: $e')));
    } finally {
      if (mounted) {
        setState(() {
          salvando = false;
        });
      }
    }
  }

  Widget campo({
    required String label,
    required TextEditingController controller,
    bool obrigatorio = false,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? hint,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: TextFormField(
      controller: controller,
      enabled: !salvando,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: obrigatorio
          ? (value) => value == null || value.trim().isEmpty
                ? 'Campo obrigatório'
                : null
          : null,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
  );

  Widget _secao(String titulo) => Padding(
    padding: const EdgeInsets.only(top: 6, bottom: 10),
    child: Text(titulo, style: const TextStyle(fontWeight: FontWeight.bold)),
  );

  Widget _formulario() => Padding(
    padding: const EdgeInsets.all(16),
    child: Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 20,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            bottom: MediaQuery.sizeOf(context).width < 1000 ? 80 : 0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _secao('Dados do fornecedor'),
              CamposGrid(
                campos: [
                  campo(
                    label: 'Nome / Razão Social *',
                    controller: nomeController,
                    obrigatorio: true,
                  ),
                  campo(label: 'CPF / CNPJ', controller: cpfCnpjController),
                  campo(
                    label: 'Categoria',
                    hint: 'Ex.: Ração, Ferrageamento, Veterinário',
                    controller: categoriaController,
                  ),
                  campo(
                    label: 'Telefone',
                    controller: telefoneController,
                    keyboardType: TextInputType.phone,
                  ),
                  campo(
                    label: 'Email',
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                  ),
                ],
              ),
              _secao('Endereço'),
              campo(label: 'Endereço', controller: enderecoController),
              _secao('Observações'),
              campo(
                label: 'Observações',
                controller: observacoesController,
                maxLines: 3,
              ),
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                title: const Text('Fornecedor ativo'),
                value: ativo,
                onChanged: salvando
                    ? null
                    : (value) => setState(() => ativo = value),
              ),
            ],
          ),
        ),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.sizeOf(context).width >= 1000;
    return PopScope(
      canPop: !salvando,
      child: Scaffold(
        backgroundColor: fundo,
        appBar: AppBar(
          title: Text(editando ? 'Editar Fornecedor' : 'Novo Fornecedor'),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            tooltip: 'Fechar',
            icon: const Icon(Icons.close),
            onPressed: salvando ? null : () => Navigator.maybePop(context),
          ),
        ),
        body: Column(
          children: [
            if (isDesktop) const AdminTopBar(),
            Expanded(
              child: Form(key: _formKey, child: _formulario()),
            ),
          ],
        ),
        floatingActionButton: isDesktop
            ? null
            : FloatingActionButton.extended(
                onPressed: salvando ? null : salvar,
                icon: salvando
                    ? const SizedBox.square(
                        dimension: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save),
                label: const Text('Salvar'),
              ),
        bottomNavigationBar: isDesktop
            ? DesktopFormActions(
                primaryLabel: 'Salvar fornecedor',
                onPrimary: salvar,
                onCancel: () => Navigator.maybePop(context),
                loading: salvando,
              )
            : null,
      ),
    );
  }
}
