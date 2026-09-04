import 'package:flutter/material.dart';

class ProdutoFoto extends StatelessWidget {
  const ProdutoFoto({super.key, required this.url, this.tamanho = 44});

  final String url;
  final double tamanho;

  @override
  Widget build(BuildContext context) {
    final vazio = ColoredBox(
      color: const Color(0xFFF1F5F9),
      child: Center(
        child: Icon(
          Icons.inventory_2_outlined,
          size: tamanho * .52,
          color: const Color(0xFF64748B),
        ),
      ),
    );
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox.square(
        dimension: tamanho,
        child: url.trim().isEmpty
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
