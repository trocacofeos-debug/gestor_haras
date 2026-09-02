import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../models/funcionario_model.dart';
import '../../models/permissao_acesso.dart';
import '../../widgets/desktop_window.dart';
import 'funcionario_permissoes_page.dart';

class PermissoesFuncionariosPage extends StatefulWidget {
  const PermissoesFuncionariosPage({super.key, this.funcionarios});

  final Stream<List<FuncionarioModel>>? funcionarios;

  @override
  State<PermissoesFuncionariosPage> createState() =>
      _PermissoesFuncionariosPageState();
}

class _PermissoesFuncionariosPageState
    extends State<PermissoesFuncionariosPage> {
  final busca = TextEditingController();
  late final Stream<List<FuncionarioModel>> funcionarios;

  @override
  void initState() {
    super.initState();
    funcionarios =
        widget.funcionarios ??
        FirebaseFirestore.instance
            .collection('funcionarios')
            .orderBy('nome')
            .snapshots()
            .map(
              (snapshot) => snapshot.docs
                  .map((doc) => FuncionarioModel.fromMap(doc.data(), doc.id))
                  .toList(),
            );
  }

  @override
  void dispose() {
    busca.dispose();
    super.dispose();
  }

  Future<void> _abrir(FuncionarioModel funcionario) async {
    if (MediaQuery.sizeOf(context).width >= 1000) {
      await openDesktopWindow<bool>(
        context,
        title: 'Permissões de ${funcionario.nome}',
        icon: Icons.admin_panel_settings_outlined,
        builder: (_) => FuncionarioPermissoesPage(funcionario: funcionario),
      );
    } else {
      await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (_) => FuncionarioPermissoesPage(funcionario: funcionario),
        ),
      );
    }
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (!ControleAcesso.acessoTotal) {
      return const Scaffold(
        body: Center(
          child: Text('Apenas administradores podem alterar acessos.'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: DesktopWindowScope.isInside(context)
          ? null
          : AppBar(title: const Text('Permissões')),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: busca,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Buscar funcionário...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: busca.text.isEmpty
                    ? null
                    : IconButton(
                        tooltip: 'Limpar busca',
                        onPressed: () => setState(busca.clear),
                        icon: const Icon(Icons.close),
                      ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<FuncionarioModel>>(
              stream: funcionarios,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Erro ao carregar funcionários: ${snapshot.error}',
                    ),
                  );
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final termo = busca.text.trim().toLowerCase();
                final itens = snapshot.data!
                    .where(
                      (item) =>
                          termo.isEmpty ||
                          item.nome.toLowerCase().contains(termo) ||
                          item.email.toLowerCase().contains(termo),
                    )
                    .toList();
                if (itens.isEmpty) {
                  return const Center(
                    child: Text('Nenhum funcionário encontrado.'),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: itens.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final funcionario = itens[index];
                    final liberadas = funcionario.permissoes.length;
                    return Card(
                      child: ListTile(
                        key: ValueKey(
                          'funcionario_permissoes_${funcionario.id}',
                        ),
                        leading: CircleAvatar(
                          child: Text(
                            funcionario.nome.trim().isEmpty
                                ? '?'
                                : funcionario.nome.trim()[0].toUpperCase(),
                          ),
                        ),
                        title: Text(
                          funcionario.nome.isEmpty
                              ? 'Funcionário sem nome'
                              : funcionario.nome,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        subtitle: Text(
                          '${funcionario.email.isEmpty ? 'Sem email cadastrado' : funcionario.email}\n'
                          '$liberadas de ${ModuloAcesso.values.length} módulos liberados',
                        ),
                        isThreeLine: true,
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => _abrir(funcionario),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
