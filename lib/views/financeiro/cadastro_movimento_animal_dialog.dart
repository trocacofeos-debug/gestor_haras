import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../models/despesa_cavalo_model.dart';
import '../../models/financeiro_animais.dart';
import '../../widgets/app_dialogs.dart';

class CadastroMovimentoAnimalDialog extends StatefulWidget {
  const CadastroMovimentoAnimalDialog({
    super.key,
    required this.animais,
    this.animalInicial,
  });

  final Map<String, String> animais;
  final String? animalInicial;

  @override
  State<CadastroMovimentoAnimalDialog> createState() =>
      _CadastroMovimentoAnimalDialogState();
}

class _CadastroMovimentoAnimalDialogState
    extends State<CadastroMovimentoAnimalDialog> {
  final _formKey = GlobalKey<FormState>();
  final _descricao = TextEditingController();
  final _valor = TextEditingController();
  TipoMovimentoAnimal _tipo = TipoMovimentoAnimal.despesa;
  CategoriaDespesa _categoriaDespesa = CategoriaDespesa.outro;
  CategoriaReceitaAnimal _categoriaReceita = CategoriaReceitaAnimal.hospedagem;
  late String? _animalId;
  DateTime _data = DateTime.now();

  @override
  void initState() {
    super.initState();
    _animalId = widget.animais.containsKey(widget.animalInicial)
        ? widget.animalInicial
        : null;
  }

  @override
  void dispose() {
    _descricao.dispose();
    _valor.dispose();
    super.dispose();
  }

  int? _lerCentavos(String texto) {
    var valor = texto.replaceAll(RegExp(r'[^0-9,.]'), '');
    if (valor.contains(',')) {
      valor = valor.replaceAll('.', '').replaceAll(',', '.');
    }
    final numero = double.tryParse(valor);
    if (numero == null || !numero.isFinite || numero <= 0) return null;
    return (numero * 100).round();
  }

  Future<void> _selecionarData() async {
    final selecionada = await showAppDatePicker(
      context: context,
      initialDate: _data,
      firstDate: DateTime(2000),
      lastDate: DateTime(DateTime.now().year + 10, 12, 31),
    );
    if (selecionada != null && mounted) setState(() => _data = selecionada);
  }

  void _salvar() {
    if (!_formKey.currentState!.validate()) return;
    final centavos = _lerCentavos(_valor.text)!;
    Navigator.pop(
      context,
      NovoMovimentoAnimal(
        animalId: _animalId!,
        tipo: _tipo,
        descricao: _descricao.text.trim(),
        categoria: _tipo == TipoMovimentoAnimal.despesa
            ? _categoriaDespesa.name
            : _categoriaReceita.name,
        centavos: centavos,
        data: _data,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final animais = widget.animais.entries.toList()
      ..sort((a, b) => a.value.toLowerCase().compareTo(b.value.toLowerCase()));
    return AlertDialog(
      title: const Text('Novo lançamento'),
      content: SizedBox(
        width: 520,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SegmentedButton<TipoMovimentoAnimal>(
                  segments: const [
                    ButtonSegment(
                      value: TipoMovimentoAnimal.receita,
                      icon: Icon(Icons.south_west_rounded),
                      label: Text('Receita'),
                    ),
                    ButtonSegment(
                      value: TipoMovimentoAnimal.despesa,
                      icon: Icon(Icons.north_east_rounded),
                      label: Text('Despesa'),
                    ),
                  ],
                  selected: {_tipo},
                  onSelectionChanged: (tipos) => setState(() {
                    _tipo = tipos.first;
                  }),
                ),
                const SizedBox(height: 18),
                DropdownButtonFormField<String>(
                  key: const ValueKey('novo-lancamento-animal'),
                  initialValue: _animalId,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Animal *',
                    prefixIcon: Icon(Icons.pets_outlined),
                  ),
                  items: [
                    for (final animal in animais)
                      DropdownMenuItem(
                        value: animal.key,
                        child: Text(
                          animal.value,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                  onChanged: (valor) => setState(() => _animalId = valor),
                  validator: (valor) => valor == null
                      ? 'Selecione o animal deste lançamento'
                      : null,
                ),
                const SizedBox(height: 14),
                if (_tipo == TipoMovimentoAnimal.despesa)
                  DropdownButtonFormField<CategoriaDespesa>(
                    key: const ValueKey('categoria-despesa'),
                    initialValue: _categoriaDespesa,
                    decoration: const InputDecoration(labelText: 'Categoria'),
                    items: [
                      for (final categoria in CategoriaDespesa.values)
                        DropdownMenuItem(
                          value: categoria,
                          child: Text(categoria.label),
                        ),
                    ],
                    onChanged: (valor) => setState(
                      () => _categoriaDespesa = valor ?? CategoriaDespesa.outro,
                    ),
                  )
                else
                  DropdownButtonFormField<CategoriaReceitaAnimal>(
                    key: const ValueKey('categoria-receita'),
                    initialValue: _categoriaReceita,
                    decoration: const InputDecoration(labelText: 'Categoria'),
                    items: [
                      for (final categoria in CategoriaReceitaAnimal.values)
                        DropdownMenuItem(
                          value: categoria,
                          child: Text(categoria.label),
                        ),
                    ],
                    onChanged: (valor) => setState(
                      () => _categoriaReceita =
                          valor ?? CategoriaReceitaAnimal.outro,
                    ),
                  ),
                const SizedBox(height: 14),
                TextFormField(
                  key: const ValueKey('novo-lancamento-descricao'),
                  controller: _descricao,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    labelText: 'Descrição *',
                    hintText: 'Ex.: consulta veterinária ou hospedagem',
                    prefixIcon: Icon(Icons.notes_rounded),
                  ),
                  validator: (valor) => valor == null || valor.trim().isEmpty
                      ? 'Informe uma descrição'
                      : null,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  key: const ValueKey('novo-lancamento-valor'),
                  controller: _valor,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9,.]')),
                  ],
                  decoration: const InputDecoration(
                    labelText: 'Valor *',
                    prefixText: 'R\$ ',
                  ),
                  validator: (valor) => _lerCentavos(valor ?? '') == null
                      ? 'Informe um valor maior que zero'
                      : null,
                ),
                const SizedBox(height: 14),
                OutlinedButton.icon(
                  key: const ValueKey('novo-lancamento-data'),
                  onPressed: _selecionarData,
                  icon: const Icon(Icons.calendar_month_outlined),
                  label: Text(
                    'Data: ${DateFormat('dd/MM/yyyy').format(_data)}',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton.icon(
          key: const ValueKey('salvar-novo-lancamento'),
          onPressed: _salvar,
          icon: const Icon(Icons.save_outlined),
          label: const Text('Salvar lançamento'),
        ),
      ],
    );
  }
}
