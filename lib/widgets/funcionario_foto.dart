import 'package:flutter/material.dart';

class FuncionarioFoto extends StatelessWidget {
  final String url;
  final double tamanho;
  const FuncionarioFoto({super.key, required this.url, this.tamanho = 40});
  @override
  Widget build(BuildContext context) {
    final vazio = ColoredBox(
      color: const Color(0xFFF3F4F6),
      child: Center(
        child: Icon(
          Icons.person_outline,
          size: tamanho * .55,
          color: const Color(0xFF6B7280),
        ),
      ),
    );
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: SizedBox.square(
        dimension: tamanho,
        child: url.isEmpty
            ? vazio
            : Image.network(
                url,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => vazio,
              ),
      ),
    );
  }
}
