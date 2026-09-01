// ignore_for_file: unused_field, deprecated_member_use

import 'package:flutter/material.dart';

import '../../models/cliente_model.dart';
import '../../services/cliente_service.dart';

import '../home/admin_home.dart';
import 'cliente_detalhes_page.dart';

class ClientesPageMobile extends StatefulWidget {
  const ClientesPageMobile({super.key});

  @override
  State<ClientesPageMobile> createState() => _ClientesPageMobileState();
}

class _ClientesPageMobileState extends State<ClientesPageMobile> {
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

  String limparTexto(String valor) {
    return valor.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
  }

  String inicialCliente(ClienteModel cliente) {
    final nome = cliente.nomeExibicao.trim();

    if (nome.isEmpty) {
      return "?";
    }

    return nome.substring(0, 1).toUpperCase();
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

  Color statusColor(bool ativo) {
    return ativo ? Colors.green : Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: corFundo,
      appBar: _header(),
      body: Column(
        children: [
          _campoBusca(),
          Expanded(child: _conteudo()),
        ],
      ),
    );
  }

  // ==============================
  // HEADER CORPORATIVO
  // ==============================

  PreferredSizeWidget _header() => AppBar(
    leading: IconButton(
      tooltip: 'Voltar ao dashboard',
      onPressed: voltarDashboard,
      icon: const Icon(Icons.arrow_back_rounded),
    ),
    title: const Text('Clientes'),
    actions: [
      IconButton(
        tooltip: 'Atualizar',
        onPressed: () => setState(() {}),
        icon: const Icon(Icons.refresh_rounded),
      ),
      const SizedBox(width: 6),
    ],
  );

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

              child: Column(
                children: [
                  const SizedBox(height: 10),

                  _listaClientes(clientes),

                  const SizedBox(height: 30),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _campoBusca() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
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

    return _listaClientesCards(clientes);
  }

  Widget _listaClientesCards(List<ClienteModel> clientes) {
    return ListView.builder(
      shrinkWrap: true,

      physics: const NeverScrollableScrollPhysics(),

      padding: const EdgeInsets.symmetric(horizontal: 16),

      itemCount: clientes.length,

      itemBuilder: (context, index) {
        return _clienteCard(clientes[index]);
      },
    );
  }

  Widget _clienteCard(ClienteModel cliente) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => abrirDetalhes(cliente),
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: corBorda),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: corPrimaria.withOpacity(.10),
                child: Text(
                  inicialCliente(cliente),
                  style: const TextStyle(
                    color: corPrimaria,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cliente.nomeExibicao.isEmpty
                          ? 'Cliente sem nome'
                          : cliente.nomeExibicao,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: corTexto,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      cliente.telefone.isEmpty
                          ? 'Sem telefone'
                          : cliente.telefone,
                      style: const TextStyle(
                        color: corSecundario,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      tipoTexto(cliente.tipoCliente),
                      style: const TextStyle(
                        color: corSecundario,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: cliente.ativo
                      ? const Color(0xFFDCFCE7)
                      : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  cliente.ativo ? 'Ativo' : 'Inativo',
                  style: TextStyle(
                    color: cliente.ativo
                        ? const Color(0xFF166534)
                        : corSecundario,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: corSecundario,
                size: 21,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
