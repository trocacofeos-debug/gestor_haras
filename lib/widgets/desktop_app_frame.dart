import 'package:flutter/material.dart';

/// Moldura global usada apenas no modo desktop/web.
///
/// Mantém o aplicativo preso ao viewport, cria uma leitura visual de software
/// desktop e reduz a densidade dos controles sem alterar as telas mobile.
class DesktopAppFrame extends StatelessWidget {
  final Widget child;

  const DesktopAppFrame({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);

    if (media.size.width < 1000) {
      return child;
    }

    final compactarAltura = media.size.height < 820;
    final escalaTexto = compactarAltura ? 0.92 : 1.0;
    final tema = Theme.of(context);

    return MediaQuery(
      data: media.copyWith(
        textScaler: TextScaler.linear(escalaTexto),
        padding: EdgeInsets.zero,
        viewPadding: EdgeInsets.zero,
      ),
      child: Theme(
        data: tema.copyWith(
          visualDensity: compactarAltura
              ? const VisualDensity(horizontal: -1, vertical: -2)
              : const VisualDensity(horizontal: -0.5, vertical: -1),
          inputDecorationTheme: tema.inputDecorationTheme.copyWith(
            isDense: true,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 14,
              vertical: compactarAltura ? 11 : 14,
            ),
          ),
        ),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFE8EEF7), Color(0xFFD7E0EC)],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: const Color(0xFFF4F6FA),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFBFCBDA)),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x300F172A),
                    blurRadius: 32,
                    offset: Offset(0, 12),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(17),
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
