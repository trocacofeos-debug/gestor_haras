import 'package:flutter/material.dart';
import 'fornecedores_lista_view.dart';

class FornecedoresListPageDesktop extends StatelessWidget {
  const FornecedoresListPageDesktop({super.key});

  @override
  Widget build(BuildContext context) =>
      const FornecedoresListaView(desktop: true);
}
