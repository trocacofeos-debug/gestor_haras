import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gestor_haras/models/cavalo_model.dart';
import 'package:gestor_haras/models/ficha_abccmm.dart';
import 'package:gestor_haras/services/abccmm_importacao.dart';
import 'package:gestor_haras/widgets/importar_abccmm_dialog.dart';
import 'fixtures/abccmm_playboy.dart';

void main() {
  test('importa exatamente a tabela de PLAYBOY SG enviada pelo usuário', () {
    expect(AbccmmImportacao.ler(fichaPlayboy), {
      'nome': 'PLAYBOY SG',
      'criador': 'FREDERICO SANTOS GONÇALVES',
      'proprietario': 'FREDERICO SANTOS GONÇALVES',
      'livro': 'MM5 - DEFINITIVO FECHADO MACHO',
      'registro': '038184',
      'sexo': 'Macho',
      'dataNascimento': '01/02/2013',
      'chip': '982000196502174',
      'pelagem': 'ALAZÃ',
      'exame': 'DNA-VP',
      'vivo': 'Sim',
      'bloqueado': 'Não',
    });
  });
  test('aceita tabela copiada sem markdown, com tabulações e abreviações', () {
    expect(
      AbccmmImportacao.ler(
        'PLAYBOY SG\nProp.:\tFREDERICO\nNasc.:\t01/02/2013\nRegistro:\t038184',
      ),
      {
        'nome': 'PLAYBOY SG',
        'proprietario': 'FREDERICO',
        'dataNascimento': '01/02/2013',
        'registro': '038184',
      },
    );
  });
  test('ignora separadores, tabela vazia e títulos sem ficha', () {
    expect(AbccmmImportacao.ler('**PLAYBOY SG**'), isEmpty);
    expect(AbccmmImportacao.ler('| Pai: | |\n| --- | --- |\n| Mãe: | Lua |'), {
      'mae': 'Lua',
    });
  });
  test('nascimento valida calendário e futuro; idade é calculada', () {
    expect(FichaAbccmm.lerData('31/02/2020'), isNull);
    expect(FichaAbccmm.lerData('29/02/2021'), isNull);
    expect(FichaAbccmm.lerData('29/02/2020'), DateTime(2020, 2, 29));
    expect(FichaAbccmm.validarNascimento('01/01/9999'), isNotNull);
    expect(FichaAbccmm.validarNascimento(''), isNull);
    expect(
      FichaAbccmm(
        dataNascimento: DateTime(2020, 8, 30),
      ).idadeEm(DateTime(2026, 8, 29)),
      '5 ano(s) e 11 mês(es)',
    );
  });
  test(
    'ficha persiste nascimento sem fuso e situações independentes do ativo',
    () {
      final animal = CavaloModel(
        id: '1',
        ativo: true,
        fichaAbccmm: FichaAbccmm(
          dataNascimento: DateTime(2020, 2, 29),
          chip: '000123',
          registrado: false,
          vivo: false,
          bloqueado: false,
        ),
      );
      final lido = CavaloModel.fromMap(animal.toMap(), '1');
      expect(lido.fichaAbccmm.dataNascimento, DateTime(2020, 2, 29));
      expect(lido.fichaAbccmm.chip, '000123');
      expect(lido.fichaAbccmm.registrado, false);
      expect(lido.fichaAbccmm.vivo, false);
      expect(lido.fichaAbccmm.bloqueado, false);
      expect(CavaloModel.fromMap({}, 'antigo').fichaAbccmm.bloqueado, isNull);
      expect(lido.ativo, true);
      expect(CavaloModel.fromMap({}, 'antigo').fichaAbccmm.vivo, isNull);
    },
  );
  test('importação reconhece ficha ampliada e ignora data inválida', () {
    expect(
      AbccmmImportacao.ler(
        'Nascimento: 2020-02-29\nChip: 000123\nLivro: MM-6\nRegistrado: Sim\nVivo: Não\nRegistro do pai: 00456\nLivro da mãe: MM-5\nCriador: Haras',
      ),
      {
        'dataNascimento': '29/02/2020',
        'chip': '000123',
        'livro': 'MM-6',
        'registrado': 'Sim',
        'vivo': 'Não',
        'paiRegistro': '00456',
        'maeLivro': 'MM-5',
        'criador': 'Haras',
      },
    );
    expect(
      AbccmmImportacao.ler('Nascimento: 31/02/2020\nVivo: desconhecido'),
      isEmpty,
    );
  });
  test('reconhece proprietário da associação sem criar vínculo com cliente', () {
    expect(
      AbccmmImportacao.ler(
        'Nome: Estrela\nSexo: Fêmea\nPelagem: Castanha\nRegistro: 00123\nPai: Trovão\nMãe: Lua\nProprietário: Ana',
      ),
      {
        'nome': 'Estrela',
        'sexo': 'Fêmea',
        'pelagem': 'Castanha',
        'registro': '00123',
        'pai': 'Trovão',
        'mae': 'Lua',
        'proprietario': 'Ana',
      },
    );
  });
  test('aceita células e linhas separadas sem consumir outro campo', () {
    expect(
      AbccmmImportacao.ler(
        'Nome do animal\tEstrela\nRaça:\nMangalarga Marchador\nPai:\nMãe: Lua',
      ),
      {'nome': 'Estrela', 'raca': 'Mangalarga Marchador', 'mae': 'Lua'},
    );
  });
  test('não adivinha dados sem rótulo, sexo desconhecido ou campo ausente', () {
    expect(
      AbccmmImportacao.ler('Estrela\n123456\nSexo: desconhecido\nPai: -'),
      isEmpty,
    );
  });
  test(
    'campos opcionais preservam cadastros antigos e persistem novos dados',
    () {
      expect(CavaloModel.fromMap({}, 'antigo').registroAbccmm, '');
      const cavalo = CavaloModel(
        id: 'novo',
        registroAbccmm: '00123',
        pai: 'Trovão',
        mae: 'Lua',
      );
      final recuperado = CavaloModel.fromMap(cavalo.toMap(), cavalo.id);
      expect(recuperado.registroAbccmm, '00123');
      expect(recuperado.pai, 'Trovão');
      expect(recuperado.mae, 'Lua');
    },
  );
  for (final tamanho in [const Size(800, 600), const Size(390, 844)]) {
    testWidgets(
      'revisão protege valores atuais e só retorna campos selecionados em $tamanho',
      (tester) async {
        tester.view.physicalSize = tamanho;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        ResultadoImportacaoAbccmm? retorno;
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) => Scaffold(
                body: TextButton(
                  onPressed: () async {
                    retorno = await showDialog<ResultadoImportacaoAbccmm>(
                      context: context,
                      builder: (_) => const ImportarAbccmmDialog(
                        atuais: {'nome': 'Original', 'sexo': 'Macho'},
                      ),
                    );
                  },
                  child: const Text('Abrir'),
                ),
              ),
            ),
          ),
        );
        await tester.tap(find.text('Abrir'));
        await tester.pumpAndSettle();
        await tester.enterText(
          find.byType(TextField),
          'Nome: Novo\nSexo: Fêmea\nPelagem: Castanha',
        );
        await tester.ensureVisible(find.text('Reconhecer campos'));
        await tester.tap(find.text('Reconhecer campos'));
        await tester.pumpAndSettle();
        final caixas = tester
            .widgetList<CheckboxListTile>(find.byType(CheckboxListTile))
            .toList();
        expect(caixas.map((e) => e.value), [false, false, true]);
        await tester.tap(find.text('Preencher cadastro'));
        await tester.pumpAndSettle();
        expect(retorno?.campos, {'pelagem': 'Castanha'});
        expect(tester.takeException(), isNull);
      },
    );
  }
}
