import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../models/fornecedor_model.dart';
import '../home/admin_top_bar.dart';

class CadastroFornecedorPage extends StatefulWidget {
  final FornecedorModel? fornecedorParaEditar;

  const CadastroFornecedorPage({super.key, this.fornecedorParaEditar});

  @override
  State<CadastroFornecedorPage> createState() =>
      _CadastroFornecedorPageState();
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

  bool get editando => widget.fornecedorParaEditar != null;

  static const Color primaria = Color(0xFF4F46E5);
  static const Color fundo = Color(0xFFF3F4F6);

  @override
  void initState() {
    super.initState();

    final f = widget.fornecedorParaEditar;

    if (f != null) {
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
    if (!_formKey.currentState!.validate()) {
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

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro: $e')),
      );
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
    required IconData icon,
    required TextEditingController controller,
    bool required = true,
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: required
            ? (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Campo obrigatório';
                }
                return null;
              }
            : null,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: primaria),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 1000;

    return Scaffold(
      backgroundColor: fundo,
      appBar: isDesktop
          ? null
          : AppBar(
              backgroundColor: primaria,
              foregroundColor: Colors.white,
              title: Text(editando ? 'Editar Fornecedor' : 'Cadastro de Fornecedor'),
            ),
      body: Column(
        children: [
          if (isDesktop) const AdminTopBar(),
          if (isDesktop)
            Container(
              height: 56,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              color: Colors.white,
              alignment: Alignment.centerLeft,
              child: Text(
                editando ? 'Editar Fornecedor' : 'Cadastro de Fornecedor',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
          Expanded(
            child: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF4F46E5), Color(0xFF7C7AF0)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    editando ? 'Editar Fornecedor' : 'Novo Fornecedor',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    editando
                        ? 'Atualize os dados do fornecedor.'
                        : 'Cadastre os dados do fornecedor.',
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            campo(
              label: 'Nome / Razão Social',
              icon: Icons.storefront_outlined,
              controller: nomeController,
            ),

            campo(
              label: 'CPF / CNPJ',
              icon: Icons.badge_outlined,
              controller: cpfCnpjController,
              keyboardType: TextInputType.number,
              required: false,
            ),

            campo(
              label: 'Categoria (ex: Ração, Ferrageamento, Veterinário)',
              icon: Icons.category_outlined,
              controller: categoriaController,
              required: false,
            ),

            campo(
              label: 'Telefone',
              icon: Icons.phone_outlined,
              controller: telefoneController,
              keyboardType: TextInputType.phone,
              required: false,
            ),

            campo(
              label: 'Email',
              icon: Icons.email_outlined,
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              required: false,
            ),

            campo(
              label: 'Endereço',
              icon: Icons.location_on_outlined,
              controller: enderecoController,
              required: false,
            ),

            campo(
              label: 'Observações',
              icon: Icons.notes_outlined,
              controller: observacoesController,
              required: false,
            ),

            const SizedBox(height: 20),

            SizedBox(
              height: 55,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaria,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: salvando ? null : salvar,
                icon: salvando
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.save, color: Colors.white),
                label: Text(
                  salvando
                      ? 'SALVANDO...'
                      : (editando
                          ? 'SALVAR ALTERAÇÕES'
                          : 'CADASTRAR FORNECEDOR'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
          ),
        ],
      ),
    );
  }
}