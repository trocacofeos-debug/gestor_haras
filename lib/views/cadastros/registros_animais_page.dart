import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../models/cavalo_model.dart';
import '../../models/registro_animal_model.dart';
import '../../services/registro_animal_service.dart';
import '../../widgets/app_dialogs.dart';
import '../../widgets/desktop_window.dart';

class RegistrosAnimaisPage extends StatefulWidget {
  const RegistrosAnimaisPage({
    super.key,
    required this.tipo,
    this.repository,
    this.embedded = false,
  });

  final TipoRegistroAnimal tipo;
  final RegistroAnimalRepository? repository;
  final bool embedded;

  @override
  State<RegistrosAnimaisPage> createState() => _RegistrosAnimaisPageState();
}

class _RegistrosAnimaisPageState extends State<RegistrosAnimaisPage> {
  late final RegistroAnimalRepository repository =
      widget.repository ?? RegistroAnimalService();
  final data = DateFormat('dd/MM/yyyy');

  Future<void> _novo() async {
    await openDesktopWindow<bool>(
      context,
      title: 'Novo ${widget.tipo.nomeRegistro}',
      icon: _icone(widget.tipo),
      width: 760,
      height: 700,
      builder: (_) =>
          CadastroRegistroAnimalPage(tipo: widget.tipo, repository: repository),
    );
  }

  Future<void> _excluir(RegistroAnimalModel item) async {
    final confirmar = await showAppDialog<bool>(
      context: context,
      title: 'Excluir registro',
      builder: (dialogContext) => AlertDialog(
        title: const Text('Excluir este registro?'),
        content: const Text('Esta ação remove o registro do histórico.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    if (confirmar == true) await repository.excluir(item.id);
  }

  @override
  Widget build(BuildContext context) {
    final desktop = MediaQuery.sizeOf(context).width >= 900;
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: widget.embedded ? null : AppBar(title: Text(widget.tipo.titulo)),
      floatingActionButton: !desktop
          ? FloatingActionButton.extended(
              onPressed: _novo,
              icon: const Icon(Icons.add),
              label: const Text('Novo registro'),
            )
          : null,
      body: Padding(
        padding: EdgeInsets.all(widget.embedded ? 12 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!widget.embedded || desktop)
              Row(
                children: [
                  if (!widget.embedded) ...[
                    Icon(_icone(widget.tipo), color: const Color(0xFF4F46E5)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.tipo.titulo,
                        style: const TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ] else
                    const Spacer(),
                  if (desktop)
                    FilledButton.icon(
                      onPressed: _novo,
                      icon: const Icon(Icons.add),
                      label: const Text('Novo registro'),
                    ),
                ],
              ),
            SizedBox(height: widget.embedded ? 6 : 12),
            Expanded(
              child: StreamBuilder<List<RegistroAnimalModel>>(
                stream: repository.observar(widget.tipo),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text('Erro: ${snapshot.error}'));
                  }
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final itens = snapshot.data!;
                  if (itens.isEmpty) {
                    return Center(
                      child: Text(
                        'Nenhum ${widget.tipo.nomeRegistro} cadastrado.',
                      ),
                    );
                  }
                  return ListView.separated(
                    itemCount: itens.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 5),
                    itemBuilder: (_, index) {
                      final item = itens[index];
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(10, 8, 4, 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                radius: 18,
                                child: Icon(_icone(item.tipo), size: 19),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.tipo ==
                                                  TipoRegistroAnimal.controle ||
                                              item.titulo.isEmpty
                                          ? item.animalNome
                                          : item.titulo,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      _resumo(item),
                                      style: const TextStyle(
                                        color: Color(0xFF64748B),
                                        fontSize: 13,
                                        height: 1.25,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                visualDensity: VisualDensity.compact,
                                tooltip: 'Excluir',
                                onPressed: () => _excluir(item),
                                icon: const Icon(Icons.delete_outline),
                              ),
                            ],
                          ),
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

  String _resumo(RegistroAnimalModel item) {
    final medidas = <String>[
      if (item.alturaMetros != null) '${item.alturaMetros} m',
      if (item.pesoKg != null) '${item.pesoKg} kg',
    ];
    final filiacao = <String>[
      if (item.pai.isNotEmpty) 'Pai: ${item.pai}',
      if (item.mae.isNotEmpty) 'Mãe: ${item.mae}',
    ];
    return '${item.animalNome} • Controle: ${data.format(item.data)}'
        '${item.dataNascimento == null ? '' : '\nNascimento: ${data.format(item.dataNascimento!)}'}'
        '${medidas.isEmpty ? '' : '\n${medidas.join(' • ')}'}'
        '${filiacao.isEmpty ? '' : '\n${filiacao.join(' • ')}'}'
        '${item.tipo == TipoRegistroAnimal.controle || item.status.isEmpty ? '' : '\n${item.status}'}';
  }

  IconData _icone(TipoRegistroAnimal tipo) => switch (tipo) {
    TipoRegistroAnimal.controle => Icons.monitor_weight_outlined,
    TipoRegistroAnimal.treinamento => Icons.fitness_center_outlined,
    TipoRegistroAnimal.reproducao => Icons.favorite_outline,
  };
}

class CadastroRegistroAnimalPage extends StatefulWidget {
  const CadastroRegistroAnimalPage({
    super.key,
    required this.tipo,
    required this.repository,
  });

  final TipoRegistroAnimal tipo;
  final RegistroAnimalRepository repository;

  @override
  State<CadastroRegistroAnimalPage> createState() =>
      _CadastroRegistroAnimalPageState();
}

class _CadastroRegistroAnimalPageState
    extends State<CadastroRegistroAnimalPage> {
  final formKey = GlobalKey<FormState>();
  final titulo = TextEditingController();
  final status = TextEditingController();
  final observacoes = TextEditingController();
  final altura = TextEditingController();
  final peso = TextEditingController();
  final pai = TextEditingController();
  final mae = TextEditingController();
  late final Future<List<CavaloModel>> animais = widget.repository
      .listarAnimais();
  String animalId = '';
  DateTime data = DateTime.now();
  bool salvando = false;

  CavaloModel? _animalSelecionado(List<CavaloModel> lista) {
    for (final animal in lista) {
      if (animal.id == animalId) return animal;
    }
    return null;
  }

  void _selecionarAnimal(String? id, List<CavaloModel> lista) {
    CavaloModel? selecionado;
    if (id != null) {
      for (final animal in lista) {
        if (animal.id == id) {
          selecionado = animal;
          break;
        }
      }
    }
    setState(() {
      animalId = id ?? '';
      pai.text = selecionado?.pai ?? '';
      mae.text = selecionado?.mae ?? '';
      if (widget.tipo == TipoRegistroAnimal.controle) {
        altura.text =
            selecionado?.altura?.toString().replaceAll('.', ',') ?? '';
        peso.text = selecionado?.peso?.toString().replaceAll('.', ',') ?? '';
      }
    });
  }

  double? _numero(String valor) {
    var texto = valor.trim();
    if (texto.contains(',')) {
      texto = texto.replaceAll('.', '').replaceAll(',', '.');
    }
    return double.tryParse(texto);
  }

  Future<void> _salvar(List<CavaloModel> lista) async {
    if (!(formKey.currentState?.validate() ?? false)) return;
    if (animalId.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Selecione um animal.')));
      return;
    }
    if (widget.tipo == TipoRegistroAnimal.controle &&
        titulo.text.trim().isEmpty &&
        altura.text.trim().isEmpty &&
        peso.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Informe a altura, o peso ou a descrição do controle.'),
        ),
      );
      return;
    }
    final animal = lista.firstWhere((item) => item.id == animalId);
    setState(() => salvando = true);
    try {
      await widget.repository.salvar(
        RegistroAnimalModel(
          id: '',
          tipo: widget.tipo,
          animalId: animal.id,
          animalNome: animal.nome,
          data: data,
          titulo: titulo.text,
          status: status.text,
          observacoes: observacoes.text,
          pai: pai.text,
          mae: mae.text,
          dataNascimento: animal.fichaAbccmm.dataNascimento,
          alturaMetros: altura.text.trim().isEmpty
              ? null
              : _numero(altura.text),
          pesoKg: peso.text.trim().isEmpty ? null : _numero(peso.text),
        ),
      );
      if (mounted) Navigator.pop(context, true);
    } catch (erro) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar o registro: $erro')),
        );
      }
    } finally {
      if (mounted) setState(() => salvando = false);
    }
  }

  @override
  void dispose() {
    titulo.dispose();
    status.dispose();
    observacoes.dispose();
    altura.dispose();
    peso.dispose();
    pai.dispose();
    mae.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFFF3F4F6),
    appBar: DesktopWindowScope.isInside(context)
        ? null
        : AppBar(title: Text('Novo ${widget.tipo.nomeRegistro}')),
    body: FutureBuilder<List<CavaloModel>>(
      future: animais,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text('Erro ao carregar animais: ${snapshot.error}'),
          );
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final lista = snapshot.data!;
        final selecionado = _animalSelecionado(lista);
        return Form(
          key: formKey,
          child: ListView(
            padding: const EdgeInsets.all(14),
            children: [
              DropdownButtonFormField<String>(
                key: const ValueKey('registro-animal'),
                decoration: const InputDecoration(
                  labelText: 'Animal *',
                  border: OutlineInputBorder(),
                ),
                items: lista
                    .map(
                      (item) => DropdownMenuItem(
                        value: item.id,
                        child: Text(item.nome),
                      ),
                    )
                    .toList(),
                onChanged: (value) => _selecionarAnimal(value, lista),
              ),
              if (widget.tipo == TipoRegistroAnimal.controle &&
                  selecionado != null) ...[
                const SizedBox(height: 10),
                _dadosCadastro(selecionado),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        key: const ValueKey('registro-pai'),
                        controller: pai,
                        decoration: const InputDecoration(
                          labelText: 'Pai',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextFormField(
                        key: const ValueKey('registro-mae'),
                        controller: mae,
                        decoration: const InputDecoration(
                          labelText: 'Mãe',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              if (widget.tipo != TipoRegistroAnimal.controle) ...[
                const SizedBox(height: 10),
                TextFormField(
                  controller: titulo,
                  decoration: InputDecoration(
                    labelText: switch (widget.tipo) {
                      TipoRegistroAnimal.treinamento =>
                        'Treinamento / atividade *',
                      TipoRegistroAnimal.reproducao =>
                        'Procedimento / evento *',
                      TipoRegistroAnimal.controle => '',
                    },
                    border: const OutlineInputBorder(),
                  ),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Informe a descrição do registro'
                      : null,
                ),
              ],
              if (widget.tipo == TipoRegistroAnimal.controle) ...[
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(child: _numeroCampo(altura, 'Altura (m)')),
                    const SizedBox(width: 8),
                    Expanded(child: _numeroCampo(peso, 'Peso (kg)')),
                  ],
                ),
              ],
              if (widget.tipo != TipoRegistroAnimal.controle) ...[
                const SizedBox(height: 10),
                TextFormField(
                  controller: status,
                  decoration: const InputDecoration(
                    labelText: 'Status / resultado',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
              const SizedBox(height: 10),
              ListTile(
                key: const ValueKey('registro-data'),
                tileColor: Colors.white,
                leading: const Icon(Icons.event_outlined),
                title: const Text('Data da medição / controle'),
                subtitle: Text(DateFormat('dd/MM/yyyy').format(data)),
                onTap: () async {
                  final escolhida = await showAppDatePicker(
                    context: context,
                    initialDate: data,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (escolhida != null) setState(() => data = escolhida);
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: observacoes,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Observações',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 14),
              FilledButton.icon(
                key: const ValueKey('salvar-registro-animal'),
                onPressed: salvando ? null : () => _salvar(lista),
                icon: const Icon(Icons.save_outlined),
                label: const Text('Salvar registro'),
              ),
            ],
          ),
        );
      },
    ),
  );

  Widget _numeroCampo(TextEditingController controller, String label) =>
      TextFormField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'[0-9,.]')),
        ],
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) return null;
          final numero = _numero(value);
          return numero == null || numero <= 0 ? 'Valor inválido' : null;
        },
      );

  Widget _dadosCadastro(CavaloModel animal) {
    final nascimento = animal.fichaAbccmm.dataNascimento;
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFEEF2FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFC7D2FE)),
      ),
      child: Row(
        children: [
          const Icon(Icons.pets_outlined, color: Color(0xFF4338CA)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  animal.nome,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  nascimento == null
                      ? 'Data de nascimento não informada no cadastro'
                      : 'Nascimento: ${DateFormat('dd/MM/yyyy').format(nascimento)}',
                ),
                const Text(
                  'Dados carregados do cadastro do animal',
                  style: TextStyle(color: Color(0xFF64748B), fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
