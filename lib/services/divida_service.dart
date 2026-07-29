import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/divida_model.dart';


class DividaService {


  final FirebaseFirestore db =
      FirebaseFirestore.instance;



  // =====================================================
  // CRIAR DIVIDA
  // =====================================================

  Future<void> criarDivida(
    DividaModel divida,
    List<Map<String,dynamic>> parcelas,
  ) async {


    final ref = await db
        .collection("dividas")
        .add(
          divida.toMap(),
        );



    for(final parcela in parcelas){


      await ref
          .collection("parcelas")
          .add(
            parcela,
          );


    }


  }






  // =====================================================
  // TODAS AS DIVIDAS ADMIN
  // =====================================================

  Stream<QuerySnapshot<Map<String,dynamic>>>
  listarDividas(){


    return db
        .collection("dividas")
        .where(
          "status",
          isNotEqualTo: "quitada",
        )
        .snapshots();


  }






  // =====================================================
  // DIVIDAS DO CLIENTE
  // =====================================================

  Stream<QuerySnapshot<Map<String,dynamic>>>
  buscarCliente(String clienteId){


    return db
        .collection("dividas")
        .where(
          "clienteId",
          isEqualTo: clienteId,
        )
        .snapshots();


  }






  // =====================================================
  // PARCELAS DE UMA DIVIDA
  // =====================================================

  Stream<QuerySnapshot<Map<String,dynamic>>>
  parcelas(String dividaId){


    return db
        .collection("dividas")
        .doc(dividaId)
        .collection("parcelas")
        .orderBy(
          "vencimento",
        )
        .snapshots();


  }







  // =====================================================
  // PAGAR PARCELA
  // =====================================================

  Future<void> pagarParcela(
      String dividaId,
      String parcelaId,
      ) async{


    await db
        .collection("dividas")
        .doc(dividaId)
        .collection("parcelas")
        .doc(parcelaId)
        .update({

      "status":"pago",

      "dataPagamento":
          Timestamp.now(),

    });


  }







  // =====================================================
  // QUITAR DIVIDA
  // =====================================================

  Future<void> quitarDivida(
      String dividaId,
      ) async{


    await db
        .collection("dividas")
        .doc(dividaId)
        .update({

      "status":"quitada",

      "dataQuitacao":
          Timestamp.now(),

    });


  }


}