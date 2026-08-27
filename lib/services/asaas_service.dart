import 'dart:convert';

import 'package:http/http.dart' as http;

class AsaasCobranca {
  final String paymentId;
  final String tipo;
  final double valor;
  final String status;

  final String? qrCodeImagemBase64;
  final String? pixCopiaECola;

  final String? boletoUrl;
  final String? faturaUrl;

  AsaasCobranca({
    required this.paymentId,
    required this.tipo,
    required this.valor,
    required this.status,
    this.qrCodeImagemBase64,
    this.pixCopiaECola,
    this.boletoUrl,
    this.faturaUrl,
  });

  factory AsaasCobranca.fromMap(Map<String, dynamic> map) {
    return AsaasCobranca(
      paymentId: map["paymentId"]?.toString() ?? "",
      tipo: map["tipo"]?.toString() ?? "PIX",
      valor: (map["valor"] ?? 0).toDouble(),
      status: map["status"]?.toString() ?? "",
      qrCodeImagemBase64: map["qrCodeImagemBase64"],
      pixCopiaECola: map["pixCopiaECola"],
      boletoUrl: map["boletoUrl"],
      faturaUrl: map["faturaUrl"],
    );
  }
}

class AsaasService {
  final String baseUrl =
      "https://gestor-haras-api.onrender.com/api/asaas/cobranca";

  Future<AsaasCobranca> gerarCobranca({
    required String dividaId,
    required String parcelaId,
    required String tipo,
  }) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "dividaId": dividaId,
        "parcelaId": parcelaId,
        "tipo": tipo,
      }),
    );

    final dados = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode != 200) {
      throw Exception(
        dados["detail"] ?? "Erro ao gerar cobrança",
      );
    }

    return AsaasCobranca.fromMap(dados);
  }
}
