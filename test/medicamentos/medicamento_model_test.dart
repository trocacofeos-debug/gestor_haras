import 'package:flutter_test/flutter_test.dart';
import 'package:gestor_haras/models/medicamento_model.dart';
import 'package:gestor_haras/models/despesa_cavalo_model.dart';
import 'package:gestor_haras/services/medicamento_service.dart';

MedicamentoModel plano({
  required FrequenciaMedicamento frequencia,
  required DateTime inicio,
  DateTime? fim,
  DateTime? sincronizado,
  bool ativo = true,
}) => MedicamentoModel(
  id: 'plano-1',
  nome: 'Vermífugo',
  dose: '10 ml',
  valorCentavos: 2550,
  frequencia: frequencia,
  dataInicio: inicio,
  dataFim: fim,
  sincronizadoAte: sincronizado,
  animalIds: const ['animal-1', 'animal-2'],
  animalNomes: const {'animal-1': 'Lua', 'animal-2': 'Sol'},
  ativo: ativo,
);

void main() {
  group('recorrência de remédios', () {
    test('diária inclui a data inicial e o dia atual', () {
      final datas = plano(
        frequencia: FrequenciaMedicamento.diario,
        inicio: DateTime(2026, 8, 29),
      ).ocorrenciasPendentes(DateTime(2026, 8, 31, 23, 59));

      expect(datas, [
        DateTime(2026, 8, 29),
        DateTime(2026, 8, 30),
        DateTime(2026, 8, 31),
      ]);
    });

    test('semanal avança sete dias', () {
      final datas = plano(
        frequencia: FrequenciaMedicamento.semanal,
        inicio: DateTime(2026, 8, 1),
      ).ocorrenciasPendentes(DateTime(2026, 8, 22));

      expect(datas, [
        DateTime(2026, 8, 1),
        DateTime(2026, 8, 8),
        DateTime(2026, 8, 15),
        DateTime(2026, 8, 22),
      ]);
    });

    test('quinzenal avança quinze dias', () {
      final datas = plano(
        frequencia: FrequenciaMedicamento.quinzenal,
        inicio: DateTime(2026, 8, 1),
      ).ocorrenciasPendentes(DateTime(2026, 8, 31));

      expect(datas, [
        DateTime(2026, 8, 1),
        DateTime(2026, 8, 16),
        DateTime(2026, 8, 31),
      ]);
    });

    test('mensal mantém o dia original após mês curto', () {
      final datas = plano(
        frequencia: FrequenciaMedicamento.mensal,
        inicio: DateTime(2024, 1, 31),
      ).ocorrenciasPendentes(DateTime(2024, 4, 30));

      expect(datas, [
        DateTime(2024, 1, 31),
        DateTime(2024, 2, 29),
        DateTime(2024, 3, 31),
        DateTime(2024, 4, 30),
      ]);
    });

    test('respeita fim e não repete datas já sincronizadas', () {
      final datas = plano(
        frequencia: FrequenciaMedicamento.diario,
        inicio: DateTime(2026, 8, 1),
        fim: DateTime(2026, 8, 4),
        sincronizado: DateTime(2026, 8, 2),
      ).ocorrenciasPendentes(DateTime(2026, 8, 10));

      expect(datas, [DateTime(2026, 8, 3), DateTime(2026, 8, 4)]);
    });

    test('tratamento encerrado não produz lançamentos', () {
      final datas = plano(
        frequencia: FrequenciaMedicamento.diario,
        inicio: DateTime(2026, 8, 1),
        ativo: false,
      ).ocorrenciasPendentes(DateTime(2026, 8, 31));

      expect(datas, isEmpty);
    });
  });

  group('categorias financeiras dos tratamentos', () {
    for (final tipo in TipoTratamento.values) {
      test('${tipo.name} gera categoria e identificador próprios', () {
        final item = MedicamentoModel(
          id: 'p1',
          nome: 'Produto',
          dose: '1 dose',
          valorCentavos: 1000,
          frequencia: FrequenciaMedicamento.mensal,
          dataInicio: DateTime(2026, 8, 31),
          animalIds: const ['a1'],
          animalNomes: const {'a1': 'Lua'},
          tipo: tipo,
        );
        final despesa = dadosDespesaTratamento(item, DateTime(2026, 8, 31));

        expect(despesa['categoria'], tipo.categoriaDespesa);
        expect(despesa['descricao'], startsWith(tipo.singularCapital));
        expect(
          idDespesaTratamento(item, DateTime(2026, 8, 31)),
          '${tipo.name}_p1_20260831',
        );
      });
    }

    test('suplemento é exibido como categoria própria', () {
      expect(
        categoriaDespesaFromString('suplemento'),
        CategoriaDespesa.suplemento,
      );
      expect(CategoriaDespesa.suplemento.label, 'Suplemento');
    });

    test('ração entra nas despesas como alimento', () {
      expect(TipoTratamento.racao.singularCapital, 'Ração');
      expect(TipoTratamento.racao.categoriaDespesa, 'alimento');
      expect(categoriaDespesaFromString('alimento'), CategoriaDespesa.alimento);
    });
  });
}
