import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/produto_model.dart';

abstract class ProdutoRepository {
  Stream<List<ProdutoModel>> observar();
  Future<List<ProdutoModel>> listar();
  Future<void> salvar(ProdutoModel produto);
  Future<void> definirAtivo(String id, bool ativo);
}

class ProdutoService implements ProdutoRepository {
  ProdutoService({this.firestore});

  final FirebaseFirestore? firestore;
  FirebaseFirestore get _db => firestore ?? FirebaseFirestore.instance;
  CollectionReference<Map<String, dynamic>> get _produtos =>
      _db.collection('produtos');

  List<ProdutoModel> _ordenar(
    Iterable<QueryDocumentSnapshot<Map<String, dynamic>>> documentos,
  ) {
    final produtos = documentos
        .map((doc) => ProdutoModel.fromMap(doc.data(), doc.id))
        .toList();
    produtos.sort((a, b) {
      if (a.ativo != b.ativo) return a.ativo ? -1 : 1;
      return a.nome.toLowerCase().compareTo(b.nome.toLowerCase());
    });
    return produtos;
  }

  @override
  Stream<List<ProdutoModel>> observar() =>
      _produtos.snapshots().map((snapshot) => _ordenar(snapshot.docs));

  @override
  Future<List<ProdutoModel>> listar() async {
    final snapshot = await _produtos.get(
      const GetOptions(source: Source.server),
    );
    return _ordenar(snapshot.docs);
  }

  @override
  Future<void> salvar(ProdutoModel produto) async {
    final referencia = produto.id.isEmpty
        ? _produtos.doc()
        : _produtos.doc(produto.id);
    await referencia.set({
      ...produto.copyWith(id: referencia.id).toMap(),
      if (produto.id.isEmpty) 'criadoEm': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  @override
  Future<void> definirAtivo(String id, bool ativo) => _produtos.doc(id).update({
    'ativo': ativo,
    'atualizadoEm': FieldValue.serverTimestamp(),
  });
}
