import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/cavalo_model.dart';
import '../../models/financeiro_animais.dart';
import '../../models/medicamento_model.dart';
import '../../models/registro_animal_model.dart';
import '../../services/financeiro_animais_service.dart';
import '../../services/medicamento_service.dart';
import '../../services/registro_animal_service.dart';
import '../home/admin_top_bar.dart';

class AcompanhamentoAnimaisPage extends StatefulWidget {
  const AcompanhamentoAnimaisPage({
    super.key,
    this.lancamentosRepository,
    this.registrosRepository,
    this.carregarFinanceiro,
  });

  final MedicamentoRepository? lancamentosRepository;
  final RegistroAnimalRepository? registrosRepository;
  final Future<FinanceiroAnimaisDados> Function()? carregarFinanceiro;

  @override
  State<AcompanhamentoAnimaisPage> createState() =>
      _AcompanhamentoAnimaisPageState();
}

class _AcompanhamentoAnimaisPageState extends State<AcompanhamentoAnimaisPage> {
  late final MedicamentoRepository lancamentosRepository =
      widget.lancamentosRepository ?? LancamentosRepository();
  late final RegistroAnimalRepository registrosRepository =
      widget.registrosRepository ?? RegistroAnimalService();
  late Future<_BaseAnimais> base = _carregarBase();
  String? animalId;

  final moeda = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
  final data = DateFormat('dd/MM/yyyy');

  Future<_BaseAnimais> _carregarBase() async => _BaseAnimais(
    animais: await lancamentosRepository.listarAnimais(),
    financeiro:
        await (widget.carregarFinanceiro ??
            const FinanceiroAnimaisService().carregar)(),
  );

  void _atualizar() => setState(() => base = _carregarBase());

  @override
  Widget build(BuildContext context) {
    final desktop = MediaQuery.sizeOf(context).width >= 900;
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: desktop
          ? null
          : AppBar(
              title: const Text('Animais'),
              actions: [
                IconButton(
                  tooltip: 'Atualizar',
                  onPressed: _atualizar,
                  icon: const Icon(Icons.refresh_rounded),
                ),
              ],
            ),
      body: Column(
        children: [
          if (desktop) const AdminTopBar(),
          Expanded(
            child: FutureBuilder<_BaseAnimais>(
              future: base,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return _erro('Não foi possível carregar os animais.');
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final base = snapshot.data!;
                if (base.animais.isEmpty) {
                  return const Center(child: Text('Nenhum animal cadastrado.'));
                }
                final selecionado =
                    base.animais.any((animal) => animal.id == animalId)
                    ? animalId!
                    : base.animais.first.id;
                final animal = base.animais.firstWhere(
                  (item) => item.id == selecionado,
                );
                return StreamBuilder<List<MedicamentoModel>>(
                  stream: lancamentosRepository.observar(),
                  builder: (context, medicamentos) {
                    if (medicamentos.hasError) {
                      return _erro('Erro ao carregar remédios e dietas.');
                    }
                    if (!medicamentos.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    return StreamBuilder<List<RegistroAnimalModel>>(
                      stream: registrosRepository.observar(
                        TipoRegistroAnimal.controle,
                      ),
                      builder: (context, controles) => _registrosBuilder(
                        base,
                        animal,
                        medicamentos.data!,
                        controles,
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _registrosBuilder(
    _BaseAnimais base,
    CavaloModel animal,
    List<MedicamentoModel> medicamentos,
    AsyncSnapshot<List<RegistroAnimalModel>> controles,
  ) {
    if (controles.hasError) return _erro('Erro ao carregar medidas.');
    if (!controles.hasData) {
      return const Center(child: CircularProgressIndicator());
    }
    return StreamBuilder<List<RegistroAnimalModel>>(
      stream: registrosRepository.observar(TipoRegistroAnimal.treinamento),
      builder: (context, treinos) {
        if (treinos.hasError) return _erro('Erro ao carregar treinamentos.');
        if (!treinos.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        return StreamBuilder<List<RegistroAnimalModel>>(
          stream: registrosRepository.observar(TipoRegistroAnimal.reproducao),
          builder: (context, reproducao) {
            if (reproducao.hasError) {
              return _erro('Erro ao carregar reprodução.');
            }
            if (!reproducao.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            return _conteudo(
              base,
              animal,
              medicamentos
                  .where((item) => item.animalIds.contains(animal.id))
                  .toList(),
              controles.data!
                  .where((item) => item.animalId == animal.id)
                  .toList(),
              treinos.data!
                  .where((item) => item.animalId == animal.id)
                  .toList(),
              reproducao.data!
                  .where((item) => item.animalId == animal.id)
                  .toList(),
            );
          },
        );
      },
    );
  }

  Widget _conteudo(
    _BaseAnimais base,
    CavaloModel animal,
    List<MedicamentoModel> medicamentos,
    List<RegistroAnimalModel> controles,
    List<RegistroAnimalModel> treinos,
    List<RegistroAnimalModel> reproducao,
  ) {
    final movimentos = base.financeiro.filtrar(animalId: animal.id);
    final resumo = ResumoFinanceiroAnimais.calcular(movimentos);
    final dietas = medicamentos
        .where(
          (item) =>
              item.tipo == TipoTratamento.racao ||
              item.tipo == TipoTratamento.suplemento,
        )
        .toList();
    final saude = medicamentos
        .where(
          (item) =>
              item.tipo == TipoTratamento.remedio ||
              item.tipo == TipoTratamento.vacina,
        )
        .toList();

    return RefreshIndicator(
      onRefresh: () async => _atualizar(),
      child: ListView(
        padding: const EdgeInsets.all(14),
        children: [
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1250),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _cabecalho(base.animais, animal),
                  const SizedBox(height: 8),
                  _resumoFinanceiro(resumo),
                  const SizedBox(height: 8),
                  _painelAbas(
                    dietas: dietas,
                    saude: saude,
                    controles: controles,
                    treinos: treinos,
                    reproducao: reproducao,
                    movimentos: movimentos,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _cabecalho(List<CavaloModel> animais, CavaloModel animal) {
    final nascimento = animal.fichaAbccmm.dataNascimento;
    final dados = <String>[
      if (animal.raca.isNotEmpty) animal.raca,
      if (animal.sexo.isNotEmpty) animal.sexo,
      if (animal.pelagem.isNotEmpty) animal.pelagem,
      if (nascimento != null) 'Nascimento: ${data.format(nascimento)}',
      if (animal.registroAbccmm.isNotEmpty)
        'Registro: ${animal.registroAbccmm}',
    ];
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compacto = constraints.maxWidth < 650;
            final identificacao = Row(
              children: [
                const CircleAvatar(
                  radius: 21,
                  child: Icon(Icons.pets_rounded, size: 21),
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        animal.nome,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (dados.isNotEmpty)
                        Text(
                          dados.join(' • '),
                          style: const TextStyle(fontSize: 12),
                        ),
                      if (animal.pai.isNotEmpty || animal.mae.isNotEmpty)
                        Text(
                          '${animal.pai.isEmpty ? '' : 'Pai: ${animal.pai}'}'
                          '${animal.pai.isNotEmpty && animal.mae.isNotEmpty ? ' • ' : ''}'
                          '${animal.mae.isEmpty ? '' : 'Mãe: ${animal.mae}'}',
                          style: const TextStyle(
                            color: Color(0xFF64748B),
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            );
            final seletor = DropdownButtonFormField<String>(
              key: ValueKey('acompanhamento-${animal.id}'),
              initialValue: animal.id,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'Animal',
                isDense: true,
                border: OutlineInputBorder(),
              ),
              items: animais
                  .map(
                    (item) => DropdownMenuItem(
                      value: item.id,
                      child: Text(item.nome, overflow: TextOverflow.ellipsis),
                    ),
                  )
                  .toList(),
              onChanged: (id) => setState(() => animalId = id),
            );
            if (compacto) {
              return Column(
                children: [identificacao, const SizedBox(height: 8), seletor],
              );
            }
            return Row(
              children: [
                Expanded(child: identificacao),
                const SizedBox(width: 12),
                SizedBox(width: 280, child: seletor),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _painelAbas({
    required List<MedicamentoModel> dietas,
    required List<MedicamentoModel> saude,
    required List<RegistroAnimalModel> controles,
    required List<RegistroAnimalModel> treinos,
    required List<RegistroAnimalModel> reproducao,
    required List<MovimentoAnimal> movimentos,
  }) {
    final altura = MediaQuery.sizeOf(context).width < 600 ? 330.0 : 370.0;
    return DefaultTabController(
      length: 6,
      child: Column(
        children: [
          const Material(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(10)),
            child: TabBar(
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              tabs: [
                Tab(height: 40, text: 'Dietas e suplementos'),
                Tab(height: 40, text: 'Remédios e vacinas'),
                Tab(height: 40, text: 'Altura e peso'),
                Tab(height: 40, text: 'Treinamentos'),
                Tab(height: 40, text: 'Reprodução'),
                Tab(height: 40, text: 'Financeiro'),
              ],
            ),
          ),
          const SizedBox(height: 6),
          SizedBox(
            height: altura,
            child: TabBarView(
              children: [
                _rolagem(
                  _secaoProdutos(
                    'Dietas e suplementos',
                    Icons.restaurant_outlined,
                    dietas,
                  ),
                ),
                _rolagem(
                  _secaoProdutos(
                    'Remédios e vacinas',
                    Icons.medication_outlined,
                    saude,
                  ),
                ),
                _rolagem(
                  _secaoRegistros(
                    'Altura, peso e controle',
                    Icons.monitor_weight_outlined,
                    controles,
                  ),
                ),
                _rolagem(
                  _secaoRegistros(
                    'Treinamentos',
                    Icons.fitness_center_outlined,
                    treinos,
                  ),
                ),
                _rolagem(
                  _secaoRegistros(
                    'Reprodução',
                    Icons.favorite_outline,
                    reproducao,
                  ),
                ),
                _rolagem(_secaoFinanceiro(movimentos)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _rolagem(Widget child) => SingleChildScrollView(child: child);

  Widget _resumoFinanceiro(ResumoFinanceiroAnimais resumo) => Row(
    children: [
      Expanded(
        child: _indicador(
          'Receitas',
          moeda.format(resumo.receitas / 100),
          const Color(0xFF047857),
        ),
      ),
      const SizedBox(width: 8),
      Expanded(
        child: _indicador(
          'Despesas',
          moeda.format(resumo.despesas / 100),
          const Color(0xFFB91C1C),
        ),
      ),
      const SizedBox(width: 8),
      Expanded(
        child: _indicador(
          'Saldo',
          moeda.format(resumo.saldo / 100),
          const Color(0xFF4338CA),
        ),
      ),
    ],
  );

  Widget _indicador(String titulo, String valor, Color cor) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: const Color(0xFFE5E7EB)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(titulo, style: const TextStyle(fontSize: 12)),
        const SizedBox(height: 2),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            valor,
            style: TextStyle(
              color: cor,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    ),
  );

  Widget _secaoProdutos(
    String titulo,
    IconData icone,
    List<MedicamentoModel> itens,
  ) => _secao(
    titulo,
    icone,
    itens.isEmpty
        ? const [_Vazio('Nenhum lançamento para este animal.')]
        : itens
              .map(
                (item) => _Linha(
                  titulo: '${item.tipo.singularCapital}: ${item.nome}',
                  detalhe:
                      '${item.dose} • ${item.frequencia.label} • ${item.ativo ? 'Ativo' : 'Encerrado'}',
                  data: data.format(item.dataInicio),
                ),
              )
              .toList(),
  );

  Widget _secaoRegistros(
    String titulo,
    IconData icone,
    List<RegistroAnimalModel> itens,
  ) {
    final ordenados = [...itens]..sort((a, b) => b.data.compareTo(a.data));
    return _secao(
      titulo,
      icone,
      ordenados.isEmpty
          ? const [_Vazio('Nenhum registro para este animal.')]
          : ordenados
                .map(
                  (item) => _Linha(
                    titulo: item.titulo.isEmpty ? item.animalNome : item.titulo,
                    detalhe: [
                      if (item.alturaMetros != null) '${item.alturaMetros} m',
                      if (item.pesoKg != null) '${item.pesoKg} kg',
                      if (item.status.isNotEmpty) item.status,
                      if (item.observacoes.isNotEmpty) item.observacoes,
                    ].join(' • '),
                    data: data.format(item.data),
                  ),
                )
                .toList(),
    );
  }

  Widget _secaoFinanceiro(List<MovimentoAnimal> movimentos) => _secao(
    'Receitas e despesas',
    Icons.account_balance_wallet_outlined,
    movimentos.isEmpty
        ? const [_Vazio('Nenhum movimento financeiro para este animal.')]
        : movimentos
              .take(20)
              .map(
                (item) => _Linha(
                  titulo: item.descricao,
                  detalhe:
                      '${item.tipo == TipoMovimentoAnimal.receita ? 'Receita' : 'Despesa'} • ${item.categoria} • ${moeda.format(item.centavos / 100)}',
                  data: item.data == null
                      ? 'Sem data'
                      : data.format(item.data!),
                ),
              )
              .toList(),
  );

  Widget _secao(String titulo, IconData icone, List<Widget> itens) => Card(
    margin: EdgeInsets.zero,
    child: Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icone, size: 20, color: const Color(0xFF4F46E5)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  titulo,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Text(
                '${itens.whereType<_Linha>().length}',
                style: const TextStyle(color: Color(0xFF64748B)),
              ),
            ],
          ),
          const Divider(height: 18),
          ...itens,
        ],
      ),
    ),
  );

  Widget _erro(String mensagem) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(mensagem),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: _atualizar,
          icon: const Icon(Icons.refresh_rounded),
          label: const Text('Tentar novamente'),
        ),
      ],
    ),
  );
}

class _BaseAnimais {
  const _BaseAnimais({required this.animais, required this.financeiro});
  final List<CavaloModel> animais;
  final FinanceiroAnimaisDados financeiro;
}

class _Linha extends StatelessWidget {
  const _Linha({
    required this.titulo,
    required this.detalhe,
    required this.data,
  });
  final String titulo;
  final String detalhe;
  final String data;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(titulo, style: const TextStyle(fontWeight: FontWeight.w600)),
              if (detalhe.isNotEmpty)
                Text(
                  detalhe,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 12,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(
          data,
          style: const TextStyle(color: Color(0xFF64748B), fontSize: 11),
        ),
      ],
    ),
  );
}

class _Vazio extends StatelessWidget {
  const _Vazio(this.texto);
  final String texto;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 4),
    child: Text(
      texto,
      style: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
    ),
  );
}
