import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../widgets/app_dialogs.dart';
import '../../models/funcionario_model.dart';
import '../../models/permissao_acesso.dart';
import '../../services/funcionario_cadastro_formatos.dart';
import '../../widgets/campos_grid.dart';
import '../../widgets/desktop_window.dart';
import '../../widgets/funcionario_foto.dart';
import 'cadastro_funcionario_page.dart';
import 'funcionario_permissoes_page.dart';

Future<void> abrirPopupDetalhesFuncionario(BuildContext context, String id) =>
    showAppDialog<void>(
      context: context,
      title: 'Detalhes do funcionário',
      builder: (ctx) => Dialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1160, maxHeight: 800),
          child: SizedBox(
            width: double.infinity,
            height: MediaQuery.sizeOf(ctx).height * .85,
            child: DesktopWindowScope(
              child: FuncionarioDetalhesPage(funcionarioId: id),
            ),
          ),
        ),
      ),
    );

class FuncionarioDetalhesPage extends StatelessWidget {
  final String funcionarioId;
  const FuncionarioDetalhesPage({super.key, required this.funcionarioId});
  Widget _campo(String titulo, String valor) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          titulo,
          style: const TextStyle(color: Color(0xFF6B7280), fontSize: 12),
        ),
        const SizedBox(height: 4),
        SelectableText(
          valor.isEmpty ? '—' : valor,
          style: const TextStyle(fontSize: 14),
        ),
      ],
    ),
  );
  Widget _grupo(String titulo, List<Widget> campos) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      const SizedBox(height: 16),
      Text(
        titulo,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
      ),
      const SizedBox(height: 12),
      CamposGrid(maximoColunas: 3, larguraMinimaColuna: 240, campos: campos),
      const Divider(color: Color(0xFFE5E7EB)),
    ],
  );
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.white,
    appBar: AppBar(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      title: const Text(
        'Detalhes do funcionário',
        style: TextStyle(fontSize: 18),
      ),
      leading: IconButton(
        tooltip: 'Fechar',
        icon: const Icon(Icons.close),
        onPressed: () => Navigator.maybePop(context),
      ),
    ),
    body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('funcionarios')
          .doc(funcionarioId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(
            child: Text('Não foi possível carregar o funcionário.'),
          );
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.data!.exists) {
          return const Center(child: Text('Funcionário não encontrado.'));
        }
        final f = FuncionarioModel.fromMap(
          snapshot.data!.data()!,
          funcionarioId,
        );
        final mapa = f.toMap();
        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FuncionarioFoto(url: f.fotoUrl, tamanho: 80),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          f.nome.isEmpty ? 'Funcionário sem nome' : f.nome,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          f.cargo,
                          style: const TextStyle(color: Color(0xFF6B7280)),
                        ),
                        const SizedBox(height: 6),
                        Text(f.ativo ? 'Ativo' : 'Inativo'),
                      ],
                    ),
                  ),
                  Wrap(
                    children: [
                      if (ControleAcesso.acessoTotal)
                        IconButton(
                          tooltip: 'Permissões de acesso',
                          icon: const Icon(
                            Icons.admin_panel_settings_outlined,
                            color: Color(0xFF0F766E),
                          ),
                          onPressed: () => openDesktopWindow(
                            context,
                            title: 'Permissões de acesso',
                            icon: Icons.admin_panel_settings_outlined,
                            width: 800,
                            height: 760,
                            builder: (_) =>
                                FuncionarioPermissoesPage(funcionario: f),
                          ),
                        ),
                      IconButton(
                        tooltip: 'Editar funcionário',
                        icon: const Icon(
                          Icons.edit_outlined,
                          color: Color(0xFF4F46E5),
                        ),
                        onPressed: () => openDesktopWindow(
                          context,
                          title: 'Editar funcionário',
                          builder: (_) =>
                              CadastroFuncionarioPage(funcionarioParaEditar: f),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              _grupo('Dados pessoais e contato', [
                _campo('CPF', f.cpf),
                _campo(
                  'Data de nascimento',
                  FuncionarioCadastroFormatos.data(f.dataNascimento),
                ),
                _campo('Telefone / WhatsApp', f.telefone),
                _campo('Email', f.email),
              ]),
              _grupo('Vínculo com o haras', [
                _campo('Cargo', f.cargo),
                _campo('Matrícula', f.matricula),
                _campo('Tipo de vínculo', f.tipoVinculo),
                _campo('Jornada / horário', f.jornada),
                _campo(
                  'Salário',
                  'R\$ ${FuncionarioCadastroFormatos.salario(f.salario)}',
                ),
                _campo(
                  'Admissão',
                  FuncionarioCadastroFormatos.data(f.dataAdmissao),
                ),
                _campo(
                  'Desligamento',
                  FuncionarioCadastroFormatos.data(f.dataDesligamento),
                ),
              ]),
              if (ControleAcesso.acessoTotal)
                _grupo('Acesso ao sistema', [
                  _campo(
                    'Módulos permitidos',
                    f.permissoes.isEmpty
                        ? 'Nenhum módulo liberado'
                        : ModuloAcesso.values
                              .where((m) => f.permissoes.contains(m.id))
                              .map((m) => m.titulo)
                              .join(', '),
                  ),
                ]),
              _grupo('Carteira de trabalho e identificação profissional', [
                for (final k in [
                  'ctpsNumero',
                  'ctpsSerie',
                  'ctpsUf',
                  'pisPasep',
                ])
                  _campo(
                    FuncionarioModel.camposAdicionais[k]!,
                    mapa[k] as String,
                  ),
              ]),
              _grupo('Endereço', [
                for (final k in [
                  'cep',
                  'endereco',
                  'numero',
                  'complemento',
                  'bairro',
                  'cidade',
                  'estado',
                ])
                  _campo(
                    FuncionarioModel.camposAdicionais[k]!,
                    mapa[k] as String,
                  ),
              ]),
              _grupo('Contato de emergência', [
                for (final k in [
                  'emergenciaNome',
                  'emergenciaTelefone',
                  'emergenciaParentesco',
                ])
                  _campo(
                    FuncionarioModel.camposAdicionais[k]!,
                    mapa[k] as String,
                  ),
              ]),
              if (f.observacoes.isNotEmpty)
                _campo('Observações', f.observacoes),
            ],
          ),
        );
      },
    ),
  );
}
