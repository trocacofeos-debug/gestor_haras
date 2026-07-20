import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/cliente_model.dart';

class ClienteService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  static const String collection = 'clientes';

  // =========================
  // SALVAR (CORRIGIDO)
  // =========================
  Future<void> salvarCliente(ClienteModel cliente) async {
    try {
      final docRef = _db.collection(collection).doc();

      final clienteComId = ClienteModel(
        id: docRef.id,
        tipoCliente: cliente.tipoCliente,
        nome: cliente.nome,
        sobrenome: cliente.sobrenome,
        razaoSocial: cliente.razaoSocial,
        nomeFantasia: cliente.nomeFantasia,
        cpfCnpj: cliente.cpfCnpj,
        telefone: cliente.telefone,
        email: cliente.email,
        cep: cliente.cep,
        endereco: cliente.endereco,
        numero: cliente.numero,
        complemento: cliente.complemento,
        bairro: cliente.bairro,
        cidade: cliente.cidade,
        estado: cliente.estado,
        nomeHaras: cliente.nomeHaras,
        idRural: cliente.idRural,
        enderecoHaras: cliente.enderecoHaras,
        cidadeHaras: cliente.cidadeHaras,
        estadoHaras: cliente.estadoHaras,
        ativo: cliente.ativo,
        dataCadastro: Timestamp.now(),
      );

      await docRef.set(clienteComId.toMap());
    } catch (e) {
      throw Exception('Erro ao salvar cliente: $e');
    }
  }

  // =========================
  // ATUALIZAR
  // =========================
  Future<void> atualizarCliente(ClienteModel cliente) async {
    await _db
        .collection(collection)
        .doc(cliente.id)
        .set(cliente.toMap(), SetOptions(merge: true));
  }

  // =========================
  // EXCLUIR
  // =========================
  Future<void> excluirCliente(String id) async {
    await _db.collection(collection).doc(id).delete();
  }

  // =========================
  // STREAM
  // =========================
  Stream<List<ClienteModel>> streamClientes() {
    return _db
        .collection(collection)
        .orderBy('dataCadastro', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ClienteModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }
}