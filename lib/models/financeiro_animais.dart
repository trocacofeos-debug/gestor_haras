import 'package:cloud_firestore/cloud_firestore.dart';
import 'despesa_cavalo_model.dart';

enum TipoMovimentoAnimal { receita, despesa }

class MovimentoAnimal {
  final String id;
  final String animalId;
  final String animalNome;
  final TipoMovimentoAnimal tipo;
  final String descricao;
  final String categoria;
  final int centavos;
  final DateTime? data;

  const MovimentoAnimal({
    required this.id,
    required this.animalId,
    required this.animalNome,
    required this.tipo,
    required this.descricao,
    required this.categoria,
    required this.centavos,
    required this.data,
  });

  // Não transforma valores inválidos em zero nem inventa datas de lançamento.
  static MovimentoAnimal? fromMap(
    Map<String, dynamic> map, {
    required String id,
    required String animalId,
    required String animalNome,
    required TipoMovimentoAnimal tipo,
  }) {
    final valor = map['valor'];
    if (valor is! num || !valor.isFinite || valor < 0) return null;
    final centavos = valor * 100;
    if (!centavos.isFinite) return null;
    final data = map['data'];
    return MovimentoAnimal(
      id: id,
      animalId: animalId,
      animalNome: animalNome,
      tipo: tipo,
      descricao: (map['descricao'] ?? '').toString(),
      categoria: tipo == TipoMovimentoAnimal.despesa
          ? categoriaDespesaFromString(
              (map['categoria'] ?? '').toString(),
            ).label
          : 'Receita',
      centavos: centavos.round(),
      data: data is Timestamp ? data.toDate() : null,
    );
  }
}

class FinanceiroAnimaisDados {
  final Map<String, String> animais;
  final List<MovimentoAnimal> movimentos;
  final int registrosInvalidos;

  const FinanceiroAnimaisDados({
    required this.animais,
    required this.movimentos,
    this.registrosInvalidos = 0,
  });

  List<MovimentoAnimal> filtrar({
    String? animalId,
    TipoMovimentoAnimal? tipo,
    DateTime? inicio,
    DateTime? fim,
  }) {
    final primeiroDia = inicio == null
        ? null
        : DateTime(inicio.year, inicio.month, inicio.day);
    final depoisDoUltimoDia = fim == null
        ? null
        : DateTime(fim.year, fim.month, fim.day + 1);
    final resultado = movimentos.where((m) {
      if (animalId != null && m.animalId != animalId) return false;
      if (tipo != null && m.tipo != tipo) return false;
      if (primeiroDia != null || depoisDoUltimoDia != null) {
        if (m.data == null) return false;
        if (primeiroDia != null && m.data!.isBefore(primeiroDia)) return false;
        if (depoisDoUltimoDia != null && !m.data!.isBefore(depoisDoUltimoDia)) {
          return false;
        }
      }
      return true;
    }).toList();
    resultado.sort((a, b) {
      if (a.data == null) return b.data == null ? a.id.compareTo(b.id) : 1;
      if (b.data == null) return -1;
      return b.data!.compareTo(a.data!);
    });
    return resultado;
  }
}

class ResumoFinanceiroAnimais {
  final int receitas;
  final int despesas;
  int get saldo => receitas - despesas;

  const ResumoFinanceiroAnimais({
    required this.receitas,
    required this.despesas,
  });

  factory ResumoFinanceiroAnimais.calcular(
    Iterable<MovimentoAnimal> movimentos,
  ) {
    var receitas = 0;
    var despesas = 0;
    for (final movimento in movimentos) {
      if (movimento.tipo == TipoMovimentoAnimal.receita) {
        receitas += movimento.centavos;
      } else {
        despesas += movimento.centavos;
      }
    }
    return ResumoFinanceiroAnimais(receitas: receitas, despesas: despesas);
  }
}
