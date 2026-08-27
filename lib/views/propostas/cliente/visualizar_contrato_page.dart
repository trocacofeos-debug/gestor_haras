// ignore_for_file: deprecated_member_use

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'clicksign_signature_page.dart';

class VisualizarContratoPage extends StatefulWidget {
  final String propostaId;

  const VisualizarContratoPage({
    super.key,
    required this.propostaId,
  });

  @override
  State<VisualizarContratoPage> createState() =>
      _VisualizarContratoPageState();
}

class _VisualizarContratoPageState extends State<VisualizarContratoPage> {
  final FirebaseFirestore db = FirebaseFirestore.instance;

  Future<DocumentSnapshot<Map<String, dynamic>>> carregarProposta() async {
    return await db.collection('propostas').doc(widget.propostaId).get();
  }

  Future<void> abrirContratoPdf(String url) async {
    try {
      final uri = Uri.parse(url);

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        throw Exception('Não foi possível abrir o contrato');
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text('Erro ao abrir contrato: $e'),
        ),
      );
    }
  }

  Future<void> abrirAssinatura() async {
    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ClicksignSignaturePage(
          propostaId: widget.propostaId,
        ),
      ),
    );

    if (resultado == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.green,
          content: Text('Contrato assinado com sucesso.'),
        ),
      );

      setState(() {});
    }
  }

  Widget infoTile({
    required IconData icon,
    required String titulo,
    required String valor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.brown.shade50,
            child: Icon(icon, color: Colors.brown),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
                const SizedBox(height: 5),
                Text(
                  valor,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF4F6FA),
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Contrato Digital'),
      ),
      body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        future: carregarProposta(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Contrato não encontrado'));
          }

          final proposta = snapshot.data!.data()!;

          final clienteNome = proposta['clienteNome'] ?? 'Cliente';
          final status = proposta['status'] ?? 'aguardando_aprovacao';
          final valor = proposta['valorTotal'] ?? proposta['valor'] ?? 0;
          final parcelas = proposta['parcelas'] ?? 1;

          final assinado = status.toString() == 'assinado';

          final contratoPdfUrl = assinado
              ? (proposta['contratoAssinadoUrl'] ??
                  proposta['contratoPdfUrl'] ??
                  '')
              : (proposta['contratoPdfUrl'] ?? '');

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xff5D4037), Color(0xff8D6E63)],
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Column(
                  children: [
                    Icon(Icons.description, color: Colors.white, size: 60),
                    SizedBox(height: 16),
                    Text(
                      'Contrato Digital',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              infoTile(
                icon: Icons.person,
                titulo: 'Cliente',
                valor: clienteNome.toString(),
              ),
              infoTile(
                icon: Icons.attach_money,
                titulo: 'Valor da proposta',
                valor: 'R\$ ${valor.toString()}',
              ),
              infoTile(
                icon: Icons.calendar_month,
                titulo: 'Parcelas',
                valor: '$parcelas parcelas',
              ),
              infoTile(
                icon: Icons.info_outline,
                titulo: 'Status',
                valor: status.toString(),
              ),
              const SizedBox(height: 20),
              if (contratoPdfUrl.toString().isNotEmpty)
                SizedBox(
                  height: 55,
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: () {
                      abrirContratoPdf(contratoPdfUrl.toString());
                    },
                    icon: const Icon(Icons.picture_as_pdf),
                    label: Text(
                      assinado
                          ? 'VISUALIZAR CONTRATO ASSINADO'
                          : 'VISUALIZAR CONTRATO PDF',
                    ),
                  ),
                ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Termo de Contratação',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Declaro que li e concordo com todos os termos deste contrato digital, incluindo valores, parcelamento, obrigações das partes e condições estabelecidas pela empresa.',
                      textAlign: TextAlign.justify,
                    ),
                  ],
                ),
              ),
              if (!assinado)
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: SizedBox(
                    height: 55,
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: abrirAssinatura,
                      icon: const Icon(Icons.draw),
                      label: const Text('ASSINAR CONTRATO'),
                    ),
                  ),
                ),
              if (assinado)
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text('Contrato já assinado com sucesso.'),
                        ),
                      ],
                    ),
                  ),
                ),
              if (contratoPdfUrl.toString().isEmpty && !assinado)
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.orange),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'O PDF do contrato ainda não foi anexado pelo administrador. Você poderá assinar assim que estiver disponível.',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
