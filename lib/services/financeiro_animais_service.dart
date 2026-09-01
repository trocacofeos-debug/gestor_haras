import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/financeiro_animais.dart';

class FinanceiroAnimaisService {
  final FirebaseFirestore? firestore;
  const FinanceiroAnimaisService({this.firestore});

  Future<void> cadastrar(NovoMovimentoAnimal movimento) async {
    if (movimento.animalId.trim().isEmpty ||
        movimento.centavos <= 0 ||
        movimento.descricao.trim().isEmpty) {
      throw ArgumentError('Lançamento financeiro inválido.');
    }
    final db = firestore ?? FirebaseFirestore.instance;
    final colecao = movimento.tipo == TipoMovimentoAnimal.receita
        ? 'receitas'
        : 'despesas';
    await db
        .collection('cavalos')
        .doc(movimento.animalId)
        .collection(colecao)
        .add({
          'descricao': movimento.descricao.trim(),
          'categoria': movimento.categoria,
          'valor': movimento.centavos / 100,
          'data': Timestamp.fromDate(movimento.data),
          'origem': 'gestao_financeira',
          'criadoEm': FieldValue.serverTimestamp(),
        });
  }

  Future<FinanceiroAnimaisDados> carregar() async {
    final db = firestore ?? FirebaseFirestore.instance;
    const opcoes = GetOptions(source: Source.server);
    final animais = await db.collection('cavalos').get(opcoes);
    final nomes = <String, String>{};
    final movimentos = <MovimentoAnimal>[];
    var invalidos = 0;

    // Usa os mesmos caminhos das fichas, sem duplicar lançamentos ou exigir
    // índices/regras de collectionGroup. Limita a concorrência a cinco animais.
    for (var i = 0; i < animais.docs.length; i += 5) {
      await Future.wait(
        animais.docs.skip(i).take(5).map((animal) async {
          final nome = (animal.data()['nome'] ?? '').toString().trim();
          nomes[animal.id] = nome.isEmpty
              ? 'Animal sem nome (${animal.id})'
              : nome;
          final listas = await Future.wait([
            animal.reference.collection('receitas').get(opcoes),
            animal.reference.collection('despesas').get(opcoes),
          ]);
          for (var tipo = 0; tipo < listas.length; tipo++) {
            for (final doc in listas[tipo].docs) {
              final movimento = MovimentoAnimal.fromMap(
                doc.data(),
                id: doc.reference.path,
                animalId: animal.id,
                animalNome: nomes[animal.id]!,
                tipo: TipoMovimentoAnimal.values[tipo],
              );
              if (movimento == null) {
                invalidos++;
              } else {
                movimentos.add(movimento);
              }
            }
          }
        }),
      );
    }
    // Se qualquer leitura falhar, não retorna totais parciais como completos.
    return FinanceiroAnimaisDados(
      animais: nomes,
      movimentos: movimentos,
      registrosInvalidos: invalidos,
    );
  }
}
