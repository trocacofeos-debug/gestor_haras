import 'package:flutter/material.dart';

import '../../models/funcionario_model.dart';
import '../../models/permissao_acesso.dart';
import '../../services/funcionario_permissoes_service.dart';
import '../../widgets/desktop_window.dart';

class FuncionarioPermissoesPage extends StatefulWidget {
  const FuncionarioPermissoesPage({
    super.key,
    required this.funcionario,
    this.service,
    this.contasService,
  });

  final FuncionarioModel funcionario;
  final FuncionarioPermissoesRepository? service;
  final FuncionarioContasRepository? contasService;

  @override
  State<FuncionarioPermissoesPage> createState() =>
      _FuncionarioPermissoesPageState();
}

class _FuncionarioPermissoesPageState extends State<FuncionarioPermissoesPage> {
  late final FuncionarioPermissoesRepository service =
      widget.service ?? FuncionarioPermissoesService();
  late final FuncionarioContasRepository contasService =
      widget.contasService ?? FuncionarioContasService();
  late final Stream<List<ContaAcessoFuncionario>> contas = contasService
      .listarContas();
  late final Set<String> selecionadas = {...widget.funcionario.permissoes};
  bool salvando = false;
  bool vinculando = false;
  String? contaSelecionadaUid;

  Future<void> _vincularConta() async {
    final uid = contaSelecionadaUid;
    if (uid == null || vinculando) return;
    setState(() => vinculando = true);
    try {
      await contasService.vincularComoFuncionario(
        uid: uid,
        funcionarioId: widget.funcionario.id,
        permissoes: selecionadas,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Conta definida como funcionário.')),
      );
    } catch (erro) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao vincular conta: $erro')),
        );
      }
    } finally {
      if (mounted) setState(() => vinculando = false);
    }
  }

  Future<void> _salvar() async {
    if (salvando) return;
    setState(() => salvando = true);
    try {
      final resultado = await service.salvar(
        funcionarioId: widget.funcionario.id,
        email: widget.funcionario.email,
        permissoes: selecionadas,
      );
      if (!mounted) return;
      final aviso = resultado.contasVinculadas == 0
          ? 'Permissões salvas. Para entrar, o funcionário precisa ter uma conta com o mesmo email do cadastro.'
          : 'Permissões salvas e acesso da conta atualizado.';
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(aviso)));
      Navigator.pop(context, true);
    } catch (erro) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar permissões: $erro')),
        );
      }
    } finally {
      if (mounted) setState(() => salvando = false);
    }
  }

  void _marcarTodos(bool marcar) => setState(() {
    selecionadas
      ..clear()
      ..addAll(marcar ? ModuloAcesso.values.map((item) => item.id) : const []);
  });

  @override
  Widget build(BuildContext context) {
    final todos = selecionadas.length == ModuloAcesso.values.length;
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: DesktopWindowScope.isInside(context)
          ? null
          : AppBar(title: const Text('Permissões de acesso')),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          color: Colors.white,
          child: Wrap(
            alignment: WrapAlignment.end,
            spacing: 12,
            runSpacing: 8,
            children: [
              OutlinedButton(
                onPressed: salvando ? null : () => Navigator.maybePop(context),
                child: const Text('Cancelar'),
              ),
              FilledButton.icon(
                key: const ValueKey('salvar_permissoes'),
                onPressed: salvando ? null : _salvar,
                icon: salvando
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.save_outlined),
                label: Text(salvando ? 'Salvando...' : 'Salvar permissões'),
              ),
            ],
          ),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                widget.funcionario.nome.isEmpty
                    ? 'Funcionário'
                    : widget.funcionario.nome,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.funcionario.email.isEmpty
                    ? 'Cadastre um email no funcionário para vinculá-lo a uma conta.'
                    : 'Conta vinculada pelo email: ${widget.funcionario.email}',
                style: const TextStyle(color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 18),
              _seletorConta(),
              const SizedBox(height: 10),
              Card(
                child: SwitchListTile(
                  key: const ValueKey('permissao_todas'),
                  title: const Text(
                    'Permitir todos os módulos',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  subtitle: const Text(
                    'Você ainda pode desmarcar módulos individualmente.',
                  ),
                  value: todos,
                  onChanged: salvando ? null : _marcarTodos,
                ),
              ),
              const SizedBox(height: 10),
              for (final modulo in ModuloAcesso.values)
                Card(
                  child: CheckboxListTile(
                    key: ValueKey('permissao_${modulo.id}'),
                    title: Text(modulo.titulo),
                    subtitle: Text(modulo.descricao),
                    secondary: Icon(_icone(modulo)),
                    value: selecionadas.contains(modulo.id),
                    onChanged: salvando
                        ? null
                        : (marcado) => setState(() {
                            if (marcado == true) {
                              selecionadas.add(modulo.id);
                            } else {
                              selecionadas.remove(modulo.id);
                            }
                          }),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _seletorConta() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.manage_accounts_outlined),
                SizedBox(width: 10),
                Text(
                  'Conta de acesso',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ],
            ),
            const SizedBox(height: 6),
            const Text(
              'Escolha uma conta cadastrada para transformá-la em funcionário.',
              style: TextStyle(color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 14),
            StreamBuilder<List<ContaAcessoFuncionario>>(
              stream: contas,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Text('Erro ao carregar contas: ${snapshot.error}');
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final itens = snapshot.data!;
                if (itens.isEmpty) {
                  return const Text('Nenhuma conta disponível.');
                }
                ContaAcessoFuncionario? vinculada;
                for (final conta in itens) {
                  if (conta.vinculadaAo(widget.funcionario.id)) {
                    vinculada = conta;
                    break;
                  }
                }
                final valor = contaSelecionadaUid ?? vinculada?.uid;
                if (contaSelecionadaUid == null && vinculada != null) {
                  contaSelecionadaUid = vinculada.uid;
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    DropdownButtonFormField<String>(
                      key: const ValueKey('conta_funcionario'),
                      initialValue: valor,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Conta cadastrada',
                        border: OutlineInputBorder(),
                      ),
                      items: itens
                          .map(
                            (conta) => DropdownMenuItem(
                              value: conta.uid,
                              child: Text(
                                conta.email.isEmpty
                                    ? 'Conta sem email (${conta.uid})'
                                    : conta.email,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: vinculando
                          ? null
                          : (value) =>
                                setState(() => contaSelecionadaUid = value),
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: FilledButton.icon(
                        key: const ValueKey('vincular_conta_funcionario'),
                        onPressed: valor == null || vinculando
                            ? null
                            : _vincularConta,
                        icon: vinculando
                            ? const SizedBox.square(
                                dimension: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.badge_outlined),
                        label: Text(
                          vinculando
                              ? 'Vinculando...'
                              : 'Definir como funcionário',
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  IconData _icone(ModuloAcesso modulo) => switch (modulo) {
    ModuloAcesso.dashboard => Icons.dashboard_outlined,
    ModuloAcesso.clientes => Icons.people_alt_outlined,
    ModuloAcesso.animais => Icons.pets_outlined,
    ModuloAcesso.funcionarios => Icons.badge_outlined,
    ModuloAcesso.fornecedores => Icons.storefront_outlined,
    ModuloAcesso.produtos => Icons.inventory_2_outlined,
    ModuloAcesso.gestao => Icons.account_balance_wallet_outlined,
    ModuloAcesso.propostas => Icons.description_outlined,
    ModuloAcesso.site => Icons.public_outlined,
  };
}
