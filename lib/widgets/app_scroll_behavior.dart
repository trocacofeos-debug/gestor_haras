import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

/// Comportamento único de rolagem para todas as telas do aplicativo.
///
/// Permite arrastar com mouse e trackpad no web/desktop e mantém uma barra
/// discreta nas áreas roláveis, para listas grandes não parecerem uma página
/// sem fim.
class AppScrollBehavior extends MaterialScrollBehavior {
  const AppScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => const {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.trackpad,
    PointerDeviceKind.stylus,
    PointerDeviceKind.invertedStylus,
  };

  bool get _desktopOuWeb =>
      kIsWeb ||
      switch (defaultTargetPlatform) {
        TargetPlatform.windows ||
        TargetPlatform.macOS ||
        TargetPlatform.linux => true,
        _ => false,
      };

  @override
  Widget buildScrollbar(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    if (!_desktopOuWeb) return child;
    return Scrollbar(
      controller: details.controller,
      interactive: true,
      radius: const Radius.circular(8),
      thickness: 8,
      child: child,
    );
  }

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    if (_desktopOuWeb) return const ClampingScrollPhysics();
    return super.getScrollPhysics(context);
  }
}
