import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../services/asaas_service.dart';

class AsaasPaymentPage extends StatefulWidget {
  final String dividaId;
  final String parcelaId;
  final String descricao;
  final double valor;

  /// "PIX" ou "BOLETO"
  final String tipo;

  const AsaasPaymentPage({
    super.key,
    required this.dividaId,
    required this.parcelaId,
    required this.descricao,
    required this.valor,
    required this.tipo,
  });

  @override
  State<AsaasPaymentPage> createState() => _AsaasPaymentPageState();
}

class _AsaasPaymentPageState extends State<AsaasPaymentPage> {
  final AsaasService _service = AsaasService();

  Future<AsaasCobranca>? _futureCobranca;

  @override
  void initState() {
    super.initState();

    _futureCobranca = _service.gerarCobranca(
      dividaId: widget.dividaId,
      parcelaId: widget.parcelaId,
      tipo: widget.tipo,
    );
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> _statusParcela() {
    return FirebaseFirestore.instance
        .collection("dividas")
        .doc(widget.dividaId)
        .collection("parcelas")
        .doc(widget.parcelaId)
        .snapshots();
  }

  Future<void> _copiar(String texto, String mensagem) async {
    await Clipboard.setData(ClipboardData(text: texto));

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensagem)),
    );
  }

  Future<void> _abrirLink(String url) async {
    final uri = Uri.parse(url);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Não foi possível abrir o link")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final corPrincipal =
        widget.tipo == "PIX" ? Colors.green : Colors.orange;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: AppBar(
        title: Text(
          widget.tipo == "PIX" ? "Pagamento PIX" : "Pagamento Boleto",
        ),
        backgroundColor: corPrincipal,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: _statusParcela(),
        builder: (context, statusSnapshot) {
          final pago =
              statusSnapshot.data?.data()?["status"] == "pago";

          if (pago) {
            return _telaPago();
          }

          return FutureBuilder<AsaasCobranca>(
            future: _futureCobranca,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (snapshot.hasError) {
                return _telaErro(snapshot.error.toString());
              }

              final cobranca = snapshot.data!;

              return cobranca.tipo == "PIX"
                  ? _telaPix(cobranca)
                  : _telaBoleto(cobranca);
            },
          );
        },
      ),
    );
  }

  Widget _telaErro(String erro) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 60),
            const SizedBox(height: 16),
            Text(
              erro,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Voltar"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _telaPago() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 90,
            ),
            const SizedBox(height: 20),
            const Text(
              "Pagamento confirmado!",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "R\$ ${widget.valor.toStringAsFixed(2)}",
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text("Voltar"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _cabecalho() {
    return Column(
      children: [
        Text(
          widget.descricao,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Valor da parcela',
          style: TextStyle(color: Colors.grey.shade700),
        ),
        const SizedBox(height: 6),
        Text(
          'R\$ ${widget.valor.toStringAsFixed(2)}',
          style: const TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
        const SizedBox(height: 20),
        const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 10),
            Text(
              "Aguardando confirmação automática do pagamento...",
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ],
    );
  }

  Widget _telaPix(AsaasCobranca cobranca) {
    final imagemBytes = cobranca.qrCodeImagemBase64 != null
        ? base64Decode(cobranca.qrCodeImagemBase64!)
        : null;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _cabecalho(),
          const SizedBox(height: 20),
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: imagemBytes != null
                  ? Image.memory(imagemBytes, width: 240, height: 240)
                  : const SizedBox(
                      width: 240,
                      height: 240,
                      child: Center(
                        child: Text("QR Code indisponível"),
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Escaneie o QR Code usando o aplicativo do banco.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 25),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Column(
              children: [
                const Text(
                  'PIX Copia e Cola',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                SelectableText(
                  cobranca.pixCopiaECola ?? "",
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(height: 25),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: cobranca.pixCopiaECola == null
                  ? null
                  : () => _copiar(
                        cobranca.pixCopiaECola!,
                        'PIX Copia e Cola copiado!',
                      ),
              icon: const Icon(Icons.copy),
              label: const Text('Copiar PIX Copia e Cola'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _telaBoleto(AsaasCobranca cobranca) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _cabecalho(),
          const SizedBox(height: 30),
          const Icon(
            Icons.receipt_long,
            size: 80,
            color: Colors.orange,
          ),
          const SizedBox(height: 20),
          const Text(
            'Gere e pague o boleto bancário. A baixa é automática após a compensação.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 25),
          if (cobranca.boletoUrl != null)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _abrirLink(cobranca.boletoUrl!),
                icon: const Icon(Icons.picture_as_pdf),
                label: const Text('Abrir boleto (PDF)'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          const SizedBox(height: 12),
          if (cobranca.faturaUrl != null)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _abrirLink(cobranca.faturaUrl!),
                icon: const Icon(Icons.open_in_new),
                label: const Text('Ver fatura completa'),
              ),
            ),
        ],
      ),
    );
  }
}
