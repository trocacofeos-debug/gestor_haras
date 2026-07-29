// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';


class DashboardService {


  final FirebaseFirestore db =
      FirebaseFirestore.instance;





  Future<Map<String, dynamic>> getResumo() async {


    try {



      final clientesSnap =
          await db
              .collection('clientes')
              .get();





      final cavalosSnap =
          await db
              .collection('cavalos')
              .get();





      final propostasSnap =
          await db
              .collection('propostas')
              .get();






      final dividasSnap =
          await db
              .collection('dividas')
              .get();






      double recebido = 0;

      double pendente = 0;







      print(
        "DIVIDAS ENCONTRADAS: ${dividasSnap.docs.length}",
      );








      for(final divida in dividasSnap.docs){



        print(
          "DIVIDA: ${divida.data()}",
        );



        final parcelasSnap =
            await db
                .collection('dividas')
                .doc(divida.id)
                .collection('parcelas')
                .get();







        // Caso a dívida não tenha parcelas
        if(parcelasSnap.docs.isEmpty){



          final valor =
              converterValor(
                divida.data()['valorTotal'],
              );



          final status =
              divida.data()['status']
                  ?.toString()
                  .toLowerCase()
                  .trim()
                  ??
                  "aberta";




          if(
            status == "pago" ||
            status == "quitada" ||
            status == "quitado"
          ){

            recebido += valor;

          }else{

            pendente += valor;

          }



        }







        // Soma das parcelas
        for(final parcela in parcelasSnap.docs){



          final data =
              parcela.data();




          print(
            "PARCELA: $data",
          );





          final valor =
              converterValor(
                data['valor'],
              );




          final status =
              data['status']
                  ?.toString()
                  .toLowerCase()
                  .trim()
                  ??
                  "pendente";







          if(
            status == "pago" ||
            status == "quitada" ||
            status == "quitado"
          ){



            recebido += valor;



          }else{



            pendente += valor;



          }



        }




      }








      print(
        "RECEBIDO FINAL: $recebido",
      );


      print(
        "PENDENTE FINAL: $pendente",
      );









      return {



        "clientes":
            clientesSnap.size,



        "cavalos":
            cavalosSnap.size,



        "propostas":
            propostasSnap.size,



        "recebido":
            recebido,



        "pendente":
            pendente,



        "total":
            recebido + pendente,



      };





    } catch(e, stack){



      print(
        "ERRO DASHBOARD: $e",
      );


      print(
        stack,
      );



      return {



        "clientes":0,

        "cavalos":0,

        "propostas":0,

        "recebido":0,

        "pendente":0,

        "total":0,



      };


    }



  }









  double converterValor(dynamic valor){



    if(valor == null){

      return 0;

    }





    if(valor is num){

      return valor.toDouble();

    }






    return double.tryParse(

      valor
          .toString()
          .replaceAll(",", "."),

    ) ?? 0;



  }









  Stream<QuerySnapshot<Map<String,dynamic>>>
  ultimosClientes(){



    return db

        .collection('clientes')

        .limit(5)

        .snapshots();



  }



}