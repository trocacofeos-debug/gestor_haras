import 'package:cloud_firestore/cloud_firestore.dart';

class PropostaModel {
  final String id;

  final String clienteId;
  final String clienteNome;

  // ==========================
  // PROPOSTA
  // ==========================

  final double valor;
  final int parcelas;
  final String observacoes;

  // ==========================
  // CLICKSIGN
  // ==========================

  final String? clicksignEnvelopeId;
  final String? clicksignSignerId;

  // ==========================
  // CONTRATO
  // ==========================

  final String? contratoPdfUrl;
  final String? contratoAssinadoUrl;

  // ==========================
  // CONTROLE
  // ==========================

  final String status;
  final bool contratoLiberado;
  final bool assinada;

  final Timestamp? dataCriacao;
  final Timestamp? dataEnvio;
  final Timestamp? dataAprovacao;
  final Timestamp? dataAssinatura;

  const PropostaModel({
    required this.id,
    required this.clienteId,
    required this.clienteNome,
    required this.valor,
    required this.parcelas,
    required this.observacoes,
    this.clicksignEnvelopeId,
    this.clicksignSignerId,
    this.contratoPdfUrl,
    this.contratoAssinadoUrl,
    required this.status,
    required this.contratoLiberado,
    required this.assinada,
    this.dataCriacao,
    this.dataEnvio,
    this.dataAprovacao,
    this.dataAssinatura,
  });

  factory PropostaModel.fromMap(
    String id,
    Map<String, dynamic> map,
  ) {
    return PropostaModel(
      id: id,

      clienteId: map['clienteId'] ?? '',
      clienteNome: map['clienteNome'] ?? '',

      valor: (map['valor'] ?? map['valorTotal'] ?? 0).toDouble(),
      parcelas: map['parcelas'] ?? 1,
      observacoes: map['observacoes'] ?? map['descricao'] ?? '',

      clicksignEnvelopeId: map['clicksignEnvelopeId'],
      clicksignSignerId: map['clicksignSignerId'],

      contratoPdfUrl: map['contratoPdfUrl'],
      contratoAssinadoUrl: map['contratoAssinadoUrl'],

      status: map['status'] ?? 'aguardando_aprovacao',

      contratoLiberado: map['contratoLiberado'] ?? false,
      assinada: map['assinada'] ?? (map['status'] == 'assinado'),

      dataCriacao: map['dataCriacao'] as Timestamp?,
      dataEnvio: map['dataEnvio'] as Timestamp?,
      dataAprovacao: map['dataAprovacao'] as Timestamp?,
      dataAssinatura: map['dataAssinatura'] as Timestamp?,
    );
  }

  // usado na tela de detalhes
  double get valorTotal => valor;

  // retorna o contrato para visualização (assinado tem prioridade)
  String? get contratoVisualizacao {
    if (contratoAssinadoUrl != null && contratoAssinadoUrl!.isNotEmpty) {
      return contratoAssinadoUrl;
    }

    if (contratoPdfUrl != null && contratoPdfUrl!.isNotEmpty) {
      return contratoPdfUrl;
    }

    return null;
  }

  Map<String, dynamic> toMap() {
    return {
      'clienteId': clienteId,
      'clienteNome': clienteNome,

      'valor': valor,
      'parcelas': parcelas,
      'observacoes': observacoes,

      'clicksignEnvelopeId': clicksignEnvelopeId,
      'clicksignSignerId': clicksignSignerId,

      'contratoPdfUrl': contratoPdfUrl,
      'contratoAssinadoUrl': contratoAssinadoUrl,

      'status': status,

      'contratoLiberado': contratoLiberado,
      'assinada': assinada,

      'dataCriacao': dataCriacao,
      'dataEnvio': dataEnvio,
      'dataAprovacao': dataAprovacao,
      'dataAssinatura': dataAssinatura,
    };
  }

  PropostaModel copyWith({
    String? id,
    String? clienteId,
    String? clienteNome,
    double? valor,
    int? parcelas,
    String? observacoes,
    String? clicksignEnvelopeId,
    String? clicksignSignerId,
    String? contratoPdfUrl,
    String? contratoAssinadoUrl,
    String? status,
    bool? contratoLiberado,
    bool? assinada,
    Timestamp? dataCriacao,
    Timestamp? dataEnvio,
    Timestamp? dataAprovacao,
    Timestamp? dataAssinatura,
  }) {
    return PropostaModel(
      id: id ?? this.id,
      clienteId: clienteId ?? this.clienteId,
      clienteNome: clienteNome ?? this.clienteNome,

      valor: valor ?? this.valor,
      parcelas: parcelas ?? this.parcelas,
      observacoes: observacoes ?? this.observacoes,

      clicksignEnvelopeId: clicksignEnvelopeId ?? this.clicksignEnvelopeId,
      clicksignSignerId: clicksignSignerId ?? this.clicksignSignerId,

      contratoPdfUrl: contratoPdfUrl ?? this.contratoPdfUrl,
      contratoAssinadoUrl: contratoAssinadoUrl ?? this.contratoAssinadoUrl,

      status: status ?? this.status,

      contratoLiberado: contratoLiberado ?? this.contratoLiberado,
      assinada: assinada ?? this.assinada,

      dataCriacao: dataCriacao ?? this.dataCriacao,
      dataEnvio: dataEnvio ?? this.dataEnvio,
      dataAprovacao: dataAprovacao ?? this.dataAprovacao,
      dataAssinatura: dataAssinatura ?? this.dataAssinatura,
    );
  }
}
