import '../models/ficha_abccmm.dart';
import '../models/genealogia_abccmm.dart';
import 'genealogia_abccmm_importacao.dart';

class ResultadoImportacaoAbccmm {
  final Map<String, String> campos;
  final GenealogiaAbccmm? genealogia;
  final Set<String> sugestoesDeParentesco;
  const ResultadoImportacaoAbccmm({
    required this.campos,
    this.genealogia,
    this.sugestoesDeParentesco = const {},
  });
}

/// Leitura conservadora de texto fornecido pelo usuário, sem acessar a ABCCMM.
class AbccmmImportacao {
  static ResultadoImportacaoAbccmm analisar(String texto) {
    final campos = ler(texto);
    final genealogia = GenealogiaAbccmmImportacao.ler(texto);
    final sugeridos = <String>{};
    for (final e in GenealogiaAbccmmImportacao.sugerirPais(
      genealogia,
    ).entries) {
      if (!campos.containsKey(e.key)) {
        campos[e.key] = e.value;
        sugeridos.add(e.key);
      }
    }
    return ResultadoImportacaoAbccmm(
      campos: campos,
      genealogia: genealogia,
      sugestoesDeParentesco: sugeridos,
    );
  }

  static const rotulos = <String, String>{
    'nome': 'Nome do cavalo',
    'raca': 'Raça',
    'sexo': 'Sexo',
    'pelagem': 'Pelagem',
    'registro': 'Registro ABCCMM',
    'pai': 'Pai',
    'mae': 'Mãe',
    ...FichaAbccmm.rotulos,
    'dataNascimento': 'Data de nascimento',
    'registrado': 'Registrado na ABCCMM',
    'vivo': 'Vivo',
    'bloqueado': 'Bloqueado',
  };

  static String _normalizar(String value) => value
      .trim()
      .toLowerCase()
      .replaceAll('ã', 'a')
      .replaceAll('á', 'a')
      .replaceAll('ç', 'c')
      .replaceAll('ê', 'e')
      .replaceAll('é', 'e')
      .replaceAll('í', 'i')
      .replaceAll('ó', 'o')
      .replaceAll('ú', 'u');

  static const _chaves = <String, String>{
    'nome': 'nome',
    'nome do animal': 'nome',
    'animal': 'nome',
    'raca': 'raca',
    'sexo': 'sexo',
    'pelagem': 'pelagem',
    'registro': 'registro',
    'registro abccmm': 'registro',
    'numero de registro': 'registro',
    'registro definitivo': 'registro',
    'pai': 'pai',
    'mae': 'mae',
    'chip': 'chip',
    'livro': 'livro',
    'id do animal na abccmm': 'idAnimal',
    'exame': 'exame',
    'criador': 'criador',
    'proprietario na abccmm': 'proprietario',
    'livro do pai': 'paiLivro',
    'registro do pai': 'paiRegistro',
    'pelagem do pai': 'paiPelagem',
    'exame do pai': 'paiExame',
    'livro da mae': 'maeLivro',
    'registro da mae': 'maeRegistro',
    'pelagem da mae': 'maePelagem',
    'exame da mae': 'maeExame',
    'nascimento': 'dataNascimento',
    'data de nascimento': 'dataNascimento',
    'data nascimento': 'dataNascimento',
    'id animal': 'idAnimal',
    'id do animal': 'idAnimal',
    'proprietario': 'proprietario',
    'prop.': 'proprietario',
    'prop': 'proprietario',
    'nasc.': 'dataNascimento',
    'nasc': 'dataNascimento',
    'registrado': 'registrado',
    'registrado na abccmm': 'registrado',
    'vivo': 'vivo',
    'bloqueado': 'bloqueado',
  };

  static String _limparMarkdown(String texto) =>
      texto.trim().replaceAll('**', '').replaceAll('__', '').trim();

  static String? _chaveDaLinha(String linha) {
    final celula = linha
        .replaceFirst(RegExp(r'^\s*\|'), '')
        .split(RegExp(r'[:\t|]'))
        .first;
    return _chaves[_normalizar(_limparMarkdown(celula))];
  }

  static List<String> _preparar(String texto) {
    final linhas = texto
        .replaceAll('\u00a0', ' ')
        .split(RegExp(r'[\r\n]+'))
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    final partes = <String>[];
    for (var i = 0; i < linhas.length; i++) {
      final linha = linhas[i];
      if (linha.contains('|')) {
        final celulas = linha
            .replaceFirst(RegExp(r'^\|'), '')
            .replaceFirst(RegExp(r'\|$'), '')
            .split('|')
            .map(_limparMarkdown)
            .toList();
        // Apenas tabelas de duas colunas: rótulo e valor de um único animal.
        if (celulas.length == 2 &&
            _chaveDaLinha(celulas.first) != null &&
            celulas.last.isNotEmpty) {
          partes.add(
            '${celulas.first.replaceFirst(RegExp(r':\s*$'), '')}: ${celulas.last}',
          );
        }
        continue;
      }
      final titulo = _limparMarkdown(
        linha.replaceFirst(RegExp(r'^(?:[-*•]\s+|#{1,6}\s+)'), ''),
      );
      // Aceita o nome em destaque ou como primeira linha de uma ficha copiada.
      // Não interpreta títulos soltos ou qualquer linha da genealogia como nome.
      if (i == 0 &&
          linhas.length > 1 &&
          !titulo.contains(RegExp(r'[:\t]')) &&
          _chaveDaLinha(titulo) == null &&
          ![
            'dados do animal',
            'ficha do animal',
            'abccmm',
            'genealogia',
          ].contains(_normalizar(titulo)) &&
          _chaveDaLinha(linhas[1]) != null) {
        partes.add('Nome: $titulo');
      } else {
        partes.addAll(
          linha.split('\t').map(_limparMarkdown).where((e) => e.isNotEmpty),
        );
      }
    }
    return partes;
  }

  static Map<String, String> ler(String texto) {
    final resultado = <String, String>{};
    // Rótulos e valores podem vir na mesma linha ou em linhas/células separadas.
    final partes = _preparar(texto);
    for (var i = 0; i < partes.length; i++) {
      final parte = partes[i];
      final colon = parte.indexOf(':');
      final label = colon < 0 ? parte : parte.substring(0, colon);
      final chave = _chaves[_normalizar(label)];
      if (chave == null) continue;
      var valor = colon < 0 ? '' : parte.substring(colon + 1).trim();
      if (valor.isEmpty && i + 1 < partes.length) {
        final seguinte = partes[i + 1];
        if (!seguinte.contains(':') &&
            !_chaves.containsKey(_normalizar(seguinte))) {
          valor = seguinte;
          i++;
        }
      }
      if (valor.isEmpty || valor == '-' || valor.length > 250) continue;
      if (chave == 'dataNascimento') {
        if (FichaAbccmm.validarNascimento(valor) != null) continue;
        valor = FichaAbccmm.formatarData(FichaAbccmm.lerData(valor));
      }
      if (chave == 'registrado' || chave == 'vivo' || chave == 'bloqueado') {
        valor = switch (_normalizar(valor)) {
          'sim' || 's' => 'Sim',
          'nao' || 'n' => 'Não',
          _ => '',
        };
      }
      if (chave == 'sexo') {
        valor = switch (_normalizar(valor)) {
          'm' || 'macho' || 'masculino' => 'Macho',
          'f' || 'femea' || 'feminino' => 'Fêmea',
          _ => '',
        };
      }
      if (valor.isNotEmpty) resultado.putIfAbsent(chave, () => valor);
    }
    return resultado;
  }
}
