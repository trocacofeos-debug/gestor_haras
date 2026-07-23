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
  // DOCUMENTOS
  // ==========================


  final String? rgUrl;

  final String? comprovanteUrl;

  final String? selfieDocumentoUrl;





  // ==========================
  // CONTRATO
  // ==========================


  final String? contratoUrl;

  final String? contratoPdfUrl;

  final String? assinaturaUrl;





  // ==========================
  // CONTROLE
  // ==========================


  final String status;


  final bool documentosEnviados;


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



    this.rgUrl,


    this.comprovanteUrl,


    this.selfieDocumentoUrl,



    this.contratoUrl,


    this.contratoPdfUrl,


    this.assinaturaUrl,



    required this.status,



    required this.documentosEnviados,


    required this.contratoLiberado,


    required this.assinada,



    this.dataCriacao,


    this.dataEnvio,


    this.dataAprovacao,


    this.dataAssinatura,


  });









  factory PropostaModel.fromMap(


    String id,


    Map<String,dynamic> map,


  ){



    return PropostaModel(



      id:id,



      clienteId:

      map['clienteId'] ?? '',



      clienteNome:

      map['clienteNome'] ?? '',







      valor:

      (map['valor'] ?? 0).toDouble(),



      parcelas:

      map['parcelas'] ?? 1,



      observacoes:

      map['observacoes'] ?? '',







      rgUrl:

      map['rgUrl'],



      comprovanteUrl:

      map['comprovanteUrl'],



      selfieDocumentoUrl:

      map['selfieDocumentoUrl'],








      // aceita os dois nomes

      contratoUrl:

      map['contratoUrl'],



      contratoPdfUrl:

      map['contratoPdfUrl'],



      assinaturaUrl:

      map['assinaturaUrl'],








      status:

      map['status'] ??

          'aguardando_documentos',







      documentosEnviados:

      map['documentosEnviados'] ??

          false,






      contratoLiberado:

      map['contratoLiberado'] ??

          false,







      assinada:

      map['assinada'] ??

          false,







      dataCriacao:

      map['dataCriacao'] as Timestamp?,



      dataEnvio:

      map['dataEnvio'] as Timestamp?,



      dataAprovacao:

      map['dataAprovacao'] as Timestamp?,



      dataAssinatura:

      map['dataAssinatura'] as Timestamp?,



    );


  }






  // usado na tela de detalhes

  double get valorTotal => valor;



  // retorna o contrato existente

  String? get contratoVisualizacao {


    if(contratoUrl != null &&

        contratoUrl!.isNotEmpty){

      return contratoUrl;

    }



    if(contratoPdfUrl != null &&

        contratoPdfUrl!.isNotEmpty){

      return contratoPdfUrl;

    }



    return null;


  }
  Map<String,dynamic> toMap(){


    return {


      'clienteId':
      clienteId,


      'clienteNome':
      clienteNome,



      'valor':
      valor,


      'parcelas':
      parcelas,


      'observacoes':
      observacoes,





      'rgUrl':
      rgUrl,


      'comprovanteUrl':
      comprovanteUrl,


      'selfieDocumentoUrl':
      selfieDocumentoUrl,





      // salva os dois para compatibilidade

      'contratoUrl':
      contratoUrl,


      'contratoPdfUrl':
      contratoPdfUrl,



      'assinaturaUrl':
      assinaturaUrl,





      'status':
      status,





      'documentosEnviados':
      documentosEnviados,



      'contratoLiberado':
      contratoLiberado,



      'assinada':
      assinada,





      'dataCriacao':
      dataCriacao,


      'dataEnvio':
      dataEnvio,


      'dataAprovacao':
      dataAprovacao,


      'dataAssinatura':
      dataAssinatura,



    };


  }









  PropostaModel copyWith({



    String? id,


    String? clienteId,


    String? clienteNome,



    double? valor,


    int? parcelas,


    String? observacoes,



    String? rgUrl,


    String? comprovanteUrl,


    String? selfieDocumentoUrl,



    String? contratoUrl,


    String? contratoPdfUrl,


    String? assinaturaUrl,



    String? status,



    bool? documentosEnviados,


    bool? contratoLiberado,


    bool? assinada,



    Timestamp? dataCriacao,


    Timestamp? dataEnvio,


    Timestamp? dataAprovacao,


    Timestamp? dataAssinatura,



  }){



    return PropostaModel(



      id:

      id ?? this.id,



      clienteId:

      clienteId ?? this.clienteId,



      clienteNome:

      clienteNome ?? this.clienteNome,







      valor:

      valor ?? this.valor,



      parcelas:

      parcelas ?? this.parcelas,



      observacoes:

      observacoes ?? this.observacoes,







      rgUrl:

      rgUrl ?? this.rgUrl,



      comprovanteUrl:

      comprovanteUrl ?? this.comprovanteUrl,



      selfieDocumentoUrl:

      selfieDocumentoUrl ??

          this.selfieDocumentoUrl,









      contratoUrl:

      contratoUrl ??

          this.contratoUrl,





      contratoPdfUrl:

      contratoPdfUrl ??

          this.contratoPdfUrl,





      assinaturaUrl:

      assinaturaUrl ??

          this.assinaturaUrl,








      status:

      status ?? this.status,







      documentosEnviados:

      documentosEnviados ??

          this.documentosEnviados,





      contratoLiberado:

      contratoLiberado ??

          this.contratoLiberado,





      assinada:

      assinada ??

          this.assinada,







      dataCriacao:

      dataCriacao ??

          this.dataCriacao,



      dataEnvio:

      dataEnvio ??

          this.dataEnvio,



      dataAprovacao:

      dataAprovacao ??

          this.dataAprovacao,



      dataAssinatura:

      dataAssinatura ??

          this.dataAssinatura,



    );


  }



}