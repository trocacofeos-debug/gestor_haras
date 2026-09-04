import 'package:flutter/material.dart';

import '../../models/medicamento_model.dart';
import '../../models/registro_animal_model.dart';
import '../../services/medicamento_service.dart';
import '../../services/produto_service.dart';
import '../../services/registro_animal_service.dart';
import '../home/admin_top_bar.dart';
import 'medicamentos_page.dart';
import 'registros_animais_page.dart';

class LancamentosPage extends StatelessWidget {
  const LancamentosPage({
    super.key,
    this.medicamentosRepository,
    this.produtosRepository,
    this.registrosRepository,
  });

  final MedicamentoRepository? medicamentosRepository;
  final ProdutoRepository? produtosRepository;
  final RegistroAnimalRepository? registrosRepository;

  static const _dietas = {TipoTratamento.racao, TipoTratamento.suplemento};
  static const _saude = {TipoTratamento.remedio, TipoTratamento.vacina};

  @override
  Widget build(BuildContext context) {
    final desktop = MediaQuery.sizeOf(context).width >= 900;
    final tabs = const [
      Tab(height: 42, text: 'Dietas e suplementos'),
      Tab(height: 42, text: 'Altura, peso e controle'),
      Tab(height: 42, text: 'Remédios e vermífugos'),
      Tab(height: 42, text: 'Treinamento'),
      Tab(height: 42, text: 'Reprodução'),
    ];

    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        backgroundColor: const Color(0xFFF3F4F6),
        appBar: desktop
            ? null
            : AppBar(
                toolbarHeight: 52,
                title: const Text(
                  'Lançamentos',
                  style: TextStyle(fontSize: 19, fontWeight: FontWeight.w700),
                ),
                bottom: TabBar(isScrollable: true, tabs: tabs),
              ),
        body: Column(
          children: [
            if (desktop) const AdminTopBar(),
            if (desktop)
              Material(
                color: Colors.white,
                child: SizedBox(
                  height: 58,
                  child: Row(
                    children: [
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          'Lançamentos',
                          style: TextStyle(
                            fontSize: 21,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Expanded(
                        child: TabBar(
                          isScrollable: true,
                          tabAlignment: TabAlignment.start,
                          tabs: tabs,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            Expanded(
              child: TabBarView(
                children: [
                  MedicamentosPage(
                    embedded: true,
                    repository: medicamentosRepository,
                    produtosRepository: produtosRepository,
                    tipos: _dietas,
                    tituloPersonalizado: 'Dietas e suplementos',
                  ),
                  RegistrosAnimaisPage(
                    embedded: true,
                    tipo: TipoRegistroAnimal.controle,
                    repository: registrosRepository,
                  ),
                  MedicamentosPage(
                    embedded: true,
                    repository: medicamentosRepository,
                    produtosRepository: produtosRepository,
                    tipos: _saude,
                    tituloPersonalizado: 'Remédios e vermífugos',
                  ),
                  RegistrosAnimaisPage(
                    embedded: true,
                    tipo: TipoRegistroAnimal.treinamento,
                    repository: registrosRepository,
                  ),
                  RegistrosAnimaisPage(
                    embedded: true,
                    tipo: TipoRegistroAnimal.reproducao,
                    repository: registrosRepository,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
