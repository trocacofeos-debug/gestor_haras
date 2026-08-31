import 'package:flutter/material.dart';
import 'funcionarios_lista_view.dart';

class FuncionariosListPageDesktop extends StatelessWidget {
  const FuncionariosListPageDesktop({super.key});
  @override
  Widget build(BuildContext context) =>
      const FuncionariosListaView(desktop: true);
}
