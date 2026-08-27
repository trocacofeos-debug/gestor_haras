// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;

class PropostaService {
  final FirebaseFirestore db = FirebaseFirestore.instance;

  static const String contratoApi =
      "https://gestor-haras-api.onrender.com/gerar_contrato";

  CollectionReference<Map<String, dynamic>> get ref =>
      db.collection("propostas");

  // =====================================================
  // LISTAR PROPOSTAS
  // =====================================================

  Stream<QuerySnapshot<Map<String, dynamic>>> listar() {
    return ref.orderBy("dataCriacao", descending: true).snapshots();
  }

  // =====================================================
  // LISTAR PROPOSTAS DE UM CLIENTE
  // =====================================================

  Stream<QuerySnapshot<Map<String, dynamic>>> listarPorCliente(
    String clienteId,
  ) {
    return ref.where("clienteId", isEqualTo: clienteId).snapshots();
  }

  // =====================================================
  // BUSCAR PROPOSTA
  // =====================================================

  Future<DocumentSnapshot<Map<String, dynamic>>> buscar(
    String propostaId,
  ) async {
    return await ref.doc(propostaId).get();
  }

  // =====================================================
  // APROVAR PROPOSTA
  // =====================================================

  Future<void> aprovar(String propostaId) async {
    final doc = await ref.doc(propostaId).get();

    if (!doc.exists) {
      throw Exception("Proposta não encontrada");
    }

    await ref.doc(propostaId).update({
      "status": "aprovada",
      "dataAprovacao": Timestamp.now(),
    });
  }

  // =====================================================
  // REPROVAR PROPOSTA
  // =====================================================

  Future<void> reprovar(String propostaId) async {
    await ref.doc(propostaId).update({
      "status": "reprovada",
      "dataReprovacao": Timestamp.now(),
    });
  }

  // =====================================================
  // GERAR CONTRATO + ENVELOPE CLICKSIGN
  // O backend lê a proposta/cliente direto do Firestore e
  // grava o resultado lá mesmo — aqui só disparamos e
  // aguardamos a confirmação.
  // =====================================================

  Future<void> gerarContrato(String propostaId) async {
    print("GERANDO CONTRATO: $propostaId");

    final resposta = await http.post(
      Uri.parse(contratoApi),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"propostaId": propostaId}),
    );

    print("RESPOSTA CONTRATO:");
    print(resposta.body);

    if (resposta.statusCode != 200) {
      final erro = _extrairErro(resposta.body);

      throw Exception(erro ?? "Erro ao gerar contrato (${resposta.statusCode})");
    }

    final retorno = jsonDecode(resposta.body);

    if (retorno["sucesso"] != true) {
      throw Exception(retorno["erro"] ?? "Contrato não gerado");
    }
  }

  String? _extrairErro(String corpo) {
    try {
      final dados = jsonDecode(corpo);
      return dados["detail"]?.toString() ?? dados["erro"]?.toString();
    } catch (_) {
      return null;
    }
  }

  // =====================================================
  // ATUALIZAR STATUS MANUAL
  // =====================================================

  Future<void> atualizarStatus(String propostaId, String status) async {
    await ref.doc(propostaId).update({
      "status": status,
      "ultimaAtualizacao": Timestamp.now(),
    });
  }

  // =====================================================
  // EXCLUIR PROPOSTA
  // =====================================================

  Future<void> excluir(String propostaId) async {
    await ref.doc(propostaId).delete();
  }
}
