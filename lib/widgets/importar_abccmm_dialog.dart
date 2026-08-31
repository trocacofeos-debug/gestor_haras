import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../services/abccmm_importacao.dart';
import 'genealogia_abccmm_view.dart';

class ImportarAbccmmDialog extends StatefulWidget {
  final Map<String, String> atuais;
  final bool temGenealogia;
  const ImportarAbccmmDialog({
    super.key,
    required this.atuais,
    this.temGenealogia = false,
  });

  @override
  State<ImportarAbccmmDialog> createState() => _ImportarAbccmmDialogState();
}

class _ImportarAbccmmDialogState extends State<ImportarAbccmmDialog> {
  final _texto = TextEditingController();
  final _inicioResultado = GlobalKey();
  Map<String, String>? _dados;
  ResultadoImportacaoAbccmm? _resultado;
  bool _incluirGenealogia = false;
  final _selecionados = <String>{};
  String? _erro;

  @override
  void dispose() {
    _texto.dispose();
    super.dispose();
  }

  Future<void> _abrir() async {
    try {
      if (await launchUrl(
        Uri.parse('https://abccmm.org.br/animais'),
        mode: LaunchMode.externalApplication,
      )) {
        return;
      }
    } catch (_) {
      // O texto da URL permanece disponível para copiar manualmente.
    }
    if (mounted) {
      setState(
        () => _erro =
            'Não foi possível abrir o site. Copie o endereço abaixo e abra no navegador.',
      );
    }
  }

  void _analisar() {
    final resultado = AbccmmImportacao.analisar(_texto.text);
    final dados = resultado.campos;
    setState(() {
      _resultado = resultado;
      _incluirGenealogia = false;
      _erro = dados.isEmpty && resultado.genealogia == null
          ? 'Nenhum campo reconhecido. Cole os nomes e as linhas Reg.: da genealogia, ou os rótulos e valores da ficha.'
          : null;
      _dados = dados.isEmpty && resultado.genealogia == null ? null : dados;
      _selecionados.clear();
      // Campos já preenchidos exigem seleção explícita para substituir.
      _selecionados.addAll(
        dados.keys.where(
          (k) =>
              (widget.atuais[k] ?? '').isEmpty &&
              !resultado.sugestoesDeParentesco.contains(k),
        ),
      );
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final contexto = _inicioResultado.currentContext;
      if (mounted && contexto != null) {
        Scrollable.ensureVisible(
          contexto,
          duration: const Duration(milliseconds: 200),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Importar dados da ABCCMM'),
    content: SizedBox(
      width: 560,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              '1. Consulte o animal no site e resolva o CAPTCHA, se solicitado.\n2. Copie os dados com seus rótulos e cole abaixo.\n3. Confira os campos antes de preencher o cadastro.',
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _abrir,
              icon: const Icon(Icons.open_in_new),
              label: const Text('Abrir consulta oficial'),
            ),
            const SelectableText('https://abccmm.org.br/animais'),
            const SizedBox(height: 12),
            const Text(
              'Cole a ficha, a genealogia ou ambas. Aceita a tabela em Markdown e o texto copiado da tabela exibida. Se a cópia perder as colunas, os ancestrais serão listados sem atribuir parentesco. O proprietário do haras não será alterado.',
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _texto,
              minLines: 4,
              maxLines: 8,
              maxLength: 20000,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Texto copiado da consulta',
                hintText: 'Nome: Estrela\nSexo: Fêmea\nPelagem: Castanha',
              ),
              onChanged: (_) => setState(() {
                _dados = null;
                _resultado = null;
                _incluirGenealogia = false;
                _selecionados.clear();
                _erro = null;
              }),
            ),
            TextButton(
              onPressed: _analisar,
              child: const Text('Reconhecer campos'),
            ),
            if (_erro != null)
              Text(
                _erro!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            if (_dados != null) ...[
              Text(
                key: _inicioResultado,
                _resultado!.genealogia == null
                    ? '${_dados!.length} campos reconhecidos'
                    : '${_resultado!.genealogia!.ancestrais.length} ancestrais reconhecidos',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
              if (_resultado!.genealogia != null)
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Importar genealogia revisada'),
                  subtitle: Text(
                    widget.temGenealogia
                        ? 'Substituirá a genealogia atual inteira. Confira antes de selecionar.'
                        : 'Marque para levar estes ancestrais ao cadastro, mesmo sem selecionar pai e mãe.',
                  ),
                  value: _incluirGenealogia,
                  onChanged: (value) =>
                      setState(() => _incluirGenealogia = value == true),
                ),
              const Text(
                'Selecione o que deseja preencher. Campos existentes ficam desmarcados para evitar substituições acidentais. Você pode corrigir os valores no cadastro antes de salvar.',
              ),
              if (_resultado!.sugestoesDeParentesco.isNotEmpty)
                const Text(
                  'Pai e mãe abaixo são sugestões pela ordem da primeira coluna. Ficam desmarcados: selecione somente após confirmar o parentesco. A genealogia pode ser importada sem preencher esses campos.',
                ),
              for (final entrada in _dados!.entries)
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    '${AbccmmImportacao.rotulos[entrada.key]}: ${entrada.value}',
                  ),
                  subtitle: (widget.atuais[entrada.key] ?? '').isEmpty
                      ? null
                      : Text('Atual: ${widget.atuais[entrada.key]}'),
                  value: _selecionados.contains(entrada.key),
                  onChanged: (value) => setState(() {
                    if (value == true) {
                      _selecionados.add(entrada.key);
                    } else {
                      _selecionados.remove(entrada.key);
                    }
                  }),
                ),
              if (_resultado!.genealogia != null) ...[
                GenealogiaAbccmmView(genealogia: _resultado!.genealogia!),
              ],
            ],
          ],
        ),
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancelar'),
      ),
      FilledButton(
        onPressed:
            _dados == null || (_selecionados.isEmpty && !_incluirGenealogia)
            ? null
            : () => Navigator.pop(
                context,
                ResultadoImportacaoAbccmm(
                  campos: {for (final k in _selecionados) k: _dados![k]!},
                  genealogia: _incluirGenealogia
                      ? _resultado!.genealogia
                      : null,
                ),
              ),
        child: const Text('Preencher cadastro'),
      ),
    ],
  );
}
