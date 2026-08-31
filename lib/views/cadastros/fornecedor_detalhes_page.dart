import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../widgets/app_dialogs.dart';
import '../../models/fornecedor_model.dart';

import '../../widgets/campos_grid.dart';
import '../../widgets/desktop_window.dart';

import 'cadastro_fornecedor_page.dart';

Future<void> abrirPopupDetalhesFornecedor(BuildContext context, String id) =>
    showAppDialog<void>(
      context: context,
      title: 'Detalhes do fornecedor',
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
              child: FornecedorDetalhesPage(fornecedorId: id),
            ),
          ),
        ),
      ),
    );

class FornecedorDetalhesPage extends StatelessWidget {
  final String fornecedorId;
  const FornecedorDetalhesPage({super.key, required this.fornecedorId});
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
        'Detalhes do fornecedor',
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
          .collection('fornecedores')
          .doc(fornecedorId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(
            child: Text('Não foi possível carregar o fornecedor.'),
          );
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.data!.exists) {
          return const Center(child: Text('Fornecedor não encontrado.'));
        }
        final f = FornecedorModel.fromMap(snapshot.data!.data()!, fornecedorId);

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    width: 64,
                    height: 64,
                    child: Icon(
                      Icons.storefront_outlined,
                      size: 40,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          f.nome.isEmpty ? 'Fornecedor sem nome' : f.nome,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          f.categoria,
                          style: const TextStyle(color: Color(0xFF6B7280)),
                        ),
                        const SizedBox(height: 6),
                        Text(f.ativo ? 'Ativo' : 'Inativo'),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Editar fornecedor',
                    icon: const Icon(
                      Icons.edit_outlined,
                      color: Color(0xFF4F46E5),
                    ),
                    onPressed: () => openDesktopWindow(
                      context,
                      title: 'Editar fornecedor',
                      builder: (_) =>
                          CadastroFornecedorPage(fornecedorParaEditar: f),
                    ),
                  ),
                ],
              ),
              _grupo('Dados do fornecedor', [
                _campo('Nome / Razão Social', f.nome),
                _campo('CPF / CNPJ', f.cpfCnpj),
                _campo('Categoria', f.categoria),
                _campo('Status', f.ativo ? 'Ativo' : 'Inativo'),
              ]),
              _grupo('Contato e endereço', [
                _campo('Telefone', f.telefone),
                _campo('Email', f.email),
                _campo('Endereço', f.endereco),
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


