import 'package:flutter/material.dart';
import '../../models/cliente_model.dart';
import '../../services/cliente_service.dart';
import 'cadastro_cliente_page.dart';

class ClientesPage extends StatelessWidget {
  ClientesPage({super.key});

  final ClienteService service = ClienteService();

  Color statusColor(bool ativo) => ativo ? Colors.green : Colors.red;

  String tipoTexto(TipoCliente tipo) {
    switch (tipo) {
      case TipoCliente.fisica:
        return 'Física';
      case TipoCliente.juridica:
        return 'Jurídica';
      case TipoCliente.rural:
        return 'Rural';
    }
  }

  void abrirDetalhes(BuildContext context, ClienteModel c) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(c.nomeExibicao),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Telefone: ${c.telefone}"),
              Text("Email: ${c.email}"),
              Text("Cidade: ${c.cidade}"),
              Text("Endereço: ${c.endereco} ${c.numero}"),
              Text("Bairro: ${c.bairro}"),
              Text("CEP: ${c.cep}"),
              Text("Tipo: ${tipoTexto(c.tipoCliente)}"),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Fechar"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),

      appBar: AppBar(
        title: const Text("Clientes"),
      ),

      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text("Novo Cliente"),
        onPressed: () async {
          // 🔥 CORREÇÃO IMPORTANTE: espera voltar e atualizar stream
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const CadastroClientePage(),
            ),
          );
        },
      ),

      body: StreamBuilder<List<ClienteModel>>(
        stream: service.streamClientes(),
        builder: (context, snapshot) {

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text("Erro: ${snapshot.error}"),
            );
          }

          final clientes = snapshot.data ?? [];

          if (clientes.isEmpty) {
            return const Center(
              child: Text("Nenhum cliente cadastrado"),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: clientes.length,
            itemBuilder: (context, index) {
              final c = clientes[index];

              return Card(
                child: ListTile(
                  onTap: () => abrirDetalhes(context, c),

                  leading: CircleAvatar(
                    backgroundColor: statusColor(c.ativo).withValues(alpha: 0.2),
                    child: Icon(
                      Icons.person,
                      color: statusColor(c.ativo),
                    ),
                  ),

                  title: Text(c.nomeExibicao),
                  subtitle: Text(c.telefone.isEmpty ? "Sem telefone" : c.telefone),

                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.grey,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}