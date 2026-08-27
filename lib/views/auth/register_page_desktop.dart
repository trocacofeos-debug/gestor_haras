// ignore_for_file: unnecessary_underscores, deprecated_member_use

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class RegisterPageDesktop extends StatefulWidget {
  const RegisterPageDesktop({super.key});

  @override
  State<RegisterPageDesktop> createState() => _RegisterPageDesktopState();
}

class _RegisterPageDesktopState extends State<RegisterPageDesktop>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  late TabController _tabController;

  bool loading = false;

  bool ocultarSenha = true;

  final Color primaria = const Color(0xFF37474F);

  final Color fundo = const Color(0xFFF1F3F5);

  // =================================
  // CONTROLLERS
  // =================================

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

  final enderecoHarasController = TextEditingController();

  final cidadeHarasController = TextEditingController();

  final estadoHarasController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    nomeController.dispose();
    sobrenomeController.dispose();

    razaoSocialController.dispose();
    nomeFantasiaController.dispose();

    cpfCnpjController.dispose();

    telefoneController.dispose();

    emailController.dispose();
    senhaController.dispose();

    cepController.dispose();

    enderecoController.dispose();
    numeroController.dispose();
    bairroController.dispose();
    cidadeController.dispose();
    estadoController.dispose();

    nomeHarasController.dispose();
    idRuralController.dispose();

    enderecoHarasController.dispose();
    cidadeHarasController.dispose();
    estadoHarasController.dispose();

    _tabController.dispose();

    super.dispose();
  }

  // =================================
  // BUSCAR CEP
  // =================================

  Future<void> buscarCep(String cep) async {
    cep = cep.replaceAll(RegExp(r'[^0-9]'), '');

    if (cep.length != 8) {
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('https://viacep.com.br/ws/$cep/json/'),
      );

      if (response.statusCode != 200) {
        return;
      }

      final data = jsonDecode(response.body);

      if (data['erro'] == true) {
        return;
      }

      setState(() {
        enderecoController.text = data['logradouro'] ?? '';

        bairroController.text = data['bairro'] ?? '';

        cidadeController.text = data['localidade'] ?? '';

        estadoController.text = data['uf'] ?? '';
      });
    } catch (_) {}
  }

  // =================================
  // CADASTRO
  // =================================

  Future<void> register() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      loading = true;
    });

    try {
      final bool pessoaFisica = _tabController.index == 0;

      final userCred = await _auth.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: senhaController.text.trim(),
      );

      final uid = userCred.user!.uid;

      final tipoCliente = pessoaFisica ? 'fisica' : 'juridica';

      await _db.collection('users').doc(uid).set({
        'uid': uid,

        'email': emailController.text.trim(),

        'role': 'cliente',

        'tipoCliente': tipoCliente,

        'ativo': true,

        'createdAt': FieldValue.serverTimestamp(),
      });

      await _db.collection('clientes').doc(uid).set({
        'id': uid,

        'tipoCliente': tipoCliente,

        // =====================
        // PESSOA FÍSICA
        // =====================
        'nome': nomeController.text.trim(),

        'sobrenome': sobrenomeController.text.trim(),

        // =====================
        // EMPRESA / HARAS
        // =====================
        'razaoSocial': razaoSocialController.text.trim(),

        'nomeFantasia': nomeFantasiaController.text.trim(),

        // =====================
        // DADOS GERAIS
        // =====================
        'cpfCnpj': cpfCnpjController.text.trim(),

        'telefone': telefoneController.text.trim(),

        'email': emailController.text.trim(),

        // =====================
        // ENDEREÇO
        // =====================
        'cep': cepController.text.trim(),

        'endereco': enderecoController.text.trim(),

        'numero': numeroController.text.trim(),

        'bairro': bairroController.text.trim(),

        'cidade': cidadeController.text.trim(),

        'estado': estadoController.text.trim(),

        // =====================
        // HARAS
        // =====================
        'nomeHaras': nomeHarasController.text.trim(),

        'idRural': idRuralController.text.trim(),

        'enderecoHaras': enderecoHarasController.text.trim(),

        'cidadeHaras': cidadeHarasController.text.trim(),

        'estadoHaras': estadoHarasController.text.trim(),

        // =====================
        // SISTEMA
        // =====================
        'ativo': true,

        'dataCadastro': FieldValue.serverTimestamp(),
      });

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cadastro realizado com sucesso!')),
      );

      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      String erro = 'Erro ao criar conta';

      switch (e.code) {
        case 'email-already-in-use':
          erro = 'Este email já está cadastrado';
          break;

        case 'invalid-email':
          erro = 'Email inválido';
          break;

        case 'weak-password':
          erro = 'Senha muito fraca';
          break;
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(backgroundColor: Colors.red, content: Text(erro)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(backgroundColor: Colors.red, content: Text('Erro: $e')),
        );
      }
    }

    if (mounted) {
      setState(() {
        loading = false;
      });
    }
  }

  // =================================
  // DECORAÇÃO DOS CAMPOS
  // =================================

  InputDecoration _campo(String titulo, {IconData? icon, Widget? suffix}) {
    return InputDecoration(
      labelText: titulo,

      prefixIcon: icon != null ? Icon(icon, color: primaria) : null,

      suffixIcon: suffix,

      filled: true,

      fillColor: const Color(0xFFF5F5F5),

      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),

        borderSide: BorderSide(color: Colors.grey.shade300),
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),

        borderSide: BorderSide(color: primaria, width: 2),
      ),

      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
    );
  }

  // =================================
  // CAMPO PADRÃO
  // =================================

  Widget field(
    String label,
    TextEditingController controller, {
    bool required = false,
    bool password = false,
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextFormField(
        controller: controller,

        keyboardType: keyboardType,

        obscureText: password ? ocultarSenha : false,

        validator: required
            ? (value) {
                if (value == null || value.trim().isEmpty) {
                  return "Campo obrigatório";
                }
                return null;
              }
            : null,

        decoration: _campo(
          label,
          icon: _iconeCampo(label),

          suffix: password
              ? IconButton(
                  icon: Icon(
                    ocultarSenha ? Icons.visibility_off : Icons.visibility,
                    color: primaria,
                  ),
                  onPressed: () {
                    setState(() {
                      ocultarSenha = !ocultarSenha;
                    });
                  },
                )
              : null,
        ),
      ),
    );
  }

  // =================================
  // CEP
  // =================================

  Widget cepField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextFormField(
        controller: cepController,

        keyboardType: TextInputType.number,

        onChanged: buscarCep,

        decoration: _campo("CEP", icon: Icons.location_on_outlined),
      ),
    );
  }

  // =================================
  // ÍCONES AUTOMÁTICOS
  // =================================

  IconData _iconeCampo(String label) {
    final texto = label.toLowerCase();

    if (texto.contains("nome")) {
      return Icons.person_outline;
    }

    if (texto.contains("email")) {
      return Icons.email_outlined;
    }

    if (texto.contains("senha")) {
      return Icons.lock_outline;
    }

    if (texto.contains("telefone")) {
      return Icons.phone_outlined;
    }

    if (texto.contains("cpf")) {
      return Icons.badge_outlined;
    }

    if (texto.contains("cnpj")) {
      return Icons.business_outlined;
    }

    if (texto.contains("cidade")) {
      return Icons.location_city;
    }

    if (texto.contains("estado")) {
      return Icons.map_outlined;
    }

    if (texto.contains("bairro")) {
      return Icons.place_outlined;
    }

    return Icons.edit_outlined;
  }

  // =================================
  // LOGO
  // =================================

  Widget _logo() {
    return Container(
      width: 64,
      height: 64,

      padding: const EdgeInsets.all(11),

      decoration: BoxDecoration(
        color: primaria.withOpacity(.10),

        shape: BoxShape.circle,
      ),

      child: Center(
        child: Text(
          'GH',
          style: TextStyle(
            color: primaria,
            fontSize: 23,
            fontWeight: FontWeight.w800,
            letterSpacing: -1,
          ),
        ),
      ),
    );
  }

  // =================================
  // TÍTULO
  // =================================

  Widget _titulo() {
    return Column(
      children: [
        Text(
          "Gestor Haras",
          style: TextStyle(
            color: primaria,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 3),

        Text(
          "Cadastro de Cliente",
          style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
        ),
      ],
    );
  }

  // =================================
  // PAR DE CAMPOS LADO A LADO (DESKTOP)
  // =================================

  Widget _par(Widget a, Widget b) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: a),
        const SizedBox(width: 24),
        Expanded(child: b),
      ],
    );
  }

  // =================================
  // CABEÇALHO DE SEÇÃO COMPACTO
  // =================================

  Widget _secao(String texto) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          texto,
          style: TextStyle(
            color: primaria,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // =================================
  // CARD CORPORATIVO
  // =================================

  Widget card(List<Widget> children) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),

      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1200),

          padding: const EdgeInsets.all(24),

          decoration: BoxDecoration(
            color: Colors.white,

            borderRadius: BorderRadius.circular(24),

            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(.08),

                blurRadius: 25,

                offset: const Offset(0, 10),
              ),
            ],
          ),

          child: Column(children: children),
        ),
      ),
    );
  }

  // =================================
  // PESSOA FÍSICA
  // =================================

  Widget fisica() {
    return card([
      _logo(),

      const SizedBox(height: 12),

      _titulo(),

      const SizedBox(height: 18),

      _par(
        field("Nome", nomeController, required: true),
        field("Sobrenome", sobrenomeController, required: true),
      ),

      _par(
        field(
          "CPF",
          cpfCnpjController,
          required: true,
          keyboardType: TextInputType.number,
        ),
        field(
          "Telefone",
          telefoneController,
          required: true,
          keyboardType: TextInputType.phone,
        ),
      ),

      _par(
        field(
          "Email",
          emailController,
          required: true,
          keyboardType: TextInputType.emailAddress,
        ),
        field("Senha", senhaController, required: true, password: true),
      ),

      const SizedBox(height: 6),

      const Divider(),

      const SizedBox(height: 10),

      _par(cepField(), field("Endereço", enderecoController)),

      _par(
        field("Número", numeroController),
        field("Bairro", bairroController),
      ),

      _par(
        field("Cidade", cidadeController),
        field("Estado", estadoController),
      ),

      const SizedBox(height: 20),
    ]);
  }

  // =================================
  // EMPRESA / HARAS
  // =================================

  Widget juridicaRural() {
    return card([
      _logo(),

      const SizedBox(height: 12),

      _titulo(),

      const SizedBox(height: 18),

      _secao("Dados da Empresa"),

      _par(
        field("Razão Social", razaoSocialController, required: true),
        field("Nome Fantasia", nomeFantasiaController),
      ),

      _par(
        field(
          "CNPJ",
          cpfCnpjController,
          required: true,
          keyboardType: TextInputType.number,
        ),
        field(
          "Telefone",
          telefoneController,
          required: true,
          keyboardType: TextInputType.phone,
        ),
      ),

      _par(
        field(
          "Email",
          emailController,
          required: true,
          keyboardType: TextInputType.emailAddress,
        ),
        field("Senha", senhaController, required: true, password: true),
      ),

      const SizedBox(height: 6),

      const Divider(),

      const SizedBox(height: 10),

      _secao("Endereço da Empresa"),

      _par(cepField(), field("Endereço", enderecoController)),

      _par(
        field("Número", numeroController),
        field("Bairro", bairroController),
      ),

      _par(
        field("Cidade", cidadeController),
        field("Estado", estadoController),
      ),

      const SizedBox(height: 10),

      const Divider(),

      const SizedBox(height: 10),

      _secao("Dados do Haras"),

      _par(
        field("Nome do Haras", nomeHarasController, required: true),
        field("ID Rural", idRuralController, required: true),
      ),

      _par(
        field("Endereço do Haras", enderecoHarasController),
        field("Cidade do Haras", cidadeHarasController),
      ),

      field("Estado do Haras", estadoHarasController),

      const SizedBox(height: 20),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: fundo,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,

        centerTitle: true,

        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: primaria),
          onPressed: () {
            Navigator.pop(context);
          },
        ),

        title: Text(
          "Criar Conta",
          style: TextStyle(
            color: primaria,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),

        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),

          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),

            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade200,

                borderRadius: BorderRadius.circular(15),
              ),

              child: TabBar(
                controller: _tabController,

                dividerColor: Colors.transparent,

                indicator: BoxDecoration(
                  color: primaria,

                  borderRadius: BorderRadius.circular(15),
                ),

                labelColor: Colors.white,

                unselectedLabelColor: Colors.grey.shade700,

                tabs: const [
                  Tab(text: "Pessoa Física"),
                  Tab(text: "Haras / Empresa"),
                ],
              ),
            ),
          ),
        ),
      ),

      body: Form(
        key: _formKey,

        child: TabBarView(
          controller: _tabController,

          children: [fisica(), juridicaRural()],
        ),
      ),

      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),

          boxShadow: [
            BoxShadow(
              color: primaria.withOpacity(.25),

              blurRadius: 15,

              offset: const Offset(0, 6),
            ),
          ],
        ),

        child: FloatingActionButton.extended(
          heroTag: "btnCadastrar",

          backgroundColor: primaria,

          foregroundColor: Colors.white,

          elevation: 0,

          onPressed: loading ? null : register,

          icon: loading
              ? const SizedBox(
                  height: 22,
                  width: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(Icons.person_add_alt_1),

          label: Text(
            loading ? "CADASTRANDO..." : "CRIAR CONTA",

            style: const TextStyle(
              fontWeight: FontWeight.bold,

              letterSpacing: 1.2,
            ),
          ),
        ),
      ),
    );
  }
}
