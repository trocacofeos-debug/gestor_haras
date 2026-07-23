import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../pagamentos/pix_payment_page.dart';

class ClienteDividasPage extends StatefulWidget {
  const ClienteDividasPage({super.key});

  @override
  State<ClienteDividasPage> createState() =>
      _ClienteDividasPageState();
}

class _ClienteDividasPageState
    extends State<ClienteDividasPage> {
  String? dividaAberta;

  String get uid =>
      FirebaseAuth.instance.currentUser?.uid ?? '';

  Stream<QuerySnapshot<Map<String, dynamic>>>
      minhasDividas() {
    return FirebaseFirestore.instance
        .collection("dividas")
        .where(
          "clienteId",
          isEqualTo: uid,
        )
        .where(
          "status",
          isEqualTo: "aberta",
        )
        .snapshots();
  }

  double valor(dynamic v) {
    if (v is num) {
      return v.toDouble();
    }

    return double.tryParse(
          v.toString(),
        ) ??
        0;
  }

  String formatarData(dynamic v) {
    if (v is Timestamp) {
      return DateFormat(
        "dd/MM/yyyy",
      ).format(
        v.toDate(),
      );
    }

    return "-";
  }

  void abrirPix({
    required double valor,
    required String descricao,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PixPaymentPage(
          valor: valor,
          descricao: descricao,
        ),
      ),
    );
  }

  Widget listaParcelas({
  required String dividaId,
  required String descricao,
}) {
  return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
    stream: FirebaseFirestore.instance
        .collection("dividas")
        .doc(dividaId)
        .collection("parcelas")
        .orderBy("vencimento")
        .snapshots(),
    builder: (context, snapshot) {
      if (snapshot.connectionState ==
          ConnectionState.waiting) {
        return const Padding(
          padding: EdgeInsets.all(20),
          child: Center(
            child: CircularProgressIndicator(),
          ),
        );
      }

      if (snapshot.hasError) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            snapshot.error.toString(),
          ),
        );
      }

      final parcelas = snapshot.data?.docs ?? [];

      if (parcelas.isEmpty) {
        return const Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            "Nenhuma parcela encontrada",
          ),
        );
      }

      return Column(
        children: parcelas.map((p) {
          final item = p.data();

          final status = item["status"]
                  ?.toString()
                  .trim()
                  .toLowerCase() ??
              "";

          final pago = status == "pago";

          final valorParcela =
              valor(item["valor"]);

          return Container(
            margin: const EdgeInsets.only(
              top: 12,
            ),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: pago
                  ? Colors.green.shade50
                  : Colors.orange.shade50,
              borderRadius:
                  BorderRadius.circular(14),
              border: Border.all(
                color: pago
                    ? Colors.green.shade200
                    : Colors.orange.shade200,
              ),
            ),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      pago
                          ? Icons.check_circle
                          : Icons.schedule,
                      color: pago
                          ? Colors.green
                          : Colors.orange,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            "R\$ ${valorParcela.toStringAsFixed(2)}",
                            style:
                                const TextStyle(
                              fontSize: 16,
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),
                          Text(
                            "Vencimento: ${formatarData(item["vencimento"])}",
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                if (pago)
                  Container(
                    width: double.infinity,
                    padding:
                        const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius:
                          BorderRadius.circular(10),
                    ),
                    child: const Text(
                      "PARCELA PAGA",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                  )
                else
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child:
                        ElevatedButton.icon(
                      icon: const Icon(
                        Icons.qr_code,
                      ),
                      label: Text(
                        "PAGAR R\$ ${valorParcela.toStringAsFixed(2)}",
                      ),
                      style:
                          ElevatedButton.styleFrom(
                        backgroundColor:
                            Colors.green,
                        foregroundColor:
                            Colors.white,
                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(
                            10,
                          ),
                        ),
                      ),
                      onPressed: () {
                        abrirPix(
                          valor: valorParcela,
                          descricao: descricao,
                        );
                      },
                    ),
                  ),
              ],
            ),
          );
        }).toList(),
      );
    },
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xffF4F6FA),
      appBar: AppBar(
        title: const Text(
          "Minhas Dívidas",
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<
          QuerySnapshot<Map<String, dynamic>>>(
        stream: minhasDividas(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child:
                  CircularProgressIndicator(),
            );
          }

          final docs =
              snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(
              child: Text(
                "Nenhuma dívida pendente",
              ),
            );
          }

          return ListView.builder(
            padding:
                const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder:
                (context, index) {
              final doc =
                  docs[index];

              final divida =
                  doc.data();

              return Card(
                margin:
                    const EdgeInsets.only(
                  bottom: 16,
                ),
                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(
                    18,
                  ),
                ),
                child: ExpansionTile(
                  leading:
                      const CircleAvatar(
                    backgroundColor:
                        Colors.orange,
                    child: Icon(
                      Icons.receipt_long,
                      color:
                          Colors.white,
                    ),
                  ),
                  title: Text(
                    divida["descricao"] ??
                        "Dívida",
                  ),
                  subtitle: Text(
                    "R\$ ${valor(divida["valorTotal"]).toStringAsFixed(2)}",
                    style:
                        const TextStyle(
                      color: Colors.red,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                  children: [
                    Padding(
                      padding:
                          const EdgeInsets
                              .all(16),
                      child:
                          listaParcelas(
                        dividaId:
                            doc.id,
                        descricao:
                            divida[
                                    "descricao"] ??
                                "Dívida",
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}