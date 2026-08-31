import 'package:flutter/material.dart';
import 'funcionarios_lista_view.dart';

class FuncionariosListPageMobile extends StatelessWidget {
  const FuncionariosListPageMobile({super.key});
  @override
  Widget build(BuildContext context) =>
      const FuncionariosListaView(desktop: false);
}
