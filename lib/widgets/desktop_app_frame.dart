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
                child: Column(
                  children: [
                    const _DesktopTitleBar(),
                    Expanded(child: child),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DesktopTitleBar extends StatelessWidget {
  const _DesktopTitleBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        color: Color(0xFFFBFCFE),
        border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: Color(0xFF4F46E5),
              borderRadius: BorderRadius.all(Radius.circular(7)),
            ),
            child: Icon(Icons.pets_rounded, size: 14, color: Colors.white),
          ),
          const SizedBox(width: 9),
          const Text(
            'Gestor Haras',
            style: TextStyle(
              color: Color(0xFF334155),
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              letterSpacing: .2,
            ),
          ),
          const Spacer(),
          Container(
            width: 7,
            height: 7,
            decoration: const BoxDecoration(
              color: Color(0xFF10B981),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          const Text(
            'Sistema online',
            style: TextStyle(
              color: Color(0xFF64748B),
              fontSize: 10.5,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F1FB),
              borderRadius: BorderRadius.circular(999),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.desktop_windows_rounded,
                  size: 13,
                  color: Color(0xFF1565C0),
                ),
                SizedBox(width: 5),
                Text(
                  'Modo desktop',
                  style: TextStyle(
                    color: Color(0xFF1565C0),
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
