import '../models/genealogia_abccmm.dart';

class GenealogiaAbccmmImportacao {
  static String _limpar(String value) => value
      .replaceAll(r'\*', '*')
      .replaceAll('**', '')
      .replaceAll('\u00a0', ' ')
      .trim();
  static String _informado(String value) {
    final limpo = _limpar(value);
    return RegExp(r'^[*\s-]*$').hasMatch(limpo) ? '' : limpo;
  }

  static GenealogiaAbccmm? ler(String texto) {
    final normalizado = _normalizarTabelaCopiada(texto);
    return _lerTabela(normalizado) ?? _lerSemColunas(texto);
  }

  /// Texto simples da área de transferência pode conter células com várias
  /// linhas, com ou sem as aspas usadas por planilhas.
  static String _normalizarTabelaCopiada(String texto) {
    if (!texto.contains('\t')) return texto;
    final linhas = <List<String>>[];
    var linha = <String>[];
    var celula = '';
    var aspas = false;
    final entrada = texto.replaceAll('\r\n', '\n').replaceAll('\r', '\n');
    for (var i = 0; i < entrada.length; i++) {
      final c = entrada[i];
      if (c == '"' && (aspas || celula.isEmpty)) {
        if (aspas && i + 1 < entrada.length && entrada[i + 1] == '"') {
          celula += '"';
          i++;
        } else {
          aspas = !aspas;
        }
      } else if (c == '\t' && !aspas) {
        linha.add(celula);
        celula = '';
      } else if (c == '\n' && !aspas) {
        final proxima = entrada
            .substring(i + 1)
            .split(RegExp(r'[\n\t]'))
            .first
            .trim();
        final continua =
            celula.trim().isNotEmpty &&
            !celula.contains(RegExp(r'Reg\s*\.', caseSensitive: false)) &&
            !celula.contains('|') &&
            (RegExp(r'^Reg\s*\.:', caseSensitive: false).hasMatch(proxima) ||
                RegExp(r'^[*\\\s]+\|').hasMatch(proxima));
        if (continua) {
          celula += '\n';
        } else {
          linha.add(celula);
          linhas.add(linha);
          linha = [];
          celula = '';
        }
      } else {
        celula += c;
      }
    }
    linha.add(celula);
    linhas.add(linha);
    return linhas
        .map((row) {
          if (row.length != 3) return row.join('\t');
          return '| ${row.map((cell) => cell.replaceAll(r'\|', '|').replaceAll('|', r'\|').replaceAll('\n', '<br>')).join(' | ')} |';
        })
        .join('\n');
  }

  static GenealogiaAbccmm? _lerTabela(String texto) {
    final itens = <AncestralAbccmm>[];
    var linha = 0;
    var tabelaIniciada = false;
    var formatoInvalido = false;
    for (final raw in texto.split(RegExp(r'[\r\n]+'))) {
      final textoLinha = raw.trim();
      if (!textoLinha.startsWith('|')) continue;
      final celulas = textoLinha
          .replaceFirst(RegExp(r'^\|'), '')
          .replaceFirst(RegExp(r'\|$'), '')
          .split(RegExp(r'(?<!\\)\|'))
          .map((e) => e.replaceAll(r'\|', '|').trim())
          .toList();
      // A ficha comum tem duas colunas. A genealogia fornecida tem três.
      if (celulas.length == 2 && !tabelaIniciada) continue;
      if (celulas.every((e) => RegExp(r'^:?-{3,}:?$').hasMatch(e))) continue;
      final temAncestral = celulas.any(
        (e) => RegExp(r'<br\s*/?>', caseSensitive: false).hasMatch(e),
      );
      if (!tabelaIniciada && !temAncestral) continue;
      tabelaIniciada = true;
      if (celulas.length != 3) {
        formatoInvalido = true;
        continue;
      }
      for (var coluna = 0; coluna < 3; coluna++) {
        final celula = celulas[coluna].replaceAll('\u00a0', ' ').trim();
        if (celula.isEmpty) continue;
        final partes = celula.split(RegExp(r'<br\s*/?>', caseSensitive: false));
        if (partes.length != 2) {
          formatoInvalido = true;
          continue;
        }
        final nome = _informado(partes.first);
        final detalhes = partes.last.split('|');
        if (detalhes.length < 3 || detalhes.length > 4) {
          formatoInvalido = true;
          continue;
        }
        final registro = _informado(
          detalhes.first.replaceFirst(
            RegExp(r'^\s*Reg\.:\s*', caseSensitive: false),
            '',
          ),
        );
        final exame = _informado(detalhes[1]);
        final livros = detalhes
            .skip(2)
            .map(_informado)
            .where((e) => e.isNotEmpty)
            .toList();
        itens.add(
          AncestralAbccmm(
            linha: linha,
            coluna: coluna,
            nome: nome,
            registro: registro,
            exame: exame,
            livros: livros,
          ),
        );
      }
      linha++;
    }
    if (itens.isEmpty) return null;
    final avisos = <String>[];
    if (formatoInvalido) {
      avisos.add(
        'Há células fora do formato esperado. Confira a cópia original; essas células não foram importadas.',
      );
    }
    final pais = itens.where((e) => e.coluna == 0).toList();
    if (pais.length != 2) {
      avisos.add(
        'A primeira coluna não contém exatamente dois ancestrais. Pai e mãe não serão sugeridos.',
      );
    } else {
      for (var p = 0; p < pais.length; p++) {
        final inicio = pais[p].linha;
        final fim = p + 1 < pais.length ? pais[p + 1].linha : linha;
        for (var c = 1; c < 3; c++) {
          final quantidade = itens
              .where((e) => e.coluna == c && e.linha >= inicio && e.linha < fim)
              .length;
          if (quantidade != (c == 1 ? 2 : 4)) {
            avisos.add(
              'Ramo de ${pais[p].nome.isEmpty ? "ancestral desconhecido" : pais[p].nome}: coluna ${c + 1} contém $quantidade entradas. O parentesco não foi deduzido; confira as posições.',
            );
          }
        }
      }
    }
    return GenealogiaAbccmm(ancestrais: itens, avisos: avisos);
  }

  static Map<String, String> sugerirPais(GenealogiaAbccmm? genealogia) {
    if (genealogia == null || !genealogia.posicoesPreservadas) return {};
    final pais = genealogia.ancestrais.where((e) => e.coluna == 0).toList();
    if (pais.length != 2) return {};
    final campos = <String, String>{};
    for (var i = 0; i < pais.length; i++) {
      final ancestral = pais[i];
      if (ancestral.desconhecido) continue;
      final prefixo = i == 0 ? 'pai' : 'mae';
      campos[prefixo] = ancestral.nome;
      if (ancestral.registro.isNotEmpty) {
        campos['${prefixo}Registro'] = ancestral.registro;
      }
      if (ancestral.exame.isNotEmpty) {
        campos['${prefixo}Exame'] = ancestral.exame;
      }
      if (ancestral.livros.isNotEmpty) {
        campos['${prefixo}Livro'] = ancestral.livros.join(' | ');
      }
    }
    return campos;
  }

  static GenealogiaAbccmm? _lerSemColunas(String texto) {
    // Sem células não há informação suficiente para ligar os parentes.
    // Importamos somente pares nome/registro, sem atribuir pai ou mãe.
    final linhas = texto
        .replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n')
        .replaceAll(r'\|', '|')
        .split(RegExp(r'[\r\n\t]+'))
        .map(_limpar)
        .where((e) => e.isNotEmpty)
        .toList();
    final itens = <AncestralAbccmm>[];
    for (var i = 0; i + 1 < linhas.length; i++) {
      final nome = linhas[i].replaceFirst(RegExp(r'^[-•]\s+'), '');
      final dados = linhas[i + 1];
      if (nome.contains('|') ||
          nome.contains(':') ||
          nome.toLowerCase() == 'genealogia') {
        continue;
      }
      final detalhes = dados.split('|');
      if (detalhes.length < 3 || detalhes.length > 4) continue;
      if (!RegExp(r'^Reg\s*\.:', caseSensitive: false).hasMatch(dados) &&
          !(_informado(nome).isEmpty && _informado(detalhes.first).isEmpty)) {
        continue;
      }
      itens.add(
        AncestralAbccmm(
          linha: itens.length,
          coluna: -1,
          nome: _informado(nome),
          registro: _informado(
            detalhes.first.replaceFirst(
              RegExp(r'^Reg\s*\.:\s*', caseSensitive: false),
              '',
            ),
          ),
          exame: _informado(detalhes[1]),
          livros: detalhes
              .skip(2)
              .map(_informado)
              .where((e) => e.isNotEmpty)
              .toList(),
        ),
      );
      i++;
    }
    if (itens.isEmpty) return null;
    return GenealogiaAbccmm(
      ancestrais: itens,
      posicoesPreservadas: false,
      avisos: const [
        'A cópia não preservou as colunas. Os ancestrais foram reconhecidos como uma lista, sem atribuir parentesco. Confira se todas as entradas da origem estão presentes.',
      ],
    );
  }
}
