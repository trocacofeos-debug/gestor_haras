import 'package:cloud_firestore/cloud_firestore.dart';


class DividaModel {


  final String id;

  final String clienteId;

  final String clienteNome;

  final double valorTotal;

  final String descricao;

  final String categoria;

  final int parcelas;

  final String status;

  final Timestamp dataCriacao;




  DividaModel({

    required this.id,

    required this.clienteId,

    required this.clienteNome,

    required this.valorTotal,

    required this.descricao,

    required this.categoria,

    required this.parcelas,

    required this.status,

    required this.dataCriacao,

  });






  Map<String,dynamic> toMap(){


    return {


      "clienteId":
          clienteId,


      "clienteNome":
          clienteNome,


      "valorTotal":
          valorTotal,


      "descricao":
          descricao,


      "categoria":
          categoria,


      "parcelas":
          parcelas,


      "status":
          status,


      "dataCriacao":
          dataCriacao,

    };


  }







  factory DividaModel.fromMap(
      Map<String,dynamic> map,
      String id,
      ){


    return DividaModel(


      id:id,


      clienteId:
          map["clienteId"] ?? "",


      clienteNome:
          map["clienteNome"] ?? "",



      valorTotal:
          (map["valorTotal"] ?? 0)
              .toDouble(),



      descricao:
          map["descricao"] ?? "",



      categoria:
          map["categoria"] ?? "",



      parcelas:
          map["parcelas"] ?? 1,



      status:
          map["status"] ?? "aberta",



      dataCriacao:
          map["dataCriacao"] ??
          Timestamp.now(),


    );


  }


}