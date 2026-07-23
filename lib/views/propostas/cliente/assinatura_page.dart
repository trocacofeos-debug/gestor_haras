import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:signature/signature.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AssinaturaPage extends StatefulWidget {
  final String propostaId;

  const AssinaturaPage({
    super.key,
    required this.propostaId,
  });

  @override
  State<AssinaturaPage> createState() =>
      _AssinaturaPageState();
}

class _AssinaturaPageState
    extends State<AssinaturaPage> {
  final SignatureController controller =
      SignatureController(
    penStrokeWidth: 3,
    penColor: Colors.black,
  );

  bool salvando = false;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> salvarAssinatura() async {
    if (controller.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            "Desenhe sua assinatura",
          ),
        ),
      );
      return;
    }

    setState(() {
      salvando = true;
    });

    try {
      final Uint8List? assinatura =
          await controller.toPngBytes();

      if (assinatura == null) {
        throw Exception(
          "Erro ao gerar assinatura",
        );
      }

      // Aqui futuramente envia para Cloudflare R2
      // final url = await CloudflareR2Service()
      //     .uploadBytes(assinatura);

      await FirebaseFirestore.instance
          .collection("propostas")
          .doc(widget.propostaId)
          .update({
        "status": "assinado",
        "dataAssinatura":
            Timestamp.now(),

        // "assinaturaUrl": url
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            "Contrato assinado com sucesso",
          ),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            e.toString(),
          ),
        ),
      );
    }

    if (mounted) {
      setState(() {
        salvando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xffF4F6FA),

      appBar: AppBar(
        title: const Text(
          "Assinatura Digital",
        ),
      ),

      body: Padding(
        padding:
            const EdgeInsets.all(20),

        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.all(16),

              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.circular(
                  20,
                ),
              ),

              child: const Column(
                children: [
                  Icon(
                    Icons.draw,
                    size: 40,
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Assine dentro da área abaixo",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.circular(
                    20,
                  ),
                  border: Border.all(
                    color: Colors.black12,
                  ),
                ),
                child: Signature(
                  controller: controller,
                  backgroundColor:
                      Colors.white,
                ),
              ),
            ),

            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(
                      Icons.delete,
                    ),
                    label: const Text(
                      "Limpar",
                    ),
                    onPressed: () {
                      controller.clear();
                    },
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(
                      Icons.check,
                      color: Colors.white,
                    ),
                    label: const Text(
                      "Assinar",
                      style: TextStyle(
                        color:
                            Colors.white,
                      ),
                    ),
                    style:
                        ElevatedButton.styleFrom(
                      backgroundColor:
                          Colors.blue,
                      minimumSize:
                          const Size(
                        double.infinity,
                        55,
                      ),
                    ),
                    onPressed: salvando
                        ? null
                        : salvarAssinatura,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}