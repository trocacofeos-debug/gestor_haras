// ignore_for_file: deprecated_member_use

import 'dart:ui' as ui;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../../widgets/app_dialogs.dart';

import '../../models/cavalo_model.dart';
import '../../models/ficha_abccmm.dart';
import '../../models/genealogia_abccmm.dart';
import '../../services/abccmm_importacao.dart';
import '../../widgets/genealogia_abccmm_view.dart';
import '../../models/cliente_model.dart';
import '../../services/cloudflare_r2_service.dart';
import '../../widgets/campos_grid.dart';
import '../../widgets/desktop_window.dart';
import '../../widgets/importar_abccmm_dialog.dart';
import '../home/admin_top_bar.dart';

class CadastroCavaloPage extends StatefulWidget {
  final CavaloModel? cavaloParaEditar;
  final CloudflareR2Service? uploadService;

  const CadastroCavaloPage({
    super.key,
    this.cavaloParaEditar,
    this.uploadService,
  });

  @override
  State<CadastroCavaloPage> createState() => _CadastroCavaloPageState();
}

class _CadastroCavaloPageState extends State<CadastroCavaloPage> {
  final _formKey = GlobalKey<FormState>();

  final nomeController = TextEditingController();
  final racaController = TextEditingController();
  final pelagemController = TextEditingController();
  final registroController = TextEditingController();
  final paiController = TextEditingController();
  final maeController = TextEditingController();
  final nascimentoController = TextEditingController();
  final _fichaControllers = {
    for (final chave in FichaAbccmm.rotulos.keys)
      chave: TextEditingController(),
  };
  bool? _registrado;
  bool? _vivo;
  bool? _bloqueado;
  GenealogiaAbccmm? _genealogia;
  final alturaController = TextEditingController();
  final pesoController = TextEditingController();
  final observacoesController = TextEditingController();

  String sexo = 'Macho';

  String? proprietarioId;
  String? proprietarioNome;

  bool salvando = false;
  bool _selecionandoFoto = false;
  bool _enviandoFoto = false;
  PlatformFile? _fotoSelecionada;
  String? _fotoEnviadaUrl;
  late final _uploadService = widget.uploadService ?? CloudflareR2Service();

  bool get _ocupado => salvando || _selecionandoFoto;

  bool get editando => widget.cavaloParaEditar != null;

  static const Color primaria = Color(0xFF374151);
  static const Color fundo = Colors.white;

  @override
  void initState() {
    super.initState();

    final c = widget.cavaloParaEditar;

    if (c != null) {
      nomeController.text = c.nome;
      racaController.text = c.raca;
      pelagemController.text = c.pelagem;
      registroController.text = c.registroAbccmm;
      paiController.text = c.pai;
      maeController.text = c.mae;
      nascimentoController.text = FichaAbccmm.formatarData(
        c.fichaAbccmm.dataNascimento,
      );
      final ficha = c.fichaAbccmm.toMap();
      for (final e in _fichaControllers.entries) {
        e.value.text = ficha[e.key] as String;
      }
      _registrado = c.fichaAbccmm.registrado;
      _vivo = c.fichaAbccmm.vivo;
      _bloqueado = c.fichaAbccmm.bloqueado;
      _genealogia = c.genealogiaAbccmm;
      alturaController.text = _formatarMedida(c.altura);
      pesoController.text = _formatarMedida(c.peso);
      observacoesController.text = c.observacoes;
      sexo = c.sexo.isEmpty ? 'Macho' : c.sexo;
      proprietarioId = c.proprietarioId.isEmpty ? null : c.proprietarioId;
      proprietarioNome = c.proprietarioNome.isEmpty ? null : c.proprietarioNome;
    }
  }

  @override
  void dispose() {
    nomeController.dispose();
    racaController.dispose();
    pelagemController.dispose();
    registroController.dispose();
    paiController.dispose();
    maeController.dispose();
    nascimentoController.dispose();
    for (final controller in _fichaControllers.values) {
      controller.dispose();
    }
    alturaController.dispose();
    pesoController.dispose();
    observacoesController.dispose();
    super.dispose();
  }

  Future<void> selecionarProprietario() async {
    final resultado = await showAppDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => const _SelecionarClienteDialog(),
    );

    if (mounted && resultado != null) {
      setState(() {
        proprietarioId = resultado['id'] as String?;
        proprietarioNome = resultado['nome'] as String?;
      });
    }
  }

  Future<void> _importarAbccmm() async {
    if (_ocupado) return;
    final controllers = <String, TextEditingController>{
      'nome': nomeController,
      'raca': racaController,
      'pelagem': pelagemController,
      'registro': registroController,
      'pai': paiController,
      'mae': maeController,
      'dataNascimento': nascimentoController,
      ..._fichaControllers,
    };
    final resultado = await showAppDialog<ResultadoImportacaoAbccmm>(
      context: context,
      builder: (_) => ImportarAbccmmDialog(
        temGenealogia: _genealogia != null,
        atuais: {
          for (final e in controllers.entries) e.key: e.value.text.trim(),
          'sexo': sexo,
          'registrado': _registrado == null
              ? ''
              : (_registrado! ? 'Sim' : 'Não'),
          'vivo': _vivo == null ? '' : (_vivo! ? 'Sim' : 'Não'),
          'bloqueado': _bloqueado == null ? '' : (_bloqueado! ? 'Sim' : 'Não'),
        },
      ),
    );
    if (!mounted || resultado == null) return;
    setState(() {
      if (resultado.genealogia != null) _genealogia = resultado.genealogia;
      for (final e in resultado.campos.entries) {
        if (e.key == 'sexo') {
          sexo = e.value;
        } else if (e.key == 'registrado') {
          _registrado = e.value == 'Sim';
        } else if (e.key == 'vivo') {
          _vivo = e.value == 'Sim';
        } else if (e.key == 'bloqueado') {
          _bloqueado = e.value == 'Sim';
        } else {
          controllers[e.key]?.text = e.value;
        }
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Dados preenchidos. Revise e clique em Salvar para concluir o cadastro.',
        ),
      ),
    );
  }

  Future<void> salvar() async {
    if (_ocupado) return;
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      salvando = true;
    });

    try {
      final fotos = List<String>.from(widget.cavaloParaEditar?.fotos ?? []);
      if (_fotoSelecionada != null) {
        if (_fotoEnviadaUrl == null) {
          setState(() => _enviandoFoto = true);
          final url = await _uploadService.uploadArquivo(
            arquivo: _fotoSelecionada!,
            pasta: 'cavalos',
          );
          if (url.trim().isEmpty) {
            throw Exception('O envio da foto não retornou uma URL.');
          }
          _fotoEnviadaUrl = url;
        }
        if (!mounted) return;
        setState(() => _enviandoFoto = false);
        if (fotos.isEmpty) {
          fotos.add(_fotoEnviadaUrl!);
        } else {
          fotos[0] = _fotoEnviadaUrl!;
        }
      }
      final cavalo = CavaloModel(
        id: widget.cavaloParaEditar?.id ?? '',
        nome: nomeController.text.trim(),
        raca: racaController.text.trim(),
        sexo: sexo,
        pelagem: pelagemController.text.trim(),
        registroAbccmm: registroController.text.trim(),
        pai: paiController.text.trim(),
        mae: maeController.text.trim(),
        genealogiaAbccmm: _genealogia,
        fichaAbccmm: FichaAbccmm.fromMap({
          for (final e in _fichaControllers.entries) e.key: e.value.text.trim(),
          'dataNascimento': nascimentoController.text.trim(),
          'registrado': _registrado,
          'vivo': _vivo,
          'bloqueado': _bloqueado,
        }),
        altura: _lerMedida(alturaController.text),
        peso: _lerMedida(pesoController.text),
        proprietarioId: proprietarioId ?? '',
        proprietarioNome: proprietarioNome ?? '',
        ativo: widget.cavaloParaEditar?.ativo ?? true,
        preco: widget.cavaloParaEditar?.preco ?? 0,
        fotos: fotos,
        observacoes: observacoesController.text.trim(),
        dataCadastro: widget.cavaloParaEditar?.dataCadastro ?? Timestamp.now(),
      );

      if (editando) {
        await FirebaseFirestore.instance
            .collection('cavalos')
            .doc(cavalo.id)
            .update(cavalo.toMap());
      } else {
        await FirebaseFirestore.instance
            .collection('cavalos')
            .add(cavalo.toMap());
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            editando
                ? 'Cavalo atualizado com sucesso'
                : 'Cavalo cadastrado com sucesso',
          ),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro: $e')));
    } finally {
      if (mounted) {
        setState(() {
          salvando = false;
          _enviandoFoto = false;
        });
      }
    }
  }

  Future<void> _selecionarFoto() async {
    if (_ocupado) return;
    setState(() => _selecionandoFoto = true);
    try {
      final resultado = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png'],
        allowMultiple: false,
        withData: true,
      );
      if (!mounted || resultado == null || resultado.files.isEmpty) return;
      final arquivo = resultado.files.single;
      final bytes = arquivo.bytes;
      if (!['jpg', 'jpeg', 'png'].contains(arquivo.extension?.toLowerCase()) ||
          bytes == null ||
          bytes.isEmpty) {
        throw Exception('Selecione uma imagem JPG ou PNG válida.');
      }
      if (bytes.length > 10 * 1024 * 1024) {
        throw Exception('A foto deve ter até 10 MB.');
      }
      // Validate the image before replacing the preview or uploading it.
      final codec = await ui.instantiateImageCodec(bytes, targetWidth: 512);
      try {
        final frame = await codec.getNextFrame();
        frame.image.dispose();
      } finally {
        codec.dispose();
      }
      if (!mounted) return;
      setState(() {
        _fotoSelecionada = arquivo;
        _fotoEnviadaUrl = null;
      });
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Não foi possível abrir a foto. Use uma imagem JPG ou PNG de até 10 MB.',
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _selecionandoFoto = false);
    }
  }

  Widget _foto() {
    final fotos = widget.cavaloParaEditar?.fotos ?? const <String>[];
    final temFoto = _fotoSelecionada != null || fotos.isNotEmpty;
    const placeholder = ColoredBox(
      color: Color(0xFFF3F4F6),
      child: Center(
        child: Icon(
          Icons.add_photo_alternate_outlined,
          color: Color(0xFF9CA3AF),
        ),
      ),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Foto do cavalo',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: SizedBox(
                width: 96,
                height: 96,
                child: _fotoSelecionada != null
                    ? Image.memory(
                        _fotoSelecionada!.bytes!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => placeholder,
                      )
                    : fotos.isEmpty
                    ? placeholder
                    : Image.network(
                        fotos.first,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => placeholder,
                      ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextButton(
                    onPressed: _ocupado ? null : _selecionarFoto,
                    style: TextButton.styleFrom(foregroundColor: primaria),
                    child: Text(
                      _selecionandoFoto
                          ? 'Abrindo...'
                          : temFoto
                          ? 'Trocar foto'
                          : 'Adicionar foto',
                    ),
                  ),
                  if (_fotoSelecionada != null)
                    TextButton(
                      onPressed: _ocupado
                          ? null
                          : () => setState(() {
                              _fotoSelecionada = null;
                              _fotoEnviadaUrl = null;
                            }),
                      child: const Text('Desfazer seleção'),
                    )
                  else
                    const Text(
                      'JPG ou PNG · até 10 MB',
                      style: TextStyle(fontSize: 11, color: Color(0xFF6B7280)),
                    ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _complementos() => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [_foto(), const SizedBox(height: 16), _observacoes()],
  );

  InputDecoration _decoracao(String label) {
    return InputDecoration(
      labelText: label,
      isDense: true,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      labelStyle: const TextStyle(color: Color(0xFF6B7280), fontSize: 13),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(4)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: const BorderSide(color: primaria),
      ),
    );
  }

  Widget campo({
    required String label,
    required TextEditingController controller,
    bool required = true,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        enabled: !salvando,
        style: const TextStyle(fontSize: 14),
        validator: required
            ? (value) => value == null || value.trim().isEmpty
                  ? 'Campo obrigatório'
                  : null
            : null,
        decoration: _decoracao(label),
      ),
    );
  }

  String _formatarMedida(double? valor) => valor == null
      ? ''
      : valor.toString().replaceFirst(RegExp(r'\.0$'), '').replaceAll('.', ',');

  double? _lerMedida(String texto) =>
      double.tryParse(texto.trim().replaceAll(',', '.'));

  Widget _campoMedida(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        enabled: !salvando,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        style: const TextStyle(fontSize: 14),
        decoration: _decoracao(label),
        validator: (texto) {
          final entrada = texto?.trim() ?? '';
          if (entrada.isEmpty) return null;
          final valor = _lerMedida(entrada);
          if (!RegExp(r'^\d+(?:[.,]\d+)?$').hasMatch(entrada) ||
              valor == null ||
              !valor.isFinite ||
              valor <= 0) {
            return 'Informe um número maior que zero';
          }
          return null;
        },
      ),
    );
  }

  Widget _dados() {
    final idade = FichaAbccmm(
      dataNascimento: FichaAbccmm.lerData(nascimentoController.text),
    ).idadeEm(DateTime.now());
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Dados do animal',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: _ocupado ? null : _importarAbccmm,
            icon: const Icon(Icons.content_paste_search),
            label: const Text('Importar dados da ABCCMM'),
          ),
        ),
        const SizedBox(height: 12),
        CamposGrid(
          maximoColunas: 2,
          larguraMinimaColuna: 220,
          campos: [
            campo(label: 'Nome do cavalo', controller: nomeController),
            campo(label: 'Raça', controller: racaController, required: false),
            campo(
              label: 'Pelagem',
              controller: pelagemController,
              required: false,
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: DropdownButtonFormField<String>(
                value: sexo,
                isExpanded: true,
                decoration: _decoracao('Sexo'),
                style: const TextStyle(fontSize: 14, color: Color(0xFF111827)),
                items: const [
                  DropdownMenuItem(value: 'Macho', child: Text('Macho')),
                  DropdownMenuItem(value: 'Fêmea', child: Text('Fêmea')),
                ],
                onChanged: salvando
                    ? null
                    : (value) => setState(() => sexo = value ?? 'Macho'),
              ),
            ),
          ],
        ),
        CamposGrid(
          maximoColunas: 2,
          larguraMinimaColuna: 220,
          campos: [
            _campoMedida('Altura (m)', alturaController),
            _campoMedida('Peso (kg)', pesoController),
          ],
        ),
        _secaoFicha('Identificação e registro'),
        CamposGrid(
          maximoColunas: 2,
          larguraMinimaColuna: 220,
          campos: [
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: TextFormField(
                controller: nascimentoController,
                enabled: !salvando,
                keyboardType: TextInputType.datetime,
                decoration: _decoracao(
                  'Data de nascimento',
                ).copyWith(hintText: 'DD/MM/AAAA'),
                validator: (value) =>
                    FichaAbccmm.validarNascimento(value ?? ''),
                onChanged: (_) => setState(() {}),
              ),
            ),
            InputDecorator(
              decoration: _decoracao('Idade (calculada)'),
              child: Text(idade.isEmpty ? '—' : idade),
            ),
            _campoFicha('idAnimal'),
            _campoFicha('chip'),
            _campoFicha('livro'),
            campo(
              label: 'Registro ABCCMM',
              controller: registroController,
              required: false,
            ),
            _campoFicha('exame'),
            _campoSituacao(
              'Registrado na ABCCMM',
              _registrado,
              (value) => setState(() => _registrado = value),
            ),
            _campoSituacao(
              'Vivo',
              _vivo,
              (value) => setState(() => _vivo = value),
            ),
            _campoSituacao(
              'Bloqueado',
              _bloqueado,
              (value) => setState(() => _bloqueado = value),
            ),
          ],
        ),
        _secaoFicha('Filiação'),
        CamposGrid(
          maximoColunas: 2,
          larguraMinimaColuna: 220,
          campos: [
            campo(label: 'Pai', controller: paiController, required: false),
            campo(label: 'Mãe', controller: maeController, required: false),
            _campoFicha('paiLivro'),
            _campoFicha('maeLivro'),
            _campoFicha('paiRegistro'),
            _campoFicha('maeRegistro'),
            _campoFicha('paiPelagem'),
            _campoFicha('maePelagem'),
            _campoFicha('paiExame'),
            _campoFicha('maeExame'),
          ],
        ),
        if (_genealogia != null)
          ExpansionTile(
            title: Text(
              'Genealogia importada (${_genealogia!.ancestrais.length} entradas)',
            ),
            subtitle: const Text(
              'Posições da tabela de origem; independentes dos campos de pai e mãe acima.',
            ),
            children: [GenealogiaAbccmmView(genealogia: _genealogia!)],
          ),
        _secaoFicha('Criador e proprietário na associação'),
        CamposGrid(
          maximoColunas: 2,
          larguraMinimaColuna: 220,
          campos: [_campoFicha('criador'), _campoFicha('proprietario')],
        ),
        const Text(
          'Os dados da associação são informativos. O proprietário vinculado ao haras é selecionado separadamente abaixo.',
          style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
        ),
        const SizedBox(height: 4),
        const Text(
          'Proprietário',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Material(
          color: Colors.white,
          child: InkWell(
            onTap: salvando ? null : selecionarProprietario,
            borderRadius: BorderRadius.circular(4),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      proprietarioNome ?? 'Selecionar proprietário (opcional)',
                      style: const TextStyle(fontSize: 14, color: primaria),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.search, size: 20, color: primaria),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _secaoFicha(String titulo) => Padding(
    padding: const EdgeInsets.only(top: 16, bottom: 12),
    child: Text(
      titulo,
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
    ),
  );

  Widget _campoFicha(String chave) => campo(
    label: FichaAbccmm.rotulos[chave]!,
    controller: _fichaControllers[chave]!,
    required: false,
  );

  Widget _campoSituacao(
    String label,
    bool? valor,
    ValueChanged<bool?> onChanged,
  ) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: DropdownButtonFormField<String>(
      value: valor == null ? '' : (valor ? 'sim' : 'nao'),
      decoration: _decoracao(label),
      isExpanded: true,
      items: const [
        DropdownMenuItem(value: '', child: Text('Não informado')),
        DropdownMenuItem(value: 'sim', child: Text('Sim')),
        DropdownMenuItem(value: 'nao', child: Text('Não')),
      ],
      onChanged: salvando
          ? null
          : (value) => onChanged(value == '' ? null : value == 'sim'),
    ),
  );

  Widget _observacoes() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Observações',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: observacoesController,
          enabled: !salvando,
          minLines: 5,
          maxLines: 5,
          keyboardType: TextInputType.multiline,
          style: const TextStyle(fontSize: 14),
          decoration: _decoracao('Notas sobre o animal'),
        ),
      ],
    );
  }

  Widget _acoes() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
      ),
      child: Wrap(
        alignment: WrapAlignment.end,
        spacing: 12,
        runSpacing: 8,
        children: [
          TextButton(
            onPressed: _ocupado ? null : () => Navigator.maybePop(context),
            style: TextButton.styleFrom(foregroundColor: primaria),
            child: const Text('Cancelar'),
          ),
          FilledButton.icon(
            onPressed: _ocupado ? null : salvar,
            style: FilledButton.styleFrom(
              backgroundColor: primaria,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            icon: salvando
                ? const SizedBox.square(
                    dimension: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.save_outlined, size: 18),
            label: Text(
              _enviandoFoto
                  ? 'Enviando foto...'
                  : editando
                  ? 'Salvar alterações'
                  : 'Cadastrar cavalo',
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: fundo,
      bottomNavigationBar: SafeArea(top: false, child: _acoes()),
      body: SafeArea(
        child: Column(
          children: [
            if (MediaQuery.sizeOf(context).width >= 1000) const AdminTopBar(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
              ),
              child: Row(
                children: [
                  IconButton(
                    tooltip: DesktopWindowScope.isInside(context)
                        ? 'Fechar'
                        : 'Voltar',
                    onPressed: _ocupado
                        ? null
                        : () => Navigator.maybePop(context),
                    icon: Icon(
                      DesktopWindowScope.isInside(context)
                          ? Icons.close
                          : Icons.arrow_back,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      editando ? 'Editar cavalo' : 'Novo cavalo',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Form(
                key: _formKey,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints.maxWidth < 900) {
                      return SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            _dados(),
                            const SizedBox(height: 20),
                            _complementos(),
                          ],
                        ),
                      );
                    }
                    return SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 2, child: _dados()),
                          const SizedBox(width: 24),
                          Expanded(child: _complementos()),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =====================================================
// SELECIONAR CLIENTE (proprietário)
// =====================================================

class _SelecionarClienteDialog extends StatefulWidget {
  const _SelecionarClienteDialog();

  @override
  State<_SelecionarClienteDialog> createState() =>
      _SelecionarClienteDialogState();
}

class _SelecionarClienteDialogState extends State<_SelecionarClienteDialog> {
  String busca = '';

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        height: 550,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              decoration: const InputDecoration(
                hintText: 'Buscar cliente...',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                setState(() {
                  busca = value.toLowerCase();
                });
              },
            ),
            const SizedBox(height: 12),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('clientes')
                    .orderBy('nome')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final docs = snapshot.data!.docs.where((doc) {
                    final cliente = ClienteModel.fromMap(
                      doc.data() as Map<String, dynamic>,
                      doc.id,
                    );

                    return cliente.nomeExibicao.toLowerCase().contains(busca);
                  }).toList();

                  if (docs.isEmpty) {
                    return const Center(
                      child: Text('Nenhum cliente encontrado'),
                    );
                  }

                  return ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final cliente = ClienteModel.fromMap(
                        docs[index].data() as Map<String, dynamic>,
                        docs[index].id,
                      );

                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: const CircleAvatar(
                            child: Icon(Icons.person),
                          ),
                          title: Text(cliente.nomeExibicao),
                          trailing: const Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                          ),
                          onTap: () {
                            Navigator.pop(context, {
                              'id': cliente.id,
                              'nome': cliente.nomeExibicao,
                            });
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

