// ignore_for_file: deprecated_member_use

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../models/cavalo_model.dart';
import '../../models/cliente_model.dart';

class CadastroCavaloPage extends StatefulWidget {
  final CavaloModel? cavaloParaEditar;

  const CadastroCavaloPage({super.key, this.cavaloParaEditar});

  @override
  State<CadastroCavaloPage> createState() => _CadastroCavaloPageState();
}

class _CadastroCavaloPageState extends State<CadastroCavaloPage> {
  final _formKey = GlobalKey<FormState>();

  final nomeController = TextEditingController();
  final racaController = TextEditingController();
  final pelagemController = TextEditingController();
  final observacoesController = TextEditingController();

  String sexo = 'Macho';

  String? proprietarioId;
  String? proprietarioNome;

  bool salvando = false;

  bool get editando => widget.cavaloParaEditar != null;

  static const Color primaria = Color(0xFF4F46E5);
  static const Color fundo = Color(0xFFF3F4F6);

  @override
  void initState() {
    super.initState();

    final c = widget.cavaloParaEditar;

    if (c != null) {
      nomeController.text = c.nome;
      racaController.text = c.raca;
      pelagemController.text = c.pelagem;
      observacoesController.text = c.observacoes;
      sexo = c.sexo.isEmpty ? 'Macho' : c.sexo;
      proprietarioId = c.proprietarioId.isEmpty ? null : c.proprietarioId;
      proprietarioNome =
          c.proprietarioNome.isEmpty ? null : c.proprietarioNome;
    }
  }

  @override
  void dispose() {
    nomeController.dispose();
    racaController.dispose();
    pelagemController.dispose();
    observacoesController.dispose();
    super.dispose();
  }

  Future<void> selecionarProprietario() async {
    final resultado = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => const _SelecionarClienteDialog(),
    );

    if (resultado != null) {
      setState(() {
        proprietarioId = resultado['id'] as String?;
        proprietarioNome = resultado['nome'] as String?;
      });
    }
  }

  Future<void> salvar() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      salvando = true;
    });

    try {
      final cavalo = CavaloModel(
        id: widget.cavaloParaEditar?.id ?? '',
        nome: nomeController.text.trim(),
        raca: racaController.text.trim(),
        sexo: sexo,
        pelagem: pelagemController.text.trim(),
        proprietarioId: proprietarioId ?? '',
        proprietarioNome: proprietarioNome ?? '',
        preco: widget.cavaloParaEditar?.preco ?? 0,
        fotos: widget.cavaloParaEditar?.fotos ?? const [],
        observacoes: observacoesController.text.trim(),
        dataCadastro:
            widget.cavaloParaEditar?.dataCadastro ?? Timestamp.now(),
      );

      if (editando) {
        await FirebaseFirestore.instance
            .collection('cavalos')
            .doc(cavalo.id)
            .update(cavalo.toMap());
      } else {
        await FirebaseFirestore.instance
            .collection('cavalos')
            .add(cavalo.toMap());
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            editando
                ? 'Cavalo atualizado com sucesso'
                : 'Cavalo cadastrado com sucesso',
          ),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          salvando = false;
        });
      }
    }
  }

  Widget campo({
    required String label,
    required IconData icon,
    required TextEditingController controller,
    bool required = true,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        validator: required
            ? (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Campo obrigatório';
                }
                return null;
              }
            : null,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: primaria),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: fundo,
      appBar: AppBar(
        backgroundColor: primaria,
        foregroundColor: Colors.white,
        title: Text(editando ? 'Editar Cavalo' : 'Cadastro de Cavalo'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF4F46E5), Color(0xFF7C7AF0)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    editando ? 'Editar Cavalo' : 'Novo Cavalo',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    editando
                        ? 'Atualize os dados do animal.'
                        : 'Cadastre os dados do animal.',
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            InkWell(
              onTap: selecionarProprietario,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 18,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.person, color: primaria),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        proprietarioNome ??
                            'Selecionar Proprietário (opcional)',
                        style: TextStyle(
                          color: proprietarioNome == null
                              ? Colors.grey
                              : Colors.black,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const Icon(Icons.search),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            campo(
              label: 'Nome do Cavalo',
              icon: Icons.pets_outlined,
              controller: nomeController,
            ),

            campo(
              label: 'Raça',
              icon: Icons.category_outlined,
              controller: racaController,
              required: false,
            ),

            campo(
              label: 'Pelagem',
              icon: Icons.palette_outlined,
              controller: pelagemController,
              required: false,
            ),

            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: DropdownButtonFormField<String>(
                  value: sexo,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    prefixIcon: Icon(Icons.male, color: primaria),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'Macho', child: Text('Macho')),
                    DropdownMenuItem(value: 'Fêmea', child: Text('Fêmea')),
                  ],
                  onChanged: (v) {
                    setState(() {
                      sexo = v ?? 'Macho';
                    });
                  },
                ),
              ),
            ),

            campo(
              label: 'Observações',
              icon: Icons.notes_outlined,
              controller: observacoesController,
              required: false,
            ),

            const SizedBox(height: 20),

            SizedBox(
              height: 55,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaria,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: salvando ? null : salvar,
                icon: salvando
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.save, color: Colors.white),
                label: Text(
                  salvando
                      ? 'SALVANDO...'
                      : (editando ? 'SALVAR ALTERAÇÕES' : 'CADASTRAR CAVALO'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =====================================================
// SELECIONAR CLIENTE (proprietário)
// =====================================================

class _SelecionarClienteDialog extends StatefulWidget {
  const _SelecionarClienteDialog();

  @override
  State<_SelecionarClienteDialog> createState() =>
      _SelecionarClienteDialogState();
}

class _SelecionarClienteDialogState extends State<_SelecionarClienteDialog> {
  String busca = '';

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        height: 550,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              decoration: const InputDecoration(
                hintText: 'Buscar cliente...',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                setState(() {
                  busca = value.toLowerCase();
                });
              },
            ),
            const SizedBox(height: 12),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('clientes')
                    .orderBy('nome')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final docs = snapshot.data!.docs.where((doc) {
                    final cliente = ClienteModel.fromMap(
                      doc.data() as Map<String, dynamic>,
                      doc.id,
                    );

                    return cliente.nomeExibicao.toLowerCase().contains(busca);
                  }).toList();

                  if (docs.isEmpty) {
                    return const Center(
                      child: Text('Nenhum cliente encontrado'),
                    );
                  }

                  return ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final cliente = ClienteModel.fromMap(
                        docs[index].data() as Map<String, dynamic>,
                        docs[index].id,
                      );

                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: const CircleAvatar(
                            child: Icon(Icons.person),
                          ),
                          title: Text(cliente.nomeExibicao),
                          trailing: const Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                          ),
                          onTap: () {
                            Navigator.pop(context, {
                              'id': cliente.id,
                              'nome': cliente.nomeExibicao,
                            });
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}