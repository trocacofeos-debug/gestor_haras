import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/cavalo_model.dart';
import '../models/registro_animal_model.dart';

abstract class RegistroAnimalRepository {
  Stream<List<RegistroAnimalModel>> observar(TipoRegistroAnimal tipo);
  Future<List<CavaloModel>> listarAnimais();
  Future<void> salvar(RegistroAnimalModel registro);
  Future<void> excluir(String id);
}

class RegistroAnimalService implements RegistroAnimalRepository {
  RegistroAnimalService({FirebaseFirestore? firestore})
    : firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore firestore;
  CollectionReference<Map<String, dynamic>> get _registros =>
      firestore.collection('registros_animais');

  @override
  Stream<List<RegistroAnimalModel>> observar(TipoRegistroAnimal tipo) =>
      _registros.snapshots().map((snapshot) {
        final itens =
            snapshot.docs
                .map((doc) => RegistroAnimalModel.fromMap(doc.data(), doc.id))
                .where((item) => item.tipo == tipo)
                .toList()
              ..sort((a, b) => b.data.compareTo(a.data));
        return itens;
      });

  @override
  Future<List<CavaloModel>> listarAnimais() async {
    final snapshot = await firestore.collection('cavalos').get();
    final animais =
        snapshot.docs
            .map((doc) => CavaloModel.fromMap(doc.data(), doc.id))
            .toList()
          ..sort((a, b) => a.nome.compareTo(b.nome));
    return animais;
  }

  @override
  Future<void> salvar(RegistroAnimalModel registro) async {
    final referencia = registro.id.isEmpty
        ? _registros.doc()
        : _registros.doc(registro.id);
    await referencia.set({
      ...registro.toMap(),
      if (registro.id.isEmpty) 'criadoEm': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  @override
  Future<void> excluir(String id) => _registros.doc(id).delete();
}
