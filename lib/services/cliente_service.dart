import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../models/cliente_model.dart';

class ClienteService {

  final FirebaseFirestore _db =
      FirebaseFirestore.instance;


  static const String collection =
      'clientes';



  // =========================
  // SALVAR CLIENTE
  // =========================
  Future<void> salvarCliente(
      ClienteModel cliente,
      ) async {

    try {

      final docRef =
          _db.collection(collection).doc();


      final clienteComId =
      ClienteModel(

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
        clienteComId.toMap(),
      );


      debugPrint(
        "CLIENTE SALVO: ${docRef.id}",
      );


    } catch (e) {

      debugPrint(
        "ERRO AO SALVAR CLIENTE: $e",
      );

      throw Exception(
        "Erro ao salvar cliente: $e",
      );
    }
  }





  // =========================
  // ATUALIZAR CLIENTE
  // =========================
  Future<void> atualizarCliente(
      ClienteModel cliente,
      ) async {


    await _db
        .collection(collection)
        .doc(cliente.id)
        .set(
      cliente.toMap(),
      SetOptions(
        merge: true,
      ),
    );
  }






  // =========================
  // EXCLUIR CLIENTE
  // =========================
  Future<void> excluirCliente(
      String id,
      ) async {


    await _db
        .collection(collection)
        .doc(id)
        .delete();

  }






  // =========================
  // LISTAR CLIENTES
  // =========================
  Stream<List<ClienteModel>> streamClientes() {


    return _db
        .collection(collection)
        .snapshots()
        .map(
          (snapshot) {


        debugPrint(
          "TOTAL CLIENTES FIREBASE: "
              "${snapshot.docs.length}",
        );



        for(final doc in snapshot.docs){

          debugPrint(
            "CLIENTE ID: ${doc.id}",
          );

        }



        return snapshot.docs
            .map(

              (doc) => ClienteModel.fromMap(
                doc.data(),
                doc.id,
              ),

        )
            .toList();

      },

    );

  }



}