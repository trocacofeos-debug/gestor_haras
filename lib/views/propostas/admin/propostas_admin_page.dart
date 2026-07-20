import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'nova_proposta_page.dart';
import 'detalhes_proposta_page.dart';
import 'aprovar_proposta_page.dart';

class PropostasAdminPage extends StatefulWidget {
  const PropostasAdminPage({
    super.key,
  });

  @override
  State<PropostasAdminPage> createState() =>
      _PropostasAdminPageState();
}

class _PropostasAdminPageState
    extends State<PropostasAdminPage> {
  final FirebaseFirestore db =
      FirebaseFirestore.instance;

  Stream<QuerySnapshot<Map<String, dynamic>>>
      propostas() {
    return db
        .collection("propostas")
        .orderBy(
          "dataCriacao",
          descending: true,
        )
        .snapshots();
  }

  Future<void> liberarContrato(
    String id,
  ) async {
    await db
        .collection("propostas")
        .doc(id)
        .update({
      "status": "aguardando_assinatura",
      "contratoLiberado": true,
      "dataLiberacao": Timestamp.now(),
    });

    if (!mounted) return;

    ScaffoldMessenger.of(context)
        .showSnackBar(
      const SnackBar(
        content: Text(
          "Contrato liberado com sucesso",
        ),
      ),
    );
  }

  Color statusColor(String status) {
    switch (status) {
      case "aguardando_documentos":
        return Colors.grey;

      case "documentos_enviados":
        return Colors.blue;

      case "em_analise":
        return Colors.orange;

      case "aprovada":
        return Colors.green;

      case "aguardando_assinatura":
        return Colors.deepPurple;

      case "contrato_assinado":
        return Colors.teal;

      case "reprovada":
        return Colors.red;

      default:
        return Colors.grey;
    }
  }

  String statusTexto(String status) {
    switch (status) {
      case "aguardando_documentos":
        return "Aguardando documentos";

      case "documentos_enviados":
        return "Documentos enviados";

      case "em_analise":
        return "Em análise";

      case "aprovada":
        return "Aprovada";

      case "aguardando_assinatura":
        return "Aguardando assinatura";

      case "contrato_assinado":
        return "Contrato assinado";

      case "reprovada":
        return "Reprovada";

      default:
        return status;
    }
  }

  String formatarData(
    Timestamp? timestamp,
  ) {
    if (timestamp == null) {
      return "-";
    }

    final data =
        timestamp.toDate();

    return
        "${data.day.toString().padLeft(2, '0')}/"
        "${data.month.toString().padLeft(2, '0')}/"
        "${data.year}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xffF4F6FA),

      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "Propostas",
        ),
      ),

      floatingActionButton:
          FloatingActionButton.extended(
        backgroundColor:
            const Color(0xff1565C0),

        icon: const Icon(
          Icons.add,
          color: Colors.white,
        ),

        label: const Text(
          "Nova Proposta",
          style: TextStyle(
            color: Colors.white,
            fontWeight:
                FontWeight.bold,
          ),
        ),

        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  const NovaPropostaPage(),
            ),
          );
        },
      ),

      body: StreamBuilder<
          QuerySnapshot<
              Map<String, dynamic>>>(
        stream: propostas(),
        builder: (
          context,
          snapshot,
        ) {
          if (snapshot
                  .connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child:
                  CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                snapshot.error
                    .toString(),
              ),
            );
          }

          final docs =
              snapshot.data?.docs ??
                  [];

          if (docs.isEmpty) {
            return const Center(
              child: Text(
                "Nenhuma proposta encontrada",
              ),
            );
          }

          return ListView.builder(
            padding:
                const EdgeInsets.all(
              16,
            ),
            itemCount:
                docs.length,
            itemBuilder:
                (context, index) {
              final doc =
                  docs[index];

              final data =
                  doc.data();

              final nome =
                  data["clienteNome"] ??
                      "Cliente";

              final status =
                  data["status"] ??
                      "aguardando_documentos";

              final valor =
                  (data["valorTotal"] ??
                          0)
                      .toDouble();

              final parcelas =
                  data["parcelas"] ??
                      1;

              final criadoEm =
                  data["dataCriacao"]
                      as Timestamp?;

              return Container(
                margin:
                    const EdgeInsets.only(
                  bottom: 16,
                ),
                decoration:
                    BoxDecoration(
                  color:
                      Colors.white,
                  borderRadius:
                      BorderRadius
                          .circular(
                    22,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color:
                          Colors.black12,
                      blurRadius:
                          8,
                      offset:
                          const Offset(
                        0,
                        4,
                      ),
                    ),
                  ],
                ),
                child: Padding(
                  padding:
                      const EdgeInsets
                          .all(
                    18,
                  ),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment
                            .start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor:
                                Colors.blue
                                    .shade100,
                            child:
                                const Icon(
                              Icons
                                  .person,
                              color:
                                  Colors
                                      .blue,
                            ),
                          ),
                          const SizedBox(
                            width: 12,
                          ),
                          Expanded(
                            child: Text(
                              nome,
                              style:
                                  const TextStyle(
                                fontSize:
                                    18,
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(
                        height: 18,
                      ),

                      Container(
                        padding:
                            const EdgeInsets
                                .symmetric(
                          horizontal:
                              12,
                          vertical:
                              8,
                        ),
                        decoration:
                            BoxDecoration(
                          color:
                              statusColor(
                            status,
                          // ignore: deprecated_member_use
                          ).withOpacity(
                            0.15,
                          ),
                          borderRadius:
                              BorderRadius.circular(
                            30,
                          ),
                        ),
                        child: Text(
                          statusTexto(
                            status,
                          ),
                          style:
                              TextStyle(
                            color:
                                statusColor(
                              status,
                            ),
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                      ),

                      const SizedBox(
                        height: 18,
                      ),

                      Text(
                        "Valor da proposta",
                        style:
                            TextStyle(
                          color: Colors
                              .grey
                              .shade600,
                        ),
                      ),

                      const SizedBox(
                        height: 4,
                      ),

                      Text(
                        "R\$ ${valor.toStringAsFixed(2)}",
                        style:
                            const TextStyle(
                          fontSize:
                              24,
                          fontWeight:
                              FontWeight.bold,
                          color:
                              Colors.green,
                        ),
                      ),

                      const SizedBox(
                        height: 8,
                      ),

                      Text(
                        "$parcelas parcela(s)",
                        style:
                            const TextStyle(
                          fontWeight:
                              FontWeight.w500,
                        ),
                      ),

                      const SizedBox(
                        height: 4,
                      ),

                      Text(
                        "Criada em ${formatarData(criadoEm)}",
                        style:
                            TextStyle(
                          color: Colors
                              .grey
                              .shade600,
                        ),
                      ),

                      const SizedBox(
                        height: 20,
                      ),

                      Row(
                        children: [
                          Expanded(
                            child:
                                OutlinedButton.icon(
                              icon:
                                  const Icon(
                                Icons
                                    .visibility,
                              ),
                              label:
                                  const Text(
                                "Detalhes",
                              ),
                              onPressed:
                                  () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (_) =>
                                            DetalhesPropostaPage(
                                      propostaId:
                                          doc.id,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),

                          const SizedBox(
                            width: 10,
                          ),

                          if (status ==
                                  "documentos_enviados" ||
                              status ==
                                  "em_analise")
                            Expanded(
                              child:
                                  ElevatedButton.icon(
                                icon:
                                    const Icon(
                                  Icons
                                      .fact_check,
                                ),
                                label:
                                    const Text(
                                  "Analisar",
                                ),
                                onPressed:
                                    () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (_) =>
                                              AprovarPropostaPage(
                                        propostaId:
                                            doc.id,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                        ],
                      ),

                      if (status ==
                          "aprovada")
                        Padding(
                          padding:
                              const EdgeInsets.only(
                            top: 12,
                          ),
                          child:
                              SizedBox(
                            width:
                                double
                                    .infinity,
                            child:
                                ElevatedButton.icon(
                              style:
                                  ElevatedButton.styleFrom(
                                backgroundColor:
                                    Colors.deepPurple,
                              ),
                              icon:
                                  const Icon(
                                Icons
                                    .description,
                                color:
                                    Colors.white,
                              ),
                              label:
                                  const Text(
                                "LIBERAR CONTRATO",
                                style:
                                    TextStyle(
                                  color:
                                      Colors.white,
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),
                              onPressed:
                                  () {
                                liberarContrato(
                                  doc.id,
                                );
                              },
                            ),
                          ),
                        ),
                    ],
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