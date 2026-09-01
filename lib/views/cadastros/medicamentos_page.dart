// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../models/cavalo_model.dart';
import '../../models/medicamento_model.dart';
import '../../services/medicamento_service.dart';
import '../../widgets/app_dialogs.dart';
import '../../widgets/desktop_window.dart';
import '../home/admin_top_bar.dart';

class MedicamentosPage extends StatefulWidget {
  const MedicamentosPage({
    super.key,
    this.repository,
    this.tipo = TipoTratamento.remedio,
  });
  final MedicamentoRepository? repository;
  final TipoTratamento tipo;

  String get titulo => tipo.pluralCapital;
  IconData get icone => switch (tipo) {
    TipoTratamento.remedio => Icons.medication_rounded,
    TipoTratamento.vacina => Icons.vaccines_rounded,
    TipoTratamento.suplemento => Icons.grass_rounded,
  };

  @override
  State<MedicamentosPage> createState() => _MedicamentosPageState();
}

class _MedicamentosPageState extends State<MedicamentosPage> {
  late final MedicamentoRepository repository =
      widget.repository ?? MedicamentoService(tipo: widget.tipo);
  bool sincronizando = false;
  final moeda = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
  final data = DateFormat('dd/MM/yyyy');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _sincronizar());
  }

  Future<void> _sincronizar() async {
    if (sincronizando) return;
    setState(() => sincronizando = true);
    try {
      final total = await repository.sincronizarTudo();
      if (mounted && total > 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '$total despesa(s) de ${widget.tipo.singular} atualizada(s).',
            ),
          ),
        );
      }
    } catch (erro) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Não foi possível atualizar as despesas: $erro'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => sincronizando = false);
    }
  }

  Future<void> _novo() async {
    await openDesktopWindow<bool>(
      context,
      title: 'Novo ${widget.tipo.singular}',
      icon: widget.icone,
      width: 1000,
      height: 760,
      builder: (_) =>
          CadastroMedicamentoPage(repository: repository, tipo: widget.tipo),
    );
  }

  Future<void> _encerrar(MedicamentoModel item) async {
    final confirmar = await showAppDialog<bool>(
      context: context,
      title: 'Encerrar tratamento',
      builder: (dialogContext) => AlertDialog(
        title: const Text('Encerrar tratamento?'),
        content: Text(
          'Não serão criadas novas despesas de ${item.nome}. Os lançamentos já feitos serão mantidos.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Encerrar'),
          ),
        ],
      ),
    );
    if (confirmar == true) await repository.encerrar(item.id);
  }

  @override
  Widget build(BuildContext context) {
    final desktop = MediaQuery.sizeOf(context).width >= 900;
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: desktop
          ? null
          : AppBar(
              title: Text(widget.titulo),
              actions: [
                IconButton(
                  onPressed: _sincronizar,
                  icon: const Icon(Icons.sync),
                ),
              ],
            ),
      body: Column(
        children: [
          if (desktop) const AdminTopBar(),
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1250),
                child: Padding(
                  padding: EdgeInsets.all(desktop ? 28 : 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (desktop)
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                widget.titulo,
                                style: const TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            IconButton(
                              tooltip: 'Atualizar despesas',
                              onPressed: sincronizando ? null : _sincronizar,
                              icon: sincronizando
                                  ? const SizedBox.square(
                                      dimension: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Icon(Icons.sync_rounded),
                            ),
                            const SizedBox(width: 8),
                            FilledButton.icon(
                              onPressed: _novo,
                              icon: const Icon(Icons.add),
                              label: Text('Cadastrar ${widget.tipo.singular}'),
                            ),
                          ],
                        )
                      else
                        const Text(
                          'Cadastre e acompanhe aplicações recorrentes para vários animais.',
                          style: TextStyle(color: Color(0xFF64748B)),
                        ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEEF2FF),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFC7D2FE)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.info_outline,
                              color: Color(0xFF4338CA),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'As aplicações vencidas de ${widget.tipo.singular} são lançadas automaticamente nas despesas de cada animal ao abrir ou atualizar esta tela. O mesmo lançamento nunca é somado duas vezes.',
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: StreamBuilder<List<MedicamentoModel>>(
                          stream: repository.observar(),
                          builder: (context, snapshot) {
                            if (snapshot.hasError) {
                              return Center(
                                child: Text(
                                  'Erro ao carregar ${widget.titulo.toLowerCase()}: ${snapshot.error}',
                                ),
                              );
                            }
                            if (!snapshot.hasData) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                            final itens = snapshot.data!;
                            if (itens.isEmpty) {
                              return Center(
                                child: Text(
                                  'Nenhum ${widget.tipo.singular} cadastrado.',
                                ),
                              );
                            }
                            return desktop ? _tabela(itens) : _lista(itens);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: desktop
          ? null
          : FloatingActionButton.extended(
              onPressed: _novo,
              icon: const Icon(Icons.add),
              label: Text('Cadastrar ${widget.tipo.singular}'),
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _tabela(List<MedicamentoModel> itens) => Card(
    clipBehavior: Clip.antiAlias,
    child: SingleChildScrollView(
      child: SizedBox(
        width: double.infinity,
        child: DataTable(
          columns: [
            DataColumn(label: Text(widget.tipo.singularCapital)),
            const DataColumn(label: Text('Dose / orientação')),
            const DataColumn(label: Text('Frequência')),
            const DataColumn(label: Text('Valor por aplicação')),
            const DataColumn(label: Text('Animais')),
            const DataColumn(label: Text('Situação')),
            const DataColumn(label: Text('')),
          ],
          rows: itens
              .map(
                (item) => DataRow(
                  cells: [
                    DataCell(
                      Text(
                        item.nome,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    DataCell(Text(item.dose)),
                    DataCell(Text(item.frequencia.label)),
                    DataCell(Text(moeda.format(item.valor))),
                    DataCell(Text('${item.animalIds.length}')),
                    DataCell(_status(item)),
                    DataCell(
                      item.ativo
                          ? IconButton(
                              tooltip: 'Encerrar',
                              onPressed: () => _encerrar(item),
                              icon: const Icon(Icons.stop_circle_outlined),
                            )
                          : const SizedBox.shrink(),
                    ),
                  ],
                ),
              )
              .toList(),
        ),
      ),
    ),
  );

  Widget _lista(List<MedicamentoModel> itens) => ListView.separated(
    itemCount: itens.length,
    separatorBuilder: (_, _) => const SizedBox(height: 10),
    itemBuilder: (_, index) {
      final item = itens[index];
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(child: Icon(widget.icone)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      item.nome,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  _status(item),
                ],
              ),
              const SizedBox(height: 12),
              Text('${item.dose} • ${item.frequencia.label}'),
              const SizedBox(height: 5),
              Text(
                '${moeda.format(item.valor)} por animal/aplicação • ${item.animalIds.length} animal(is)',
              ),
              Text(
                'Início: ${data.format(item.dataInicio)}${item.dataFim == null ? '' : ' • Fim: ${data.format(item.dataFim!)}'}',
              ),
              if (item.ativo)
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: () => _encerrar(item),
                    icon: const Icon(Icons.stop_circle_outlined),
                    label: const Text('Encerrar'),
                  ),
                ),
            ],
          ),
        ),
      );
    },
  );

  Widget _status(MedicamentoModel item) => Chip(
    label: Text(item.ativo ? 'Ativo' : 'Encerrado'),
    side: BorderSide.none,
    backgroundColor: item.ativo
        ? const Color(0xFFD1FAE5)
        : const Color(0xFFE5E7EB),
    labelStyle: TextStyle(
      color: item.ativo ? const Color(0xFF065F46) : const Color(0xFF4B5563),
      fontSize: 12,
    ),
  );
}

class CadastroMedicamentoPage extends StatefulWidget {
  const CadastroMedicamentoPage({
    super.key,
    required this.repository,
    this.tipo = TipoTratamento.remedio,
  });
  final MedicamentoRepository repository;
  final TipoTratamento tipo;

  @override
  State<CadastroMedicamentoPage> createState() =>
      _CadastroMedicamentoPageState();
}

class _CadastroMedicamentoPageState extends State<CadastroMedicamentoPage> {
  final formKey = GlobalKey<FormState>();
  final nome = TextEditingController();
  final dose = TextEditingController();
  final orientacoes = TextEditingController();
  final valor = TextEditingController();
  final busca = TextEditingController();
  late final Future<List<CavaloModel>> animais = widget.repository
      .listarAnimais();
  final selecionados = <String>{};
  FrequenciaMedicamento frequencia = FrequenciaMedicamento.diario;
  DateTime inicio = somenteData(DateTime.now());
  DateTime? fim;
  bool salvando = false;

  @override
  void dispose() {
    nome.dispose();
    dose.dispose();
    orientacoes.dispose();
    valor.dispose();
    busca.dispose();
    super.dispose();
  }

  int? _centavos(String texto) {
    var limpo = texto.replaceAll(RegExp(r'[^0-9,.]'), '');
    if (limpo.isEmpty) return null;
    if (limpo.contains(',')) {
      limpo = limpo.replaceAll('.', '').replaceAll(',', '.');
    }
    final numero = double.tryParse(limpo);
    return numero == null ? null : (numero * 100).round();
  }

  Future<void> _escolherInicio() async {
    final data = await showAppDatePicker(
      context: context,
      initialDate: inicio,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (data != null) setState(() => inicio = somenteData(data));
  }

  Future<void> _escolherFim() async {
    final data = await showAppDatePicker(
      context: context,
      initialDate: fim ?? inicio,
      firstDate: inicio,
      lastDate: DateTime(2100),
    );
    if (data != null) setState(() => fim = somenteData(data));
  }

  Future<void> _salvar(List<CavaloModel> lista) async {
    if (!(formKey.currentState?.validate() ?? false)) return;
    if (selecionados.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione pelo menos um animal.')),
      );
      return;
    }
    final teste = MedicamentoModel(
      id: '',
      nome: nome.text,
      dose: dose.text,
      orientacoes: orientacoes.text,
      valorCentavos: _centavos(valor.text)!,
      frequencia: frequencia,
      dataInicio: inicio,
      dataFim: fim,
      animalIds: selecionados.toList(),
      animalNomes: {
        for (final animal in lista.where((a) => selecionados.contains(a.id)))
          animal.id: animal.nome,
      },
      tipo: widget.tipo,
    );
    if (teste.ocorrenciasPendentes(DateTime.now()).length *
            selecionados.length >
        5000) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'O período gera mais de 5.000 despesas. Escolha uma data inicial mais recente.',
          ),
        ),
      );
      return;
    }
    setState(() => salvando = true);
    try {
      await widget.repository.cadastrar(teste);
      if (mounted) Navigator.pop(context, true);
    } on MedicamentoSalvoSemSincronizar catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${widget.tipo.singularCapital} salvo. As despesas serão atualizadas ao abrir a tela novamente.',
            ),
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (erro) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro ao salvar: $erro')));
      }
    } finally {
      if (mounted) setState(() => salvando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final formato = DateFormat('dd/MM/yyyy');
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: DesktopWindowScope.isInside(context)
          ? null
          : AppBar(title: Text('Novo ${widget.tipo.singular}')),
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
          return Form(
            key: formKey,
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                const Text(
                  'Dados do tratamento',
                  style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 14,
                  runSpacing: 14,
                  children: [
                    SizedBox(
                      width: 420,
                      child: TextFormField(
                        controller: nome,
                        decoration: InputDecoration(
                          labelText: 'Nome do ${widget.tipo.singular} *',
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) => v == null || v.trim().isEmpty
                            ? 'Informe o ${widget.tipo.singular}'
                            : null,
                      ),
                    ),
                    SizedBox(
                      width: 420,
                      child: TextFormField(
                        controller: dose,
                        decoration: const InputDecoration(
                          labelText: 'Dose / orientação *',
                          hintText: 'Ex.: 10 ml ou 1 comprimido',
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) => v == null || v.trim().isEmpty
                            ? 'Informe a dose ou orientação'
                            : null,
                      ),
                    ),
                    SizedBox(
                      width: 270,
                      child: TextFormField(
                        controller: valor,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9,.]')),
                        ],
                        decoration: const InputDecoration(
                          labelText: 'Valor por animal/aplicação *',
                          prefixText: 'R\$ ',
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) {
                          final c = _centavos(v ?? '');
                          return c == null || c <= 0
                              ? 'Informe um valor maior que zero'
                              : null;
                        },
                      ),
                    ),
                    SizedBox(
                      width: 270,
                      child: DropdownButtonFormField<FrequenciaMedicamento>(
                        initialValue: frequencia,
                        decoration: const InputDecoration(
                          labelText: 'Frequência',
                          border: OutlineInputBorder(),
                        ),
                        items: FrequenciaMedicamento.values
                            .map(
                              (f) => DropdownMenuItem(
                                value: f,
                                child: Text(f.label),
                              ),
                            )
                            .toList(),
                        onChanged: (v) => setState(() => frequencia = v!),
                      ),
                    ),
                    SizedBox(
                      width: 270,
                      child: OutlinedButton.icon(
                        onPressed: _escolherInicio,
                        icon: const Icon(Icons.calendar_today),
                        label: Text('Início: ${formato.format(inicio)}'),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(56),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 270,
                      child: OutlinedButton.icon(
                        onPressed: _escolherFim,
                        icon: const Icon(Icons.event_available),
                        label: Text(
                          fim == null
                              ? 'Sem data final'
                              : 'Fim: ${formato.format(fim!)}',
                        ),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(56),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 854,
                      child: TextFormField(
                        controller: orientacoes,
                        maxLines: 2,
                        decoration: const InputDecoration(
                          labelText: 'Observações e orientações',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Selecionar animais',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(
                      '${selecionados.length} selecionado(s)',
                      style: const TextStyle(
                        color: Color(0xFF4F46E5),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: busca,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    hintText: 'Buscar animal',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 8),
                Builder(
                  builder: (context) {
                    final termo = busca.text.trim().toLowerCase();
                    final filtrados = lista
                        .where((a) => a.nome.toLowerCase().contains(termo))
                        .toList();
                    return ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 300),
                      child: Material(
                        color: Colors.white,
                        clipBehavior: Clip.antiAlias,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: const BorderSide(color: Color(0xFFE5E7EB)),
                        ),
                        child: Column(
                          children: [
                            CheckboxListTile(
                              title: Text(
                                'Selecionar todos (${filtrados.length})',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              value:
                                  filtrados.isNotEmpty &&
                                  filtrados.every(
                                    (a) => selecionados.contains(a.id),
                                  ),
                              onChanged: filtrados.isEmpty
                                  ? null
                                  : (marcado) => setState(() {
                                      if (marcado == true) {
                                        selecionados.addAll(
                                          filtrados.map((a) => a.id),
                                        );
                                      } else {
                                        selecionados.removeAll(
                                          filtrados.map((a) => a.id),
                                        );
                                      }
                                    }),
                            ),
                            const Divider(height: 1),
                            Expanded(
                              child: filtrados.isEmpty
                                  ? const Center(
                                      child: Text('Nenhum animal encontrado.'),
                                    )
                                  : ListView.builder(
                                      itemCount: filtrados.length,
                                      itemBuilder: (_, i) {
                                        final animal = filtrados[i];
                                        return CheckboxListTile(
                                          key: ValueKey('animal_${animal.id}'),
                                          title: Text(
                                            animal.nome.isEmpty
                                                ? 'Animal sem nome'
                                                : animal.nome,
                                          ),
                                          subtitle:
                                              animal.registroAbccmm.isEmpty
                                              ? null
                                              : Text(
                                                  'Registro: ${animal.registroAbccmm}',
                                                ),
                                          value: selecionados.contains(
                                            animal.id,
                                          ),
                                          onChanged: (v) => setState(() {
                                            if (v == true) {
                                              selecionados.add(animal.id);
                                            } else {
                                              selecionados.remove(animal.id);
                                            }
                                          }),
                                        );
                                      },
                                    ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      onPressed: salvando
                          ? null
                          : () => Navigator.maybePop(context),
                      child: const Text('Cancelar'),
                    ),
                    const SizedBox(width: 12),
                    FilledButton.icon(
                      onPressed: salvando ? null : () => _salvar(lista),
                      icon: salvando
                          ? const SizedBox.square(
                              dimension: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.save),
                      label: const Text('Salvar e lançar despesas'),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
