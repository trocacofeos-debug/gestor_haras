import 'package:flutter/material.dart';

import '../../models/financeiro_animais.dart';
import '../../models/financeiro_vendas.dart';
import '../home/admin_top_bar.dart';
import 'financeiro_animais_page.dart';
import 'financeiro_vendas_page.dart';

class FinanceiroGeralPage extends StatelessWidget {
  const FinanceiroGeralPage({
    super.key,
    this.carregarAnimais,
    this.carregarVendas,
  });

  final Future<FinanceiroAnimaisDados> Function()? carregarAnimais;
  final Future<FinanceiroVendasDados> Function()? carregarVendas;

  @override
  Widget build(BuildContext context) {
    final desktop = MediaQuery.sizeOf(context).width >= 900;
    const tabs = [
      Tab(height: 42, text: 'Financeiro dos animais'),
      Tab(height: 42, text: 'Financeiro das vendas'),
    ];
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF3F4F6),
        appBar: desktop
            ? null
            : AppBar(
                title: const Text('Financeiro'),
                bottom: const TabBar(tabs: tabs),
              ),
        body: Column(
          children: [
            if (desktop) const AdminTopBar(),
            if (desktop)
              const Material(
                color: Colors.white,
                child: TabBar(tabs: tabs),
              ),
            Expanded(
              child: TabBarView(
                children: [
                  FinanceiroAnimaisPage(
                    embedded: true,
                    carregar: carregarAnimais,
                  ),
                  FinanceiroVendasPage(carregar: carregarVendas),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
