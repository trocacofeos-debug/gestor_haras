import 'package:cloud_firestore/cloud_firestore.dart';


class CavaloModel {

  final String? id;

  final String nome;

  final String raca;

  final String sexo;

  final String pelagem;

  final String registro;

  final int idade;

  final String descricao;

  final double preco;

  final String status;

  final List<String> fotos;

  final Timestamp? criadoEm;



  CavaloModel({

    this.id,

    required this.nome,

    required this.raca,

    required this.sexo,

    required this.pelagem,

    required this.registro,

    required this.idade,

    required this.descricao,

    required this.preco,

    required this.status,

    required this.fotos,

    this.criadoEm,

  });



  factory CavaloModel.fromMap(

      Map<String,dynamic> map,

      String id,

      ){

    return CavaloModel(

      id:id,


      nome:
      map['nome']?.toString() ?? "",


      raca:
      map['raca']?.toString() ?? "",


      sexo:
      map['sexo']?.toString() ?? "",


      pelagem:
      map['pelagem']?.toString() ?? "",


      registro:
      map['registro']?.toString() ?? "",



      idade:
      _converterInt(
        map['idade'],
      ),



      descricao:
      map['descricao']?.toString() ?? "",



      preco:
      _converterDouble(
        map['preco'],
      ),




      status:
      map['status']?.toString()
      ??
      "disponivel",




      fotos:
      _converterFotos(
        map['fotos'],
      ),




      criadoEm:
      map['criadoEm'] is Timestamp

          ?

      map['criadoEm']

          :

      null,

    );

  }





  Map<String,dynamic> toMap(){

    return {


      "nome":
      nome,


      "raca":
      raca,


      "sexo":
      sexo,


      "pelagem":
      pelagem,


      "registro":
      registro,


      "idade":
      idade,


      "descricao":
      descricao,


      "preco":
      preco,


      "status":
      status,


      "fotos":
      fotos,


      "criadoEm":
      criadoEm
      ??
      FieldValue.serverTimestamp(),


    };

  }





  static List<String> _converterFotos(dynamic valor){


    if(valor == null){

      return [];

    }



    if(valor is List){


      return valor

          .where(
              (e)=> e != null
      )

          .map(
              (e)=>e.toString().trim()
      )

          .where(
              (e)=>e.isNotEmpty
      )

          .toList();


    }



    return [];

  }





  static int _converterInt(dynamic valor){


    if(valor == null){

      return 0;

    }


    if(valor is int){

      return valor;

    }


    if(valor is double){

      return valor.toInt();

    }


    return int.tryParse(
      valor.toString(),
    ) ?? 0;


  }





  static double _converterDouble(dynamic valor){


    if(valor == null){

      return 0;

    }



    if(valor is double){

      return valor;

    }



    if(valor is int){

      return valor.toDouble();

    }



    return double.tryParse(
      valor.toString(),
    ) ?? 0;


  }



}