import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../models/cliente_model.dart';


class ClienteService {


  final FirebaseFirestore _db =
      FirebaseFirestore.instance;


  static const String collection =
      'clientes';





  // ==================================
  // CRIAR CLIENTE
  // ==================================

  Future<String> criar(
      ClienteModel cliente,
      ) async {


    try {


      final docRef =
      _db.collection(collection).doc();



      final novoCliente = ClienteModel(


        id: docRef.id,


        tipoCliente:
        cliente.tipoCliente,


        nome:
        cliente.nome,


        sobrenome:
        cliente.sobrenome,


        razaoSocial:
        cliente.razaoSocial,


        nomeFantasia:
        cliente.nomeFantasia,


        cpfCnpj:
        cliente.cpfCnpj,


        telefone:
        cliente.telefone,


        email:
        cliente.email,



        cep:
        cliente.cep,


        endereco:
        cliente.endereco,


        numero:
        cliente.numero,


        complemento:
        cliente.complemento,


        bairro:
        cliente.bairro,


        cidade:
        cliente.cidade,


        estado:
        cliente.estado,



        nomeHaras:
        cliente.nomeHaras,


        idRural:
        cliente.idRural,



        enderecoHaras:
        cliente.enderecoHaras,


        cidadeHaras:
        cliente.cidadeHaras,


        estadoHaras:
        cliente.estadoHaras,



        ativo:
        cliente.ativo,



        dataCadastro:
        Timestamp.now(),


      );





      await docRef.set(

        novoCliente.toMap(),

      );




      debugPrint(

        "CLIENTE CRIADO: ${docRef.id}",

      );



      return docRef.id;



    } catch(e){


      debugPrint(

        "ERRO AO CRIAR CLIENTE: $e",

      );


      rethrow;


    }


  }








  // ==================================
  // SALVAR CLIENTE
  // compatibilidade
  // ==================================

  Future<void> salvarCliente(
      ClienteModel cliente,
      ) async {


    await criar(cliente);


  }









  // ==================================
  // BUSCAR CLIENTE POR ID
  // ==================================

  Future<ClienteModel?> buscarPorId(
      String id,
      ) async {


    final doc = await _db

        .collection(collection)

        .doc(id)

        .get();




    if(!doc.exists){

      return null;

    }





    return ClienteModel.fromMap(

      doc.data()!,

      doc.id,

    );


  }









  // ==================================
  // ATUALIZAR CLIENTE
  // ==================================

  Future<void> atualizarCliente(
      ClienteModel cliente,
      ) async {



    await _db

        .collection(collection)

        .doc(cliente.id)

        .set(

      cliente.toMap(),

      SetOptions(

        merge:true,

      ),

    );



  }









  // ==================================
  // EXCLUIR CLIENTE
  // ==================================

  Future<void> excluirCliente(
      String id,
      ) async {


    await _db

        .collection(collection)

        .doc(id)

        .delete();



    debugPrint(

      "CLIENTE EXCLUIDO: $id",

    );


  }









  // ==================================
  // LISTAR CLIENTES
  // ==================================

  Stream<List<ClienteModel>> streamClientes(){



    return _db

        .collection(collection)

        .snapshots()



        .map((snapshot){



      debugPrint(

        "TOTAL CLIENTES FIREBASE: ${snapshot.docs.length}",

      );





      return snapshot.docs.map((doc){



        try {



          return ClienteModel.fromMap(

            doc.data(),

            doc.id,

          );



        } catch(e){



          debugPrint(

            "ERRO CLIENTE ${doc.id}: $e",

          );



          rethrow;


        }




      }).toList();



    });



  }









  // ==================================
  // STREAM CLIENTE INDIVIDUAL
  // ==================================

  Stream<ClienteModel?> streamCliente(
      String id,
      ){


    return _db

        .collection(collection)

        .doc(id)

        .snapshots()

        .map((doc){



      if(!doc.exists){

        return null;

      }



      return ClienteModel.fromMap(

        doc.data()!,

        doc.id,

      );



    });



  }



}