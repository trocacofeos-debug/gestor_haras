// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;


class PropostaService {


  final FirebaseFirestore db =
      FirebaseFirestore.instance;



  static const String contratoApi =
      "https://gestor-haras.vercel.app/api/gerar_contrato";





  CollectionReference<Map<String,dynamic>>
  get ref =>
      db.collection("propostas");







  // =====================================================
  // LISTAR PROPOSTAS
  // =====================================================

  Stream<QuerySnapshot<Map<String,dynamic>>>
  listar(){


    return ref
        .orderBy(
          "dataCriacao",
          descending:true,
        )
        .snapshots();


  }








  // =====================================================
  // BUSCAR PROPOSTA
  // =====================================================

  Future<DocumentSnapshot<Map<String,dynamic>>>
  buscar(
      String propostaId,
      ) async {


    return await ref
        .doc(propostaId)
        .get();


  }









  // =====================================================
  // SALVAR DOCUMENTOS R2
  // =====================================================

  Future<void> salvarDocumentos(

      String propostaId, {

        String? rgUrl,

        String? comprovanteUrl,

        String? selfieDocumentoUrl,

      }

      ) async {



    final dados =
    <String,dynamic>{};




    if(rgUrl != null &&
        rgUrl.isNotEmpty){


      dados["rgUrl"] =
          rgUrl;


    }





    if(comprovanteUrl != null &&
        comprovanteUrl.isNotEmpty){


      dados["comprovanteUrl"] =
          comprovanteUrl;


    }






    if(selfieDocumentoUrl != null &&
        selfieDocumentoUrl.isNotEmpty){


      dados["selfieDocumentoUrl"] =
          selfieDocumentoUrl;


    }






    dados["documentosAtualizadosEm"] =
        Timestamp.now();





    await ref
        .doc(propostaId)
        .update(
      dados,
    );



  }









  // =====================================================
  // APROVAR PROPOSTA
  // =====================================================

  Future<void> aprovar(

      String propostaId,

      ) async {



    final doc =
    await ref
        .doc(propostaId)
        .get();





    if(!doc.exists){


      throw Exception(
        "Proposta não encontrada",
      );


    }






    final dados =
        doc.data();





    if(dados == null){


      throw Exception(
        "Dados inválidos",
      );


    }







    final documentosOk =


        dados["rgUrl"] != null &&

            dados["rgUrl"]
                .toString()
                .isNotEmpty &&



            dados["comprovanteUrl"] != null &&

            dados["comprovanteUrl"]
                .toString()
                .isNotEmpty &&



            dados["selfieDocumentoUrl"] != null &&

            dados["selfieDocumentoUrl"]
                .toString()
                .isNotEmpty;








    if(!documentosOk){


      throw Exception(
        "Documentos incompletos",
      );


    }







    await ref
        .doc(propostaId)
        .update({



      "status":
      "aprovada",



      "dataAprovacao":
      Timestamp.now(),



    });




  }









  // =====================================================
  // GERAR CONTRATO PDF + ENVIAR PARA R2
  // =====================================================

  Future<String> gerarContrato(

      String propostaId,

      ) async {



    print(
      "GERANDO CONTRATO: $propostaId",
    );





    final proposta =
    await buscar(
      propostaId,
    );





    if(!proposta.exists){


      throw Exception(
        "Proposta não encontrada",
      );


    }







    final dados =
        proposta.data();






    if(dados == null){


      throw Exception(
        "Dados da proposta vazios",
      );


    }







    final body = {


      "proposta_id":
      propostaId,



      "cliente":
      dados["clienteNome"] ?? "",



      "valor":
      dados["valor"] ??
          dados["valorTotal"] ??
          0,



      "parcelas":
      dados["parcelas"] ??
          1,



      "cpf_cnpj":
      dados["cpf_cnpj"] ??
          "",



      "endereco":
      dados["endereco"] ??
          "",



      "cidade":
      dados["cidade"] ??
          "",




      // ===========================
      // IMPORTANTE PARA R2
      // ===========================

      "pasta":
      "contratos",



      "nomeArquivo":

      "contrato_$propostaId.pdf",


    };








    final resposta =
    await http.post(


      Uri.parse(
        contratoApi,
      ),



      headers:{


        "Content-Type":
        "application/json",


      },



      body:
      jsonEncode(
        body,
      ),



    );








    print(
      "RESPOSTA CONTRATO:"
    );


    print(
      resposta.body,
    );








    if(resposta.statusCode != 200){


      throw Exception(

        "Erro API contrato: "
            "${resposta.statusCode}\n"
            "${resposta.body}",

      );


    }







    final retorno =
    jsonDecode(
      resposta.body,
    );








    if(retorno["sucesso"] != true){


      throw Exception(

        retorno["erro"] ??

            "Contrato não gerado",

      );


    }








    final contratoUrl =

        retorno["contratoPdfUrl"] ??

            retorno["url"];







    if(contratoUrl == null ||
        contratoUrl.toString().isEmpty){


      throw Exception(
        "API não retornou URL do contrato",
      );


    }







    await ref
        .doc(propostaId)
        .update({



      "contratoPdfUrl":
      contratoUrl,



      "pastaContrato":
      "contratos",



      "contratoGerado":
      true,



      "contratoLiberado":
      true,



      "status":
      "aguardando_assinatura",



      "dataContrato":
      Timestamp.now(),



    });







    return contratoUrl.toString();


  }

    // =====================================================
  // LIBERAR CONTRATO
  // =====================================================

  Future<String> liberarContrato(

      String propostaId,

      ) async {


    final url =
    await gerarContrato(
      propostaId,
    );


    return url;


  }









  // =====================================================
  // BUSCAR URL CONTRATO
  // =====================================================

  Future<String?> buscarContratoUrl(

      String propostaId,

      ) async {



    final doc =
    await ref
        .doc(propostaId)
        .get();




    if(!doc.exists){


      return null;


    }





    final dados =
        doc.data();




    return dados?["contratoPdfUrl"]?.toString();



  }









  // =====================================================
  // FINALIZAR ASSINATURA CLIENTE
  // =====================================================

  Future<void> finalizarAssinatura(

      String propostaId,

      String assinaturaUrl,

      ) async {



    await ref
        .doc(propostaId)
        .update({




      "status":

      "contrato_assinado",




      "assinaturaUrl":

      assinaturaUrl,




      "assinada":

      true,




      "dataAssinatura":

      Timestamp.now(),




    });



  }









  // =====================================================
  // CONFIRMAR CONTRATO ASSINADO PELO ADMIN
  // =====================================================

  Future<void> confirmarContratoAssinado(

      String propostaId,

      ) async {



    await ref
        .doc(propostaId)
        .update({




      "status":

      "contrato_assinado",




      "assinada":

      true,




      "dataConfirmacao":

      Timestamp.now(),




    });



  }









  // =====================================================
  // REPROVAR PROPOSTA
  // =====================================================

  Future<void> reprovar(

      String propostaId,

      ) async {



    await ref
        .doc(propostaId)
        .update({



      "status":

      "reprovada",




      "dataReprovacao":

      Timestamp.now(),




    });



  }









  // =====================================================
  // ATUALIZAR STATUS MANUAL
  // =====================================================

  Future<void> atualizarStatus(

      String propostaId,

      String status,

      ) async {



    await ref
        .doc(propostaId)
        .update({



      "status":

      status,




      "ultimaAtualizacao":

      Timestamp.now(),




    });



  }









  // =====================================================
  // SALVAR CONTRATO MANUALMENTE
  // CASO API RETORNE URL
  // =====================================================

  Future<void> salvarContratoUrl(

      String propostaId,

      String url,

      ) async {



    await ref
        .doc(propostaId)
        .update({



      "contratoPdfUrl":

      url,




      "contratoGerado":

      true,




      "pastaContrato":

      "contratos",




      "dataContrato":

      Timestamp.now(),




    });



  }









  // =====================================================
  // EXCLUIR PROPOSTA
  // =====================================================

  Future<void> excluir(

      String propostaId,

      ) async {



    await ref
        .doc(propostaId)
        .delete();



  }



}