import 'package:cloud_firestore/cloud_firestore.dart';


class PropostaService {


  final FirebaseFirestore db =
      FirebaseFirestore.instance;



  CollectionReference<Map<String, dynamic>>
      get ref =>
          db.collection('propostas');



  // =====================================================
  // LISTAR PROPOSTAS
  // =====================================================

  Stream<QuerySnapshot<Map<String, dynamic>>>
      listar() {

    return ref
        .orderBy(
          'dataCriacao',
          descending: true,
        )
        .snapshots();

  }




  // =====================================================
  // BUSCAR PROPOSTA
  // =====================================================

  Future<DocumentSnapshot<Map<String, dynamic>>>
      buscar(
    String propostaId,
  ) async {

    return await ref
        .doc(propostaId)
        .get();

  }




  // =====================================================
  // SALVAR DOCUMENTOS (R2)
  // =====================================================

  Future<void> salvarDocumentos(
    String propostaId, {

    String? rgUrl,

    String? comprovanteUrl,

    String? selfieDocumentoUrl,

  }) async {


    final dados = <String, dynamic>{};


    if (rgUrl != null &&
        rgUrl.isNotEmpty) {

      dados['rgUrl'] = rgUrl;

    }


    if (comprovanteUrl != null &&
        comprovanteUrl.isNotEmpty) {

      dados['comprovanteUrl'] =
          comprovanteUrl;

    }


    if (selfieDocumentoUrl != null &&
        selfieDocumentoUrl.isNotEmpty) {

      dados['selfieDocumentoUrl'] =
          selfieDocumentoUrl;

    }


    dados['documentosAtualizadosEm'] =
        Timestamp.now();



    await ref
        .doc(propostaId)
        .update(dados);

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



    if (!doc.exists) {

      throw Exception(
        'Proposta não encontrada',
      );

    }



    final data =
        doc.data();



    if (data == null) {

      throw Exception(
        'Dados da proposta inválidos',
      );

    }




    final documentosOk =

        data['rgUrl'] != null &&
        data['rgUrl']
            .toString()
            .isNotEmpty &&


        data['comprovanteUrl'] != null &&
        data['comprovanteUrl']
            .toString()
            .isNotEmpty &&


        data['selfieDocumentoUrl'] != null &&
        data['selfieDocumentoUrl']
            .toString()
            .isNotEmpty;



    if (!documentosOk) {

      throw Exception(
        'Documentos incompletos',
      );

    }



    await ref
        .doc(propostaId)
        .update({

      'status':
          'aprovada',


      'dataAprovacao':
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

      'status':
          'reprovada',


      'dataReprovacao':
          Timestamp.now(),

    });


  }





  // =====================================================
  // LIBERAR CONTRATO
  // =====================================================

  Future<void> liberarContrato(
    String propostaId,
  ) async {


    await ref
        .doc(propostaId)
        .update({

      'status':
          'aguardando_assinatura',


      'contratoLiberado':
          true,


      'dataContrato':
          Timestamp.now(),

    });


  }





  // =====================================================
  // FINALIZAR ASSINATURA
  // =====================================================

  Future<void> finalizarAssinatura(
    String propostaId,

    String assinaturaUrl,

  ) async {


    await ref
        .doc(propostaId)
        .update({

      'status':
          'assinado',


      'assinaturaUrl':
          assinaturaUrl,


      'dataAssinatura':
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

      'status':
          status,


      'ultimaAtualizacao':
          Timestamp.now(),

    });


  }



}