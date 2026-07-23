import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../models/cliente_model.dart';

class NovaPropostaPage extends StatefulWidget {
  const NovaPropostaPage({super.key});

  @override
  State<NovaPropostaPage> createState() =>
      _NovaPropostaPageState();
}

class _NovaPropostaPageState
    extends State<NovaPropostaPage> {
  final _formKey =
      GlobalKey<FormState>();

  final descricaoController =
      TextEditingController();

  final valorController =
      TextEditingController();

  final parcelasController =
      TextEditingController(
    text: '1',
  );

  bool salvando = false;

  String? clienteId;
  String? clienteNome;

  @override
  void dispose() {
    descricaoController.dispose();
    valorController.dispose();
    parcelasController.dispose();
    super.dispose();
  }

  double get valorTotal =>
      double.tryParse(
        valorController.text
            .replaceAll(',', '.'),
      ) ??
      0;

  Future<void> selecionarCliente() async {
    final resultado =
        await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) =>
          const SelecionarClienteDialog(),
    );

    if (resultado != null) {
      setState(() {
        clienteId = resultado['id'] as String?;
        clienteNome =
            resultado['nome'] as String?;
      });
    }
  }

  Future<void> salvar() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (clienteId == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content:
              Text('Selecione um cliente'),
        ),
      );
      return;
    }

    setState(() {
      salvando = true;
    });

    try {
      final parcelas =
          int.tryParse(
                parcelasController.text,
              ) ??
              1;

      final valorParcela =
          valorTotal / parcelas;

      await FirebaseFirestore.instance
          .collection('propostas')
          .add({
        'clienteId': clienteId,
        'clienteNome': clienteNome,
        'descricao':
            descricaoController.text.trim(),
        'valorTotal': valorTotal,
        'parcelas': parcelas,
        'valorParcela': valorParcela,
        'status':
            'aguardando_documentos',
        'contratoLiberado': false,
        'contratoGerado': false,
        'contratoAssinado': false,
        'rgUrl': null,
        'comprovanteUrl': null,
        'selfieDocumentoUrl': null,
        'contratoUrl': null,
        'assinaturaUrl': null,
        'dataCriacao': Timestamp.now(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Proposta criada com sucesso',
          ),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text('Erro: $e'),
        ),
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
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding:
          const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: (value) {
          if (value == null ||
              value.trim().isEmpty) {
            return 'Campo obrigatório';
          }
          return null;
        },
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget clienteSelector() {
    return InkWell(
      onTap: selecionarCliente,
      borderRadius:
          BorderRadius.circular(16),
      child: Container(
        padding:
            const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 18,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
              BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            const Icon(Icons.person),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                clienteNome ??
                    'Selecionar Cliente',
                style: TextStyle(
                  color:
                      clienteNome == null
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xffF4F6FA),
      appBar: AppBar(
        title:
            const Text('Nova Proposta'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding:
              const EdgeInsets.all(20),
          children: [
            Container(
              padding:
                  const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient:
                    const LinearGradient(
                  colors: [
                    Color(0xff1565C0),
                    Color(0xff42A5F5),
                  ],
                ),
                borderRadius:
                    BorderRadius.circular(
                  24,
                ),
              ),
              child: const Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    'Criar Proposta',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Defina valores e envie ao cliente.',
                    style: TextStyle(
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            clienteSelector(),

            const SizedBox(height: 20),

            campo(
              label: 'Descrição',
              icon: Icons.description_outlined,
              controller:
                  descricaoController,
            ),

            campo(
              label: 'Valor Total',
              icon: Icons.attach_money,
              controller:
                  valorController,
              keyboardType:
                  TextInputType.number,
            ),

            campo(
              label:
                  'Quantidade de Parcelas',
              icon:
                  Icons.calendar_month,
              controller:
                  parcelasController,
              keyboardType:
                  TextInputType.number,
            ),

            const SizedBox(height: 30),            SizedBox(
              height: 55,
              child: ElevatedButton.icon(
                style:
                    ElevatedButton.styleFrom(
                  backgroundColor:
                      const Color(
                    0xff1565C0,
                  ),
                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(
                      16,
                    ),
                  ),
                ),
                onPressed:
                    salvando
                        ? null
                        : salvar,
                icon:
                    salvando
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child:
                                CircularProgressIndicator(
                              color:
                                  Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(
                            Icons.send,
                            color:
                                Colors.white,
                          ),
                label: Text(
                  salvando
                      ? 'SALVANDO...'
                      : 'CRIAR PROPOSTA',
                  style:
                      const TextStyle(
                    color:
                        Colors.white,
                    fontWeight:
                        FontWeight.bold,
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

class SelecionarClienteDialog
    extends StatefulWidget {
  const SelecionarClienteDialog({
    super.key,
  });

  @override
  State<SelecionarClienteDialog>
      createState() =>
          _SelecionarClienteDialogState();
}

class _SelecionarClienteDialogState
    extends State<
        SelecionarClienteDialog> {
  String busca = '';

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        height: 550,
        padding:
            const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              decoration:
                  const InputDecoration(
                hintText:
                    'Buscar cliente...',
                prefixIcon:
                    Icon(Icons.search),
              ),
              onChanged: (value) {
                setState(() {
                  busca =
                      value.toLowerCase();
                });
              },
            ),

            const SizedBox(height: 12),

            Expanded(
              child:
                  StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore
                    .instance
                    .collection(
                      'clientes',
                    )
                    .orderBy('nome')
                    .snapshots(),
                builder:
                    (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(
                      child:
                          CircularProgressIndicator(),
                    );
                  }

                  final docs =
                      snapshot.data!.docs
                          .where((doc) {
                    final cliente =
                        ClienteModel.fromMap(
                      doc.data()
                          as Map<String,
                              dynamic>,
                      doc.id,
                    );

                    return cliente
                        .nomeExibicao
                        .toLowerCase()
                        .contains(
                          busca,
                        );
                  }).toList();

                  if (docs.isEmpty) {
                    return const Center(
                      child: Text(
                        'Nenhum cliente encontrado',
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount:
                        docs.length,
                    itemBuilder:
                        (context, index) {
                      final cliente =
                          ClienteModel.fromMap(
                        docs[index].data()
                            as Map<String,
                                dynamic>,
                        docs[index].id,
                      );

                      return Card(
                        margin:
                            const EdgeInsets.only(
                          bottom: 8,
                        ),
                        child: ListTile(
                          leading:
                              const CircleAvatar(
                            child: Icon(
                              Icons.person,
                            ),
                          ),
                          title: Text(
                            cliente
                                .nomeExibicao,
                          ),
                          trailing:
                              const Icon(
                            Icons
                                .arrow_forward_ios,
                            size: 16,
                          ),
                          onTap: () {
                            Navigator.pop(
                              context,
                              {
                                'id':
                                    cliente.id,
                                'nome':
                                    cliente
                                        .nomeExibicao,
                              },
                            );
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