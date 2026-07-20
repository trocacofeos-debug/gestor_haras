import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PerfilClientePage extends StatefulWidget {
  const PerfilClientePage({super.key});

  @override
  State<PerfilClientePage> createState() =>
      _PerfilClientePageState();
}

class _PerfilClientePageState
    extends State<PerfilClientePage> {
  final uid =
      FirebaseAuth.instance.currentUser?.uid ?? '';

  Future<DocumentSnapshot<Map<String, dynamic>>>
      carregarCliente() {
    return FirebaseFirestore.instance
        .collection('clientes')
        .doc(uid)
        .get();
  }

  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();

    if (!mounted) return;

    Navigator.popUntil(context, (route) => route.isFirst);
  }

  Widget infoTile(
    String titulo,
    String valor,
    IconData icon,
  ) {
    return Card(
      elevation: 1,
      child: ListTile(
        leading: Icon(icon),
        title: Text(titulo),
        subtitle: Text(valor),
      ),
    );
  }

  Widget documentoTile(
    String titulo,
    String? url,
  ) {
    return Card(
      child: ListTile(
        leading: const Icon(
          Icons.description,
          color: Colors.indigo,
        ),
        title: Text(titulo),
        subtitle: Text(
          url == null || url.isEmpty
              ? 'Documento não enviado'
              : 'Documento enviado',
        ),
        trailing: Icon(
          url == null || url.isEmpty
              ? Icons.close
              : Icons.check_circle,
          color: url == null || url.isEmpty
              ? Colors.red
              : Colors.green,
        ),
      ),
    );
  }

  Color statusColor(String status) {
    switch (status) {
      case 'aprovado':
        return Colors.green;

      case 'rejeitado':
        return Colors.red;

      case 'aguardando_assinatura':
        return Colors.orange;

      default:
        return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(
        0xFFF4F6FA,
      ),
      appBar: AppBar(
        title: const Text('Meu Perfil'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: logout,
            icon: const Icon(Icons.logout),
          )
        ],
      ),
      body: FutureBuilder<
          DocumentSnapshot<
              Map<String, dynamic>>>(
        future: carregarCliente(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child:
                  CircularProgressIndicator(),
            );
          }

          final data =
              snapshot.data!.data() ?? {};

          final nome =
              data['nome'] ?? '';

          final email =
              data['email'] ?? '';

          final telefone =
              data['telefone'] ?? '';

          final cpf =
              data['cpf'] ?? '';

          final endereco =
              data['endereco'] ?? '';

          final statusProposta =
              data['statusProposta'] ??
                  'pendente';

          final rgUrl =
              data['rgUrl'];

          final comprovanteUrl =
              data['comprovanteUrl'];

          final selfieUrl =
              data['selfieUrl'];

          return SingleChildScrollView(
            padding:
                const EdgeInsets.all(16),
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 45,
                  backgroundColor:
                      Colors.indigo,
                  child: Icon(
                    Icons.person,
                    size: 50,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 15),

                Text(
                  nome,
                  style:
                      const TextStyle(
                    fontSize: 22,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 20),

                infoTile(
                  'E-mail',
                  email,
                  Icons.email,
                ),

                infoTile(
                  'Telefone',
                  telefone,
                  Icons.phone,
                ),

                infoTile(
                  'CPF',
                  cpf,
                  Icons.badge,
                ),

                infoTile(
                  'Endereço',
                  endereco,
                  Icons.home,
                ),

                const SizedBox(height: 20),

                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.all(
                    16,
                  ),
                  decoration:
                      BoxDecoration(
                    color: statusColor(
                      statusProposta,
                    ).withValues(alpha: 0.12),
                    borderRadius:
                        BorderRadius.circular(
                      12,
                    ),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Status da Proposta',
                        style: TextStyle(
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      Text(
                        statusProposta
                            .toUpperCase(),
                        style: TextStyle(
                          color: statusColor(
                            statusProposta,
                          ),
                          fontWeight:
                              FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 25),

                const Align(
                  alignment:
                      Alignment.centerLeft,
                  child: Text(
                    'Documentos',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                documentoTile(
                  'RG ou CNH',
                  rgUrl,
                ),

                documentoTile(
                  'Comprovante de Residência',
                  comprovanteUrl,
                ),

                documentoTile(
                  'Selfie com Documento',
                  selfieUrl,
                ),

                const SizedBox(height: 25),

                if (statusProposta ==
                    'aguardando_assinatura')
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(
                        Icons.draw,
                      ),
                      label: const Text(
                        'Assinar Contrato',
                      ),
                      style:
                          ElevatedButton.styleFrom(
                        backgroundColor:
                            Colors.green,
                        foregroundColor:
                            Colors.white,
                        padding:
                            const EdgeInsets.all(
                          16,
                        ),
                      ),
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          '/assinaturaContrato',
                        );
                      },
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}