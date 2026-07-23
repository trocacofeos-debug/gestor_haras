import 'dart:convert';

import 'package:http/http.dart' as http;


class ContratoService {


  // URL DO SEU BACKEND VERCEL

  final String baseUrl =
      "https://gestor-haras-app-one.vercel.app/api/gerar_contrato";




  Future<String> gerarContrato({

    required String propostaId,

    required String cliente,

    required double valor,

    required int parcelas,

    String? cpfCnpj,

    String? endereco,

    String? cidade,

  }) async {


    try {


      final response =
          await http.post(

        Uri.parse(baseUrl),


        headers: {

          "Content-Type":
              "application/json",

        },


        body:

        jsonEncode({

          "proposta_id":
              propostaId,


          "cliente":
              cliente,


          "valor":
              valor,


          "parcelas":
              parcelas,


          "cpf_cnpj":
              cpfCnpj,


          "endereco":
              endereco,


          "cidade":
              cidade,

        }),

      );




      if(response.statusCode != 200){

        throw Exception(
          "Erro ao gerar contrato: ${response.body}",
        );

      }



      final dados =
          jsonDecode(
            response.body,
          );



      if(dados["sucesso"] != true){

        throw Exception(
          "Contrato não gerado",
        );

      }



      return dados["contratoPdfUrl"];



    } catch(e){


      throw Exception(
        e.toString(),
      );


    }


  }


}