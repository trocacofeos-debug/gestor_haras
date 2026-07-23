import 'package:flutter/material.dart';

import '../../models/cavalo_model.dart';
import '../../services/cavalo_service.dart';

import '../cavalos/detalhe_cavalo_page.dart';
import 'editar_cavalo_page.dart';

class AdminCavalosPage extends StatefulWidget {
  const AdminCavalosPage({
    super.key,
  });

  @override
  State<AdminCavalosPage> createState() =>
      _AdminCavalosPageState();
}

class _AdminCavalosPageState
    extends State<AdminCavalosPage> {
  final CavaloService service =
      CavaloService();

  Future<void> excluirCavalo(
    CavaloModel cavalo,
  ) async {
    final confirmar =
        await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            "Excluir Cavalo",
          ),
          content: Text(
            "Deseja excluir ${cavalo.nome}?",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  false,
                );
              },
              child: const Text(
                "Cancelar",
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    Colors.red,
                foregroundColor:
                    Colors.white,
              ),
              onPressed: () {
                Navigator.pop(
                  context,
                  true,
                );
              },
              child: const Text(
                "Excluir",
              ),
            ),
          ],
        );
      },
    );

    if (confirmar != true) {
      return;
    }

    try {
      await service.excluir(
        cavalo.id!,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            "Cavalo excluído com sucesso",
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            "Erro: $e",
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Gerenciar Cavalos",
        ),
      ),

      floatingActionButton:
          FloatingActionButton.extended(
        icon: const Icon(
          Icons.add,
        ),
        label: const Text(
          "Novo Cavalo",
        ),
        onPressed: () {
          Navigator.pushNamed(
            context,
            "/novo-cavalo",
          );
        },
      ),

      body: StreamBuilder<
          List<CavaloModel>>(
        stream: service.listar(),
        builder: (
          context,
          snapshot,
        ) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child:
                  CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                "Erro:\n${snapshot.error}",
              ),
            );
          }

          final cavalos =
              snapshot.data ?? [];

          if (cavalos.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.pets,
                    size: 80,
                    color: Colors.grey,
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Text(
                    "Nenhum cavalo cadastrado",
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding:
                const EdgeInsets.all(16),
            itemCount:
                cavalos.length,
            itemBuilder:
                (context, index) {
              final cavalo =
                  cavalos[index];

              return Card(
                elevation: 4,
                margin:
                    const EdgeInsets.only(
                  bottom: 16,
                ),
                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(
                    20,
                  ),
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.all(
                    12,
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          ClipRRect(
                            borderRadius:
                                BorderRadius
                                    .circular(
                              15,
                            ),
                            child: cavalo
                                    .fotos
                                    .isNotEmpty
                                ? Image.network(
                                    cavalo
                                        .fotos
                                        .first,
                                    width: 90,
                                    height:
                                        90,
                                    fit: BoxFit
                                        .cover,
                                  )
                                : Container(
                                    width:
                                        90,
                                    height:
                                        90,
                                    decoration:
                                        BoxDecoration(
                                      color:
                                          Colors
                                              .grey
                                              .shade200,
                                      borderRadius:
                                          BorderRadius.circular(
                                        15,
                                      ),
                                    ),
                                    child:
                                        const Icon(
                                      Icons
                                          .pets,
                                      size:
                                          45,
                                    ),
                                  ),
                          ),

                          const SizedBox(
                            width: 15,
                          ),

                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment
                                      .start,
                              children: [
                                Text(
                                  cavalo
                                      .nome,
                                  style:
                                      const TextStyle(
                                    fontSize:
                                        18,
                                    fontWeight:
                                        FontWeight.bold,
                                  ),
                                ),

                                                                const SizedBox(
                                  height: 4,
                                ),

                                Text(
                                  cavalo.raca,
                                  style:
                                      TextStyle(
                                    color: Colors
                                        .grey
                                        .shade700,
                                  ),
                                ),

                                const SizedBox(
                                  height: 6,
                                ),

                                Text(
                                  "${cavalo.idade} anos",
                                ),

                                const SizedBox(
                                  height: 6,
                                ),

                                Text(
                                  "R\$ ${cavalo.preco.toStringAsFixed(2)}",
                                  style:
                                      const TextStyle(
                                    color:
                                        Colors.green,
                                    fontSize:
                                        16,
                                    fontWeight:
                                        FontWeight.bold,
                                  ),
                                ),

                                const SizedBox(
                                  height: 8,
                                ),

                                Row(
                                  children: [
                                    if (cavalo
                                        .destaque)
                                      Container(
                                        padding:
                                            const EdgeInsets.symmetric(
                                          horizontal:
                                              8,
                                          vertical:
                                              4,
                                        ),
                                        decoration:
                                            BoxDecoration(
                                          color: Colors
                                              .amber
                                              .shade100,
                                          borderRadius:
                                              BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        child:
                                            const Text(
                                          "DESTAQUE",
                                          style:
                                              TextStyle(
                                            fontSize:
                                                11,
                                            fontWeight:
                                                FontWeight.bold,
                                          ),
                                        ),
                                      ),

                                    if (cavalo
                                        .destaque)
                                      const SizedBox(
                                        width:
                                            8,
                                      ),

                                    Container(
                                      padding:
                                          const EdgeInsets.symmetric(
                                        horizontal:
                                            8,
                                        vertical:
                                            4,
                                      ),
                                      decoration:
                                          BoxDecoration(
                                        color: cavalo
                                                .vendido
                                            ? Colors.red
                                                .shade100
                                            : Colors.green
                                                .shade100,
                                        borderRadius:
                                            BorderRadius.circular(
                                          10,
                                        ),
                                      ),
                                      child: Text(
                                        cavalo
                                                .vendido
                                            ? "VENDIDO"
                                            : "DISPONÍVEL",
                                        style:
                                            const TextStyle(
                                          fontSize:
                                              11,
                                          fontWeight:
                                              FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(
                        height: 15,
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
                                "Visualizar",
                              ),
                              onPressed:
                                  () {
                                Navigator
                                    .push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (_) =>
                                            DetalheCavaloPage(
                                      cavalo:
                                          cavalo,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),

                          const SizedBox(
                            width: 10,
                          ),

                          Expanded(
                            child:
                                ElevatedButton.icon(
                              icon:
                                  const Icon(
                                Icons.edit,
                              ),
                              label:
                                  const Text(
                                "Editar",
                              ),
                              onPressed:
                                  () {
                                Navigator
                                    .push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (_) =>
                                            EditarCavaloPage(
                                      cavalo:
                                          cavalo,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),

                          const SizedBox(
                            width: 10,
                          ),

                          Expanded(
                            child:
                                FilledButton.icon(
                              style:
                                  FilledButton.styleFrom(
                                backgroundColor:
                                    Colors.red,
                              ),
                              icon:
                                  const Icon(
                                Icons.delete,
                              ),
                              label:
                                  const Text(
                                "Excluir",
                              ),
                              onPressed:
                                  () {
                                excluirCavalo(
                                  cavalo,
                                );
                              },
                            ),
                          ),
                        ],
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