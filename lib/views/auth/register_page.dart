import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  late TabController _tabController;

  bool loading = false;

  // ================= CAMPOS (IGUAL CLIENTE) =================
  final nomeController = TextEditingController();
  final sobrenomeController = TextEditingController();
  final razaoSocialController = TextEditingController();
  final nomeFantasiaController = TextEditingController();

  final cpfCnpjController = TextEditingController();
  final telefoneController = TextEditingController();
  final emailController = TextEditingController();
  final senhaController = TextEditingController();

  final cepController = TextEditingController();
  final enderecoController = TextEditingController();
  final numeroController = TextEditingController();
  final bairroController = TextEditingController();
  final cidadeController = TextEditingController();
  final estadoController = TextEditingController();

  final nomeHarasController = TextEditingController();
  final idRuralController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  // ================= CEP =================
  Future<void> buscarCep(String cep) async {
    cep = cep.replaceAll(RegExp(r'[^0-9]'), '');
    if (cep.length != 8) return;

    try {
      final res =
          await http.get(Uri.parse('https://viacep.com.br/ws/$cep/json/'));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);

        if (data['erro'] == true) return;

        setState(() {
          enderecoController.text = data['logradouro'] ?? '';
          bairroController.text = data['bairro'] ?? '';
          cidadeController.text = data['localidade'] ?? '';
          estadoController.text = data['uf'] ?? '';
        });
      }
    } catch (_) {}
  }

  // ================= SALVAR =================
  Future<void> register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => loading = true);

    try {
      final tipo = _tabController.index;

      // 1. AUTH
      final userCred = await _auth.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: senhaController.text.trim(),
      );

      final uid = userCred.user!.uid;

      // 2. USERS (controle de acesso)
      await _db.collection('users').doc(uid).set({
        'uid': uid,
        'email': emailController.text.trim(),
        'role': 'cliente',
        'tipoCliente': tipo,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // 3. CLIENTE (MESMO PADRÃO DO CADASTRO CLIENTE)
      await _db.collection('clientes').doc(uid).set({
        'id': uid,
        'tipoCliente': tipo,

        'nome': nomeController.text.trim(),
        'sobrenome': sobrenomeController.text.trim(),
        'razaoSocial': razaoSocialController.text.trim(),
        'nomeFantasia': nomeFantasiaController.text.trim(),

        'cpfCnpj': cpfCnpjController.text.trim(),
        'telefone': telefoneController.text.trim(),
        'email': emailController.text.trim(),

        'cep': cepController.text.trim(),
        'endereco': enderecoController.text.trim(),
        'numero': numeroController.text.trim(),
        'bairro': bairroController.text.trim(),
        'cidade': cidadeController.text.trim(),
        'estado': estadoController.text.trim(),

        'nomeHaras': nomeHarasController.text.trim(),
        'idRural': idRuralController.text.trim(),

        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Cadastro realizado com sucesso!")),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro: $e")),
      );
    }

    setState(() => loading = false);
  }

  // ================= FIELD =================
  Widget field(String label, TextEditingController c,
      {bool required = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: c,
        validator: required
            ? (v) =>
                (v == null || v.trim().isEmpty) ? 'Campo obrigatório' : null
            : null,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget cepField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: cepController,
        keyboardType: TextInputType.number,
        onChanged: buscarCep,
        decoration: InputDecoration(
          labelText: 'CEP',
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget card(List<Widget> children) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 20,
                offset: const Offset(0, 6),
              )
            ],
          ),
          child: Column(children: children),
        ),
      ),
    );
  }

  // ================= ABAS =================
  Widget fisica() {
    return card([
      field('Nome', nomeController, required: true),
      field('Sobrenome', sobrenomeController, required: true),
      field('CPF', cpfCnpjController, required: true),
      field('Telefone', telefoneController, required: true),
      field('Email', emailController, required: true),
      field('Senha', senhaController, required: true),

      cepField(),
      field('Endereço', enderecoController),
      field('Número', numeroController),
      field('Bairro', bairroController),
      field('Cidade', cidadeController),
      field('Estado', estadoController),
    ]);
  }

  Widget juridica() {
    return card([
      field('Razão Social', razaoSocialController, required: true),
      field('Nome Fantasia', nomeFantasiaController),
      field('CNPJ', cpfCnpjController, required: true),
      field('Telefone', telefoneController),
      field('Email', emailController, required: true),
      field('Senha', senhaController, required: true),

      cepField(),
      field('Endereço', enderecoController),
      field('Número', numeroController),
      field('Bairro', bairroController),
      field('Cidade', cidadeController),
      field('Estado', estadoController),
    ]);
  }

  Widget rural() {
    return card([
      field('Nome', nomeController, required: true),
      field('Sobrenome', sobrenomeController, required: true),
      field('CPF', cpfCnpjController, required: true),
      field('Telefone', telefoneController),
      field('Email', emailController, required: true),
      field('Senha', senhaController, required: true),

      cepField(),
      field('Endereço', enderecoController),
      field('Número', numeroController),
      field('Bairro', bairroController),
      field('Cidade', cidadeController),
      field('Estado', estadoController),

      const SizedBox(height: 10),
      field('Nome do Haras', nomeHarasController, required: true),
      field('ID Rural', idRuralController, required: true),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),

      appBar: AppBar(
        title: const Text("Cadastro"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: "Física"),
            Tab(text: "Jurídica"),
            Tab(text: "Rural"),
          ],
        ),
      ),

      body: Form(
        key: _formKey,
        child: TabBarView(
          controller: _tabController,
          children: [
            fisica(),
            juridica(),
            rural(),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF5D4037),
        onPressed: loading ? null : register,
        icon: loading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Icon(Icons.check),
        label: const Text("Criar conta"),
      ),
    );
  }
}