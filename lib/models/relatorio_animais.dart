import 'financeiro_animais.dart';

class FiltrosRelatorioAnimais {
  const FiltrosRelatorioAnimais({
    this.animalIds = const {},
    this.tipo,
    this.categoria,
    this.inicio,
    this.fim,
  });

  final Set<String> animalIds;
  final TipoMovimentoAnimal? tipo;
  final String? categoria;
  final DateTime? inicio;
  final DateTime? fim;

  List<MovimentoAnimal> aplicar(Iterable<MovimentoAnimal> movimentos) {
    final primeiroDia = inicio == null
        ? null
        : DateTime(inicio!.year, inicio!.month, inicio!.day);
    final depoisDoFim = fim == null
        ? null
        : DateTime(fim!.year, fim!.month, fim!.day + 1);
    final resultado = movimentos.where((movimento) {
      if (animalIds.isNotEmpty && !animalIds.contains(movimento.animalId)) {
        return false;
      }
      if (tipo != null && movimento.tipo != tipo) return false;
      if (categoria != null && movimento.categoria != categoria) return false;
      if (primeiroDia != null || depoisDoFim != null) {
        if (movimento.data == null) return false;
        if (primeiroDia != null && movimento.data!.isBefore(primeiroDia)) {
          return false;
        }
        if (depoisDoFim != null && !movimento.data!.isBefore(depoisDoFim)) {
          return false;
        }
      }
      return true;
    }).toList();
    resultado.sort((a, b) {
      if (a.data == null) return b.data == null ? a.id.compareTo(b.id) : 1;
      if (b.data == null) return -1;
      final data = b.data!.compareTo(a.data!);
      return data != 0 ? data : a.animalNome.compareTo(b.animalNome);
    });
    return resultado;
  }
}

class ResumoAnimalRelatorio {
  const ResumoAnimalRelatorio({
    required this.animalId,
    required this.animalNome,
    required this.receitas,
    required this.despesas,
    required this.lancamentos,
  });

  final String animalId;
  final String animalNome;
  final int receitas;
  final int despesas;
  final int lancamentos;
  int get saldo => receitas - despesas;
}

List<ResumoAnimalRelatorio> resumirPorAnimal(
  Iterable<MovimentoAnimal> movimentos,
) {
  final grupos = <String, List<MovimentoAnimal>>{};
  for (final movimento in movimentos) {
    grupos.putIfAbsent(movimento.animalId, () => []).add(movimento);
  }
  final resumos = grupos.entries.map((grupo) {
    final resumo = ResumoFinanceiroAnimais.calcular(grupo.value);
    return ResumoAnimalRelatorio(
      animalId: grupo.key,
      animalNome: grupo.value.first.animalNome,
      receitas: resumo.receitas,
      despesas: resumo.despesas,
      lancamentos: grupo.value.length,
    );
  }).toList();
  resumos.sort(
    (a, b) => a.animalNome.toLowerCase().compareTo(b.animalNome.toLowerCase()),
  );
  return resumos;
}
