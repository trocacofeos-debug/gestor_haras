import 'package:flutter/material.dart';
import 'fornecedores_lista_view.dart';

class FornecedoresListPageMobile extends StatelessWidget {
  const FornecedoresListPageMobile({super.key});

  @override
  Widget build(BuildContext context) =>
      const FornecedoresListaView(desktop: false);
}
