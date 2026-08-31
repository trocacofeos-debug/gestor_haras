import 'dart:ui' as ui;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../../models/funcionario_model.dart';
import '../../services/cloudflare_r2_service.dart';
import '../../services/funcionario_cadastro_formatos.dart';
import '../../widgets/campos_grid.dart';
import '../../widgets/desktop_window.dart';
import '../../widgets/funcionario_foto.dart';

class CadastroFuncionarioPage extends StatefulWidget {
  final FuncionarioModel? funcionarioParaEditar;
  final CloudflareR2Service? uploadService;
  const CadastroFuncionarioPage({
    super.key,
    this.funcionarioParaEditar,
    this.uploadService,
  });
  @override
  State<CadastroFuncionarioPage> createState() =>
      _CadastroFuncionarioPageState();
}

class _CadastroFuncionarioPageState extends State<CadastroFuncionarioPage> {
  final _formKey = GlobalKey<FormState>();
  final _campos = {
    for (final k in [
      'nome',
      'cargo',
      'cpf',
      'telefone',
      'email',
      'salario',
      'observacoes',
      'dataAdmissao',
      'dataNascimento',
      'dataDesligamento',
      ...FuncionarioModel.camposAdicionais.keys,
    ])
      k: TextEditingController(),
  };
  bool _salvando = false;
  bool _selecionando = false;
  bool _ativo = true;
  PlatformFile? _foto;
  String? _fotoEnviada;
  late final _upload = widget.uploadService ?? CloudflareR2Service();
  bool get _ocupado => _salvando || _selecionando;
  bool get _editando => widget.funcionarioParaEditar != null;
  static const _borda = Color(0xFFE5E7EB);
  static const _primaria = Color(0xFF4F46E5);

  @override
  void initState() {
    super.initState();
    final funcionario = widget.funcionarioParaEditar;
    if (funcionario != null) {
      final dados = funcionario.toMap();
      for (final e in _campos.entries) {
        if (dados[e.key] is String) e.value.text = dados[e.key] as String;
      }
      _campos['salario']!.text = FuncionarioCadastroFormatos.salario(
        funcionario.salario,
      );
      _campos['dataAdmissao']!.text = FuncionarioCadastroFormatos.data(
        funcionario.dataAdmissao,
      );
      _campos['dataNascimento']!.text = FuncionarioCadastroFormatos.data(
        funcionario.dataNascimento,
      );
      _campos['dataDesligamento']!.text = FuncionarioCadastroFormatos.data(
        funcionario.dataDesligamento,
      );
      _ativo = funcionario.ativo;
    } else {
      _campos['dataAdmissao']!.text = FuncionarioCadastroFormatos.data(
        Timestamp.now(),
      );
    }
  }

  @override
  void dispose() {
    for (final c in _campos.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _mensagem(String texto) => ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(texto)));

  Future<void> _selecionarFoto() async {
    if (_ocupado) return;
    setState(() => _selecionando = true);
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
      if (bytes == null ||
          bytes.isEmpty ||
          bytes.length > 10 * 1024 * 1024 ||
          !['jpg', 'jpeg', 'png'].contains(arquivo.extension?.toLowerCase())) {
        throw const FormatException('Foto inválida');
      }
      final codec = await ui.instantiateImageCodec(bytes, targetWidth: 512);
      try {
        final frame = await codec.getNextFrame();
        frame.image.dispose();
      } finally {
        codec.dispose();
      }
      if (mounted) {
        setState(() {
          _foto = arquivo;
          _fotoEnviada = null;
        });
      }
    } catch (_) {
      if (mounted) {
        _mensagem(
          'Não foi possível abrir a foto. Use JPG ou PNG de até 10 MB.',
        );
      }
    } finally {
      if (mounted) setState(() => _selecionando = false);
    }
  }

  Future<void> _salvar() async {
    if (_ocupado || !_formKey.currentState!.validate()) return;
    setState(() => _salvando = true);
    try {
      var fotoUrl = widget.funcionarioParaEditar?.fotoUrl ?? '';
      if (_foto != null) {
        _fotoEnviada ??= await _upload.uploadArquivo(
          arquivo: _foto!,
          pasta: 'funcionarios',
        );
        if (_fotoEnviada!.trim().isEmpty) {
          _fotoEnviada = null;
          throw Exception('O envio da foto não retornou uma URL.');
        }
        fotoUrl = _fotoEnviada!;
      }
      if (!mounted) return;
      final dados = <String, dynamic>{
        for (final e in _campos.entries) e.key: e.value.text.trim(),
        'salario': FuncionarioCadastroFormatos.lerSalario(
          _campos['salario']!.text,
        )!,
        'dataAdmissao': FuncionarioCadastroFormatos.timestamp(
          _campos['dataAdmissao']!.text,
        ),
        'dataNascimento': FuncionarioCadastroFormatos.timestamp(
          _campos['dataNascimento']!.text,
        ),
        'dataDesligamento': FuncionarioCadastroFormatos.timestamp(
          _campos['dataDesligamento']!.text,
        ),
        'ativo': _ativo,
        'fotoUrl': fotoUrl,
        'dataCadastro':
            widget.funcionarioParaEditar?.dataCadastro ?? Timestamp.now(),
      };
      final funcionario = FuncionarioModel.fromMap(
        dados,
        widget.funcionarioParaEditar?.id ?? '',
      );
      final collection = FirebaseFirestore.instance.collection('funcionarios');
      if (_editando) {
        await collection.doc(funcionario.id).update(funcionario.toMap());
      } else {
        await collection.add(funcionario.toMap());
      }
      if (!mounted) return;
      setState(() => _salvando = false);
      _mensagem(
        _editando
            ? 'Funcionário atualizado com sucesso'
            : 'Funcionário cadastrado com sucesso',
      );
      Navigator.pop(context);
    } catch (_) {
      if (mounted) {
        _mensagem(
          'Não foi possível salvar o funcionário. Confira a conexão e tente novamente. Os dados foram mantidos.',
        );
      }
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  InputDecoration _decoracao(String label) => InputDecoration(
    labelText: label,
    filled: true,
    fillColor: Colors.white,
    isDense: true,
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(6),
      borderSide: const BorderSide(color: _borda),
    ),
  );

  Widget _campo(
    String chave, {
    String? label,
    bool obrigatorio = false,
    TextInputType? tipo,
    int linhas = 1,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: TextFormField(
      controller: _campos[chave],
      enabled: !_ocupado,
      keyboardType: tipo,
      minLines: linhas,
      maxLines: linhas,
      decoration: _decoracao(
        label ?? FuncionarioModel.camposAdicionais[chave]!,
      ),
      validator: (value) {
        final texto = value?.trim() ?? '';
        if (obrigatorio && texto.isEmpty) return 'Campo obrigatório';
        if (texto.isEmpty) return null;
        if (chave == 'salario') {
          final valor = FuncionarioCadastroFormatos.lerSalario(texto);
          if (valor == null || !valor.isFinite || valor < 0) {
            return 'Informe um salário válido, como 1.500,00';
          }
        }
        if (chave == 'email' &&
            !RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(texto)) {
          return 'Informe um email válido';
        }
        if (chave == 'cpf' &&
            texto.replaceAll(RegExp(r'\D'), '').length != 11) {
          return 'Informe os 11 dígitos do CPF';
        }
        if (['ctpsUf', 'estado'].contains(chave) &&
            !RegExp(r'^[a-zA-Z]{2}$').hasMatch(texto)) {
          return 'Use a sigla com 2 letras';
        }
        return null;
      },
    ),
  );

  Widget _data(String chave, String label) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: TextFormField(
      controller: _campos[chave],
      enabled: !_ocupado,
      keyboardType: TextInputType.datetime,
      decoration: _decoracao(label).copyWith(hintText: 'DD/MM/AAAA'),
      validator: (value) {
        if (value == null || value.trim().isEmpty) return null;
        final data = FuncionarioCadastroFormatos.lerData(value);
        if (data == null) return 'Informe uma data válida (DD/MM/AAAA)';
        if (chave == 'dataNascimento' && data.isAfter(DateTime.now())) {
          return 'Nascimento não pode estar no futuro';
        }
        final admissao = FuncionarioCadastroFormatos.lerData(
          _campos['dataAdmissao']!.text,
        );
        if (chave == 'dataDesligamento' &&
            admissao != null &&
            data.isBefore(admissao)) {
          return 'Desligamento anterior à admissão';
        }
        return null;
      },
    ),
  );

  Widget _secao(String titulo, List<Widget> campos) => Container(
    margin: const EdgeInsets.only(bottom: 16),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(color: _borda),
      borderRadius: BorderRadius.circular(6),
    ),
    child: Material(
      color: Colors.transparent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            titulo,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          CamposGrid(
            maximoColunas: 2,
            larguraMinimaColuna: 250,
            campos: campos,
          ),
        ],
      ),
    ),
  );

  Widget _fotoWidget() => _secao('Foto do funcionário', [
    Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_foto != null)
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Image.memory(
              _foto!.bytes!,
              width: 96,
              height: 96,
              fit: BoxFit.cover,
            ),
          )
        else
          FuncionarioFoto(
            url: widget.funcionarioParaEditar?.fotoUrl ?? '',
            tamanho: 96,
          ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextButton(
                onPressed: _ocupado ? null : _selecionarFoto,
                child: Text(_selecionando ? 'Abrindo...' : 'Selecionar foto'),
              ),
              const Text(
                'JPG ou PNG · até 10 MB',
                style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
              ),
              if (_foto != null)
                TextButton(
                  onPressed: _ocupado
                      ? null
                      : () => setState(() {
                          _foto = null;
                          _fotoEnviada = null;
                        }),
                  child: const Text('Desfazer seleção'),
                ),
            ],
          ),
        ),
      ],
    ),
  ]);

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !_ocupado,
    child: Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF111827),
        title: Text(_editando ? 'Editar funcionário' : 'Novo funcionário'),
        leading: IconButton(
          tooltip: DesktopWindowScope.isInside(context) ? 'Fechar' : 'Voltar',
          onPressed: _ocupado ? null : () => Navigator.maybePop(context),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          color: Colors.white,
          child: Wrap(
            alignment: WrapAlignment.end,
            spacing: 12,
            runSpacing: 8,
            children: [
              TextButton(
                onPressed: _ocupado ? null : () => Navigator.maybePop(context),
                child: const Text('Cancelar'),
              ),
              FilledButton.icon(
                onPressed: _ocupado ? null : _salvar,
                style: FilledButton.styleFrom(backgroundColor: _primaria),
                icon: _salvando
                    ? const SizedBox.square(
                        dimension: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.save_outlined, size: 18),
                label: Text(_salvando ? 'Salvando...' : 'Salvar funcionário'),
              ),
            ],
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(bottom: 16),
                    child: Text(
                      'Nome e cargo são obrigatórios. Os demais campos são opcionais.',
                    ),
                  ),
                  _fotoWidget(),
                  _secao('Dados pessoais e contato', [
                    _campo('nome', label: 'Nome completo', obrigatorio: true),
                    _campo('cpf', label: 'CPF', tipo: TextInputType.number),
                    _data('dataNascimento', 'Data de nascimento'),
                    _campo(
                      'telefone',
                      label: 'Telefone / WhatsApp',
                      tipo: TextInputType.phone,
                    ),
                    _campo(
                      'email',
                      label: 'Email',
                      tipo: TextInputType.emailAddress,
                    ),
                  ]),
                  _secao('Vínculo com o haras', [
                    _campo('cargo', label: 'Cargo', obrigatorio: true),
                    _campo('matricula'),
                    _campo('tipoVinculo'),
                    _campo('jornada'),
                    _campo(
                      'salario',
                      label: 'Salário (R\$)',
                      tipo: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                    ),
                    _data('dataAdmissao', 'Data de admissão'),
                    _data('dataDesligamento', 'Data de desligamento'),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Funcionário ativo'),
                      value: _ativo,
                      onChanged: _ocupado
                          ? null
                          : (v) => setState(() => _ativo = v),
                    ),
                  ]),
                  _secao('Carteira de trabalho e identificação profissional', [
                    _campo('ctpsNumero'),
                    _campo('ctpsSerie'),
                    _campo('ctpsUf'),
                    _campo('pisPasep'),
                  ]),
                  _secao('Endereço', [
                    for (final k in [
                      'cep',
                      'endereco',
                      'numero',
                      'complemento',
                      'bairro',
                      'cidade',
                      'estado',
                    ])
                      _campo(k),
                  ]),
                  _secao('Contato de emergência', [
                    _campo('emergenciaNome'),
                    _campo('emergenciaTelefone', tipo: TextInputType.phone),
                    _campo('emergenciaParentesco'),
                  ]),
                  _secao('Observações', [
                    _campo('observacoes', label: 'Observações', linhas: 4),
                  ]),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
