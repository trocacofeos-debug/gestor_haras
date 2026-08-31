import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'popup_workspace.dart';

class DesktopWindowScope extends InheritedWidget {
  const DesktopWindowScope({super.key, required super.child});

  static bool isInside(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<DesktopWindowScope>() != null;

  @override
  bool updateShouldNotify(DesktopWindowScope oldWidget) => false;
}

/// Abre qualquer página como janela interna no desktop e mantém a navegação
/// tradicional em telas menores.
Future<T?> openDesktopWindow<T>(
  BuildContext context, {
  required String title,
  required WidgetBuilder builder,
  IconData icon = Icons.web_asset_rounded,
  double width = 1180,
  double height = 760,
}) async {
  if (MediaQuery.sizeOf(context).width < 900) {
    return Navigator.of(context).push<T>(MaterialPageRoute(builder: builder));
  }

  final workspace = PopupWorkspace.of(context);
  if (workspace != null) {
    return workspace.show<T>(
      sourceContext: context,
      title: title,
      barrierDismissible: false,
      barrierColor: const Color(0x7D0F172A),
      showMinimizeControl: false,
      builder: (dialogContext) => _DesktopWindow(
        title: title,
        icon: icon,
        initialWidth: width,
        initialHeight: height,
        child: builder(dialogContext),
      ),
    );
  }
  final navigator = Navigator.of(context, rootNavigator: true);

  // Mantém somente uma janela de trabalho: abrir outra substitui a atual.
  if (DesktopWindowScope.isInside(context)) {
    navigator.pop();
    await Future<void>.delayed(Duration.zero);
  }

  if (!navigator.mounted) return null;

  return showGeneralDialog<T>(
    context: navigator.context,
    barrierDismissible: false,
    barrierLabel: title,
    barrierColor: const Color(0x7D0F172A),
    transitionDuration: const Duration(milliseconds: 220),
    pageBuilder: (dialogContext, animation, secondaryAnimation) =>
        _DesktopWindow(
          title: title,
          icon: icon,
          initialWidth: width,
          initialHeight: height,
          child: builder(dialogContext),
        ),
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
      );
      return FadeTransition(
        opacity: curved,
        child: ScaleTransition(
          scale: Tween<double>(begin: .97, end: 1).animate(curved),
          child: child,
        ),
      );
    },
  );
}

class _DesktopWindow extends StatefulWidget {
  const _DesktopWindow({
    required this.title,
    required this.icon,
    required this.initialWidth,
    required this.initialHeight,
    required this.child,
  });

  final String title;
  final IconData icon;
  final double initialWidth;
  final double initialHeight;
  final Widget child;

  @override
  State<_DesktopWindow> createState() => _DesktopWindowState();
}

class _DesktopWindowState extends State<_DesktopWindow> {
  bool maximized = false;

  void _home() {
    final controls = PopupControls.of(context);
    if (controls != null) {
      controls.home();
    } else {
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.sizeOf(context);
    final margin = maximized ? 14.0 : 34.0;
    final maxWidth = (screen.width - margin * 2).clamp(0.0, double.infinity);
    final maxHeight = (screen.height - margin * 2).clamp(0.0, double.infinity);
    final windowWidth = maximized
        ? maxWidth
        : widget.initialWidth.clamp(0.0, maxWidth);
    final windowHeight = maximized
        ? maxHeight
        : widget.initialHeight.clamp(0.0, maxHeight);

    return SafeArea(
      child: Center(
        child: CallbackShortcuts(
          bindings: {
            const SingleActivator(LogicalKeyboardKey.escape): () =>
                Navigator.of(context).maybePop(),
            const SingleActivator(LogicalKeyboardKey.keyW, control: true): () =>
                Navigator.of(context).maybePop(),
            const SingleActivator(LogicalKeyboardKey.home, control: true):
                _home,
          },
          child: Focus(
            autofocus: true,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              curve: Curves.easeOutCubic,
              width: windowWidth,
              height: windowHeight,
              decoration: BoxDecoration(
                color: const Color(0xFFF4F6FA),
                borderRadius: BorderRadius.circular(maximized ? 12 : 20),
                border: Border.all(color: const Color(0xFFB9C6D8)),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x5C0F172A),
                    blurRadius: 48,
                    offset: Offset(0, 22),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(maximized ? 11 : 19),
                child: Column(
                  children: [
                    _WindowTitleBar(
                      title: widget.title,
                      icon: widget.icon,
                      maximized: maximized,
                      onHome: _home,
                      onMinimize: PopupControls.of(context)?.minimize,
                      onToggleMaximize: () =>
                          setState(() => maximized = !maximized),
                      onClose: () => Navigator.of(context).maybePop(),
                    ),
                    Expanded(child: DesktopWindowScope(child: widget.child)),
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

class _WindowTitleBar extends StatelessWidget {
  const _WindowTitleBar({
    required this.title,
    required this.icon,
    required this.maximized,
    required this.onHome,
    required this.onMinimize,
    required this.onToggleMaximize,
    required this.onClose,
  });

  final String title;
  final IconData icon;
  final bool maximized;
  final VoidCallback onHome;
  final VoidCallback? onMinimize;
  final VoidCallback onToggleMaximize;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: const BoxDecoration(
        color: Color(0xFFFBFCFE),
        border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: Row(
        children: [
          const SizedBox(width: 12),
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: const Color(0xFFEEF2FF),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: const Color(0xFF4F46E5)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onDoubleTap: onToggleMaximize,
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF1E293B),
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          TextButton.icon(
            onPressed: onHome,
            icon: const Icon(Icons.home_rounded, size: 16),
            label: const Text('Início'),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF4F46E5),
              backgroundColor: const Color(0xFFEEF2FF),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              textStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Container(
            width: 1,
            height: 22,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            color: const Color(0xFFE2E8F0),
          ),
          if (onMinimize != null)
            _TitleButton(
              tooltip: 'Minimizar',
              icon: Icons.minimize_rounded,
              onPressed: onMinimize!,
            ),
          _TitleButton(
            tooltip: maximized ? 'Restaurar' : 'Maximizar',
            icon: maximized
                ? Icons.filter_none_rounded
                : Icons.crop_square_rounded,
            onPressed: onToggleMaximize,
          ),
          _TitleButton(
            tooltip: 'Fechar',
            icon: Icons.close_rounded,
            danger: true,
            onPressed: onClose,
          ),
        ],
      ),
    );
  }
}

class _TitleButton extends StatelessWidget {
  const _TitleButton({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
    this.danger = false,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback onPressed;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 46,
      height: 48,
      child: IconButton(
        tooltip: tooltip,
        splashRadius: 20,
        hoverColor: danger ? const Color(0xFFFEE2E2) : const Color(0xFFF1F5F9),
        icon: Icon(
          icon,
          size: 17,
          color: danger ? const Color(0xFFDC2626) : const Color(0xFF475569),
        ),
        onPressed: onPressed,
      ),
    );
  }
}
