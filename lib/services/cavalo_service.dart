import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/cavalo_model.dart';


class CavaloService {


  final FirebaseFirestore _db =
      FirebaseFirestore.instance;


  final String collection =
      "cavalos";




  Future<String> criar(
      CavaloModel cavalo,
      ) async {


    final doc = await _db
        .collection(collection)
        .add(

      cavalo.toMap(),

    );


    return doc.id;


  }





  Stream<List<CavaloModel>> listar(){


    return _db
        .collection(collection)
        .orderBy(
        "criadoEm",
        descending:true
    )
        .snapshots()
        .map((snapshot){


      return snapshot.docs.map((doc){


        return CavaloModel.fromMap(

          doc.data(),

          doc.id,

        );


      }).toList();


    });


  }






  Future<CavaloModel?> buscar(
      String id,
      ) async {


    final doc =
    await _db
        .collection(collection)
        .doc(id)
        .get();



    if(!doc.exists){

      return null;

    }



    return CavaloModel.fromMap(

      doc.data()!,

      doc.id,

    );


  }







  Future<void> atualizar(

      String id,

      CavaloModel cavalo,

      ) async {


    await _db
        .collection(collection)
        .doc(id)
        .update(

      cavalo.toMap(),

    );


  }







  Future<void> excluir(
      String id,
      ) async {


    await _db
        .collection(collection)
        .doc(id)
        .delete();


  }



}