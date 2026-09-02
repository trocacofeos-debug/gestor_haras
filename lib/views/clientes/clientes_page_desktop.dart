// ignore_for_file: unused_field, deprecated_member_use

import 'package:flutter/material.dart';

import '../../models/cliente_model.dart';
import '../../services/cliente_service.dart';
import '../../widgets/desktop_window.dart';

import '../home/admin_home.dart';
import 'cadastro_cliente_page.dart';
import '../home/admin_top_bar.dart';
import 'cliente_detalhes_page.dart';

class ClientesPageDesktop extends StatefulWidget {
  const ClientesPageDesktop({super.key});

  @override
  State<ClientesPageDesktop> createState() => _ClientesPageDesktopState();
}

class _ClientesPageDesktopState extends State<ClientesPageDesktop> {
  final ClienteService service = ClienteService();

  final TextEditingController buscaController = TextEditingController();

  final ValueNotifier<String> buscaNotifier = ValueNotifier("");

  // ==============================
  // CORES DASHBOARD CORPORATIVO
  // ==============================

  static const Color corSidebar = Color(0xFF111827);

  static const Color corPrimaria = Color(0xFF4F46E5);

  static const Color corFundo = Color(0xFFF3F4F6);

  static const Color corTexto = Color(0xFF111827);

  static const Color corSecundario = Color(0xFF6B7280);

  static const Color corBorda = Color(0xFFE5E7EB);

  @override
  void dispose() {
    buscaController.dispose();

    buscaNotifier.dispose();

    super.dispose();
  }

  // ==============================
  // VOLTAR DASHBOARD
  // ==============================

  void voltarDashboard() {
    Navigator.pushReplacement(
      context,

      MaterialPageRoute(builder: (_) => const AdminHome()),
    );
  }

  void abrirDetalhes(ClienteModel cliente) {
    abrirPopupDetalhesCliente(context, cliente);
  }

  void cadastrarCliente() {
    openDesktopWindow(
      context,
      title: 'Novo cliente',
      icon: Icons.person_add_alt_1_rounded,
      width: 1100,
      height: 760,
      builder: (_) => const CadastroClientePage(),
    );
  }

  String limparTexto(String valor) {
    return valor.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
  }

  String tipoTexto(TipoCliente tipo) {
    switch (tipo) {
      case TipoCliente.fisica:
        return "Pessoa Física";

      case TipoCliente.juridica:
        return "Pessoa Jurídica";

      case TipoCliente.rural:
        return "Haras / Rural";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: corFundo,

      body: SafeArea(
        child: Column(
          children: [
            const AdminTopBar(),

            _header(),
            _campoBusca(),

            Expanded(child: _conteudo()),
          ],
        ),
      ),
    );
  }

  // ==============================
  // HEADER CORPORATIVO
  // ==============================

  Widget _header() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: corBorda)),
      ),
      child: Row(
        children: [
          IconButton(
            tooltip: 'Voltar ao dashboard',
            onPressed: voltarDashboard,
            icon: const Icon(Icons.arrow_back, color: corTexto, size: 22),
          ),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'Clientes',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: corTexto,
              ),
            ),
          ),
          IconButton(
            tooltip: 'Cadastrar cliente',
            onPressed: cadastrarCliente,
            icon: const Icon(
              Icons.person_add_alt_1_rounded,
              color: corPrimaria,
              size: 22,
            ),
          ),
          IconButton(
            tooltip: 'Atualizar',
            onPressed: () => setState(() {}),
            icon: const Icon(Icons.refresh, color: corSecundario, size: 22),
          ),
        ],
      ),
    );
  }

  Widget _conteudo() {
    return StreamBuilder<List<ClienteModel>>(
      stream: service.streamClientes(),

      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: corPrimaria),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              "Erro ao carregar clientes\n${snapshot.error}",

              textAlign: TextAlign.center,
            ),
          );
        }

        final todos = snapshot.data ?? [];

        return ValueListenableBuilder<String>(
          valueListenable: buscaNotifier,

          builder: (context, busca, _) {
            final clientes = todos.where((cliente) {
              final filtro = limparTexto(busca);

              if (filtro.isEmpty) {
                return true;
              }

              return limparTexto(cliente.nomeExibicao).contains(filtro) ||
                  limparTexto(cliente.cpfCnpj).contains(filtro) ||
                  limparTexto(cliente.telefone).contains(filtro) ||
                  limparTexto(cliente.email).contains(filtro);
            }).toList();

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),

              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1440),
                  child: Column(
                    children: [
                      const SizedBox(height: 10),

                      _listaClientes(clientes),

                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _campoBusca() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: ValueListenableBuilder<String>(
        valueListenable: buscaNotifier,
        builder: (context, busca, _) => TextField(
          controller: buscaController,
          onChanged: (valor) => buscaNotifier.value = valor,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            hintText: 'Buscar cliente...',
            prefixIcon: const Icon(
              Icons.search,
              color: corSecundario,
              size: 20,
            ),
            suffixIcon: busca.isEmpty
                ? null
                : IconButton(
                    tooltip: 'Limpar busca',
                    icon: const Icon(Icons.close, size: 18),
                    onPressed: () {
                      buscaController.clear();
                      buscaNotifier.value = '';
                    },
                  ),
            isDense: true,
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: corBorda),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: corBorda),
            ),
          ),
        ),
      ),
    );
  }

  Widget _listaClientes(List<ClienteModel> clientes) {
    if (clientes.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(50),
        child: Text(
          "Nenhum cliente encontrado",
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return _tabelaClientes(clientes);
  }

  // =====================================================
  // TABELA (DESKTOP)
  // =====================================================

  Widget _tabelaClientes(List<ClienteModel> clientes) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(6),

        border: Border.all(color: corBorda),
      ),

      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),

        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,

          child: DataTable(
            showCheckboxColumn: false,
            headingRowHeight: 40,
            dataRowMinHeight: 48,
            dataRowMaxHeight: 56,
            horizontalMargin: 16,
            columnSpacing: 24,
            headingRowColor: MaterialStateProperty.all(corFundo),

            columns: const [
              DataColumn(label: Text('Nome')),
              DataColumn(label: Text('Tipo')),
              DataColumn(label: Text('Telefone')),
              DataColumn(label: Text('Email')),
              DataColumn(label: Text('Status')),
              DataColumn(label: Text('Ações')),
            ],

            rows: clientes.map((cliente) {
              return DataRow(
                cells: [
                  DataCell(
                    Text(
                      cliente.nomeExibicao.isEmpty
                          ? 'Cliente sem nome'
                          : cliente.nomeExibicao,

                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    onTap: () => abrirDetalhes(cliente),
                  ),

                  DataCell(Text(tipoTexto(cliente.tipoCliente))),

                  DataCell(
                    Text(cliente.telefone.isEmpty ? '-' : cliente.telefone),
                  ),

                  DataCell(Text(cliente.email.isEmpty ? '-' : cliente.email)),

                  DataCell(
                    Text(
                      cliente.ativo ? 'Ativo' : 'Inativo',
                      style: const TextStyle(
                        color: corSecundario,
                        fontSize: 12,
                      ),
                    ),
                  ),

                  DataCell(
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 15,
                        color: corPrimaria,
                      ),

                      tooltip: 'Ver detalhes',

                      onPressed: () => abrirDetalhes(cliente),
                    ),
                  ),
                ],

                onSelectChanged: (_) => abrirDetalhes(cliente),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  // =====================================================
  // CARDS (MOBILE)
  // =====================================================
}
