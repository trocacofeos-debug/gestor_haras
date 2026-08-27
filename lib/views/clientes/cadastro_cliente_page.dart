import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;

import '../../models/cliente_model.dart';
import '../../services/cliente_service.dart';
import '../../widgets/campos_grid.dart';
import '../../widgets/desktop_fit_viewport.dart';
import '../home/admin_top_bar.dart';

class CadastroClientePage extends StatefulWidget {
  final ClienteModel? cliente;

  const CadastroClientePage({super.key, this.cliente});

  @override
  State<CadastroClientePage> createState() => _CadastroClientePageState();
}

class _CadastroClientePageState extends State<CadastroClientePage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final ClienteService _service = ClienteService();

  bool _loading = false;
  late TabController _tabController;

  // ================= CAMPOS =================
  final nomeController = TextEditingController();
  final sobrenomeController = TextEditingController();
  final razaoSocialController = TextEditingController();
  final nomeFantasiaController = TextEditingController();

  final cpfCnpjController = TextEditingController();
  final telefoneController = TextEditingController(); // 👈 contato
  final emailController = TextEditingController();

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

    if (widget.cliente != null) {
      _load();
    }
  }

  void _load() {
    final c = widget.cliente!;

    nomeController.text = c.nome;
    sobrenomeController.text = c.sobrenome;
    razaoSocialController.text = c.razaoSocial;
    nomeFantasiaController.text = c.nomeFantasia;

    cpfCnpjController.text = c.cpfCnpj;
    telefoneController.text = c.telefone;
    emailController.text = c.email;

    cepController.text = c.cep;
    enderecoController.text = c.endereco;
    numeroController.text = c.numero;
    bairroController.text = c.bairro;
    cidadeController.text = c.cidade;
    estadoController.text = c.estado;

    nomeHarasController.text = c.nomeHaras;
    idRuralController.text = c.idRural;

    _tabController.index = c.tipoCliente.index;
  }

  // ================= CEP =================
  Future<void> buscarCep(String cep) async {
    cep = cep.replaceAll(RegExp(r'[^0-9]'), '');
    if (cep.length != 8) return;

    try {
      final res = await http.get(
        Uri.parse('https://viacep.com.br/ws/$cep/json/'),
      );

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

  // ================= UI FIELD =================
  Widget field(String label, TextEditingController c, {bool required = false}) {
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
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
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
        onChanged: (v) => buscarCep(v),
        decoration: InputDecoration(
          labelText: 'CEP',
          prefixIcon: const Icon(Icons.location_on_outlined),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
    );
  }

  Widget secao(String titulo) {
    return Padding(
      padding: const EdgeInsets.only(top: 6, bottom: 10),
      child: Text(titulo, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }

  Widget card(List<Widget> children) {
    final conteudo = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
    final desktop = MediaQuery.of(context).size.width >= 1000;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              // ignore: deprecated_member_use
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: desktop
            ? FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.topCenter,
                child: SizedBox(width: 1180, child: conteudo),
              )
            : SingleChildScrollView(child: conteudo),
      ),
    );
  }

  // ================= ABAS =================
  Widget fisica() {
    return card([
      CamposGrid(
        campos: [
          field('Nome', nomeController, required: true),
          field('Sobrenome', sobrenomeController, required: true),
          field('CPF', cpfCnpjController, required: true),
          field('Telefone de contato', telefoneController, required: true),
          field('E-mail', emailController),
        ],
      ),
      secao('Endereço'),
      CamposGrid(
        campos: [
          cepField(),
          field('Endereço', enderecoController),
          field('Número', numeroController),
          field('Bairro', bairroController),
          field('Cidade', cidadeController),
          field('Estado', estadoController),
        ],
      ),
    ]);
  }

  Widget juridica() {
    return card([
      CamposGrid(
        campos: [
          field('Razão Social', razaoSocialController, required: true),
          field('Nome Fantasia', nomeFantasiaController),
          field('CNPJ', cpfCnpjController, required: true),
          field('Telefone de contato', telefoneController),
        ],
      ),
      secao('Endereço'),
      CamposGrid(
        campos: [
          cepField(),
          field('Endereço', enderecoController),
          field('Número', numeroController),
          field('Bairro', bairroController),
          field('Cidade', cidadeController),
          field('Estado', estadoController),
        ],
      ),
    ]);
  }

  Widget rural() {
    return card([
      CamposGrid(
        campos: [
          field('Nome', nomeController, required: true),
          field('Sobrenome', sobrenomeController, required: true),
          field('CPF', cpfCnpjController, required: true),
          field('Telefone de contato', telefoneController),
        ],
      ),
      secao('Endereço'),
      CamposGrid(
        campos: [
          cepField(),
          field('Endereço', enderecoController),
          field('Número', numeroController),
          field('Bairro', bairroController),
          field('Cidade', cidadeController),
          field('Estado', estadoController),
        ],
      ),
      secao('Dados do Haras'),
      CamposGrid(
        campos: [
          field('Nome do Haras', nomeHarasController, required: true),
          field('ID Rural', idRuralController, required: true),
        ],
      ),
    ]);
  }

  // ================= SALVAR =================
  Future<void> salvar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      final tipo = TipoCliente.values[_tabController.index];

      final cliente = ClienteModel(
        id: widget.cliente?.id ?? '',
        tipoCliente: tipo,
        nome: nomeController.text.trim(),
        sobrenome: sobrenomeController.text.trim(),
        razaoSocial: razaoSocialController.text.trim(),
        nomeFantasia: nomeFantasiaController.text.trim(),
        cpfCnpj: cpfCnpjController.text.trim(),
        telefone: telefoneController.text.trim(),
        email: emailController.text.trim(),
        cep: cepController.text.trim(),
        endereco: enderecoController.text.trim(),
        numero: numeroController.text.trim(),
        bairro: bairroController.text.trim(),
        cidade: cidadeController.text.trim(),
        estado: estadoController.text.trim(),
        nomeHaras: nomeHarasController.text.trim(),
        idRural: idRuralController.text.trim(),
        ativo: true,
        dataCadastro: widget.cliente?.dataCadastro ?? Timestamp.now(),
      );

      if (widget.cliente == null) {
        await _service.salvarCliente(cliente);
      } else {
        await _service.atualizarCliente(cliente);
      }

      if (mounted) Navigator.pop(context);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 1000;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),

      body: Column(
        children: [
          if (isDesktop) const AdminTopBar(),
          AppBar(
            title: Text(
              widget.cliente == null ? 'Novo Cliente' : 'Editar Cliente',
            ),
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            elevation: 0,
            bottom: TabBar(
              controller: _tabController,
              labelColor: Colors.black,
              indicatorColor: Colors.blue,
              tabs: const [
                Tab(text: 'Física'),
                Tab(text: 'Jurídica'),
                Tab(text: 'Rural'),
              ],
            ),
          ),
          Expanded(
            child: Form(
              key: _formKey,
              child: TabBarView(
                controller: _tabController,
                children: [fisica(), juridica(), rural()],
              ),
            ),
          ),
        ],
      ),

      floatingActionButton: isDesktop
          ? null
          : FloatingActionButton.extended(
              onPressed: _loading ? null : salvar,
              icon: _loading
                  ? const CircularProgressIndicator(strokeWidth: 2)
                  : const Icon(Icons.save),
              label: const Text("Salvar"),
            ),
      bottomNavigationBar: isDesktop
          ? DesktopFormActions(
              primaryLabel: 'Salvar cliente',
              onPrimary: salvar,
              onCancel: () => Navigator.maybePop(context),
              loading: _loading,
            )
          : null,
    );
  }
}
