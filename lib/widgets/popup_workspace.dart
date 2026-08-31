import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Cada popup tem seu próprio Navigator. Assim, salvar um formulário
/// minimizado nunca fecha a janela que o usuário está usando por cima dele.
class PopupWorkspace extends StatefulWidget {
  final Widget child;
  const PopupWorkspace({super.key, required this.child});

  static PopupWorkspaceState? of(BuildContext context) =>
      context.findAncestorStateOfType<PopupWorkspaceState>();

  @override
  State<PopupWorkspace> createState() => PopupWorkspaceState();
}

class PopupWorkspaceState extends State<PopupWorkspace> {
  final _sessions = <_PopupSession<dynamic>>[];
  int _nextId = 0;

  Future<T?> show<T>({
    required BuildContext sourceContext,
    required WidgetBuilder builder,
    required String title,
    bool barrierDismissible = true,
    Color barrierColor = Colors.black54,
    bool useSafeArea = true,
    bool showMinimizeControl = true,
  }) {
    final id = ++_nextId;
    final session = _PopupSession<T>(
      id: id,
      parentId: PopupControls.of(sourceContext)?.sessionId,
      title: title == 'Popup' ? 'Popup $id' : title,
      builder: builder,
      themes: InheritedTheme.capture(from: sourceContext, to: context),
      barrierDismissible: barrierDismissible,
      barrierColor: barrierColor,
      useSafeArea: useSafeArea,
      showMinimizeControl: showMinimizeControl,
    );
    setState(() => _sessions.add(session));
    return session.result.future;
  }

  void _finish(_PopupSession<dynamic> session, dynamic result) {
    if (!mounted || !_sessions.contains(session)) return;
    final ids = <int>{session.id};
    var changed = true;
    while (changed) {
      changed = false;
      for (final item in _sessions) {
        if (ids.contains(item.parentId) && ids.add(item.id)) changed = true;
      }
    }
    final children = _sessions
        .where((s) => ids.contains(s.id) && s != session)
        .toList();
    setState(() => _sessions.removeWhere((s) => ids.contains(s.id)));
    for (final child in children) {
      child.complete(null);
    }
    session.complete(result);
  }

  void _minimize(_PopupSession<dynamic> session) {
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() => session.minimized = true);
  }

  void _restore(_PopupSession<dynamic> session) {
    setState(() {
      session.minimized = false;
      _sessions.remove(session);
      _sessions.add(session);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _sessions.contains(session)) session.focus.requestFocus();
    });
  }

  /// Usado ao sair da conta ou voltar explicitamente ao início.
  void closeAll() {
    if (!mounted || _sessions.isEmpty) return;
    final sessions = _sessions.toList();
    setState(_sessions.clear);
    for (final session in sessions) {
      session.complete(null);
    }
  }

  @override
  void dispose() {
    for (final session in _sessions) {
      session.complete(null);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final visible = _sessions.where((s) => !s.minimized).toList();
    final minimized = _sessions.where((s) => s.minimized).toList();
    return Stack(
      fit: StackFit.expand,
      children: [
        widget.child,
        for (final session in _sessions)
          Positioned.fill(
            key: ValueKey(session.id),
            child: Offstage(
              offstage: session.minimized,
              child: ExcludeFocus(
                excluding: visible.isEmpty || visible.last != session,
                child: TickerMode(
                  enabled: !session.minimized,
                  child: _PopupNavigator(
                    session: session,
                    onFinish: (result) => _finish(session, result),
                    onMinimize: () => _minimize(session),
                    onHome: closeAll,
                  ),
                ),
              ),
            ),
          ),
        if (minimized.isNotEmpty)
          Align(
            alignment: Alignment.bottomLeft,
            child: SafeArea(
              minimum: const EdgeInsets.all(8),
              child: Material(
                elevation: 8,
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  height: 48,
                  child: ListView.separated(
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    itemCount: minimized.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final session = minimized[index];
                      return Semantics(
                        label: 'Restaurar ${session.title}',
                        button: true,
                        excludeSemantics: true,
                        child: TextButton.icon(
                          key: ValueKey('restore-popup-${session.id}'),
                          onPressed: () => _restore(session),
                          icon: const Icon(Icons.open_in_new, size: 16),
                          label: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 180),
                            child: Text(
                              session.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.white,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _PopupSession<T> {
  final int id;
  final int? parentId;
  final String title;
  final WidgetBuilder builder;
  final CapturedThemes themes;
  final bool barrierDismissible;
  final Color barrierColor;
  final bool useSafeArea;
  final bool showMinimizeControl;
  final result = Completer<T?>();
  final navigator = GlobalKey<NavigatorState>();
  final focus = FocusScopeNode();
  bool minimized = false;

  _PopupSession({
    required this.id,
    required this.parentId,
    required this.title,
    required this.builder,
    required this.themes,
    required this.barrierDismissible,
    required this.barrierColor,
    required this.useSafeArea,
    required this.showMinimizeControl,
  });

  void complete(T? value) {
    if (!result.isCompleted) result.complete(value);
  }
}

class PopupControls extends InheritedWidget {
  final int sessionId;
  final VoidCallback minimize;
  final VoidCallback home;
  const PopupControls({
    super.key,
    required this.sessionId,
    required this.minimize,
    required this.home,
    required super.child,
  });
  static PopupControls? of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<PopupControls>();
  @override
  bool updateShouldNotify(PopupControls oldWidget) => false;
}

class _PopupNavigator extends StatefulWidget {
  final _PopupSession<dynamic> session;
  final ValueChanged<dynamic> onFinish;
  final VoidCallback onMinimize;
  final VoidCallback onHome;
  const _PopupNavigator({
    required this.session,
    required this.onFinish,
    required this.onMinimize,
    required this.onHome,
  });
  @override
  State<_PopupNavigator> createState() => _PopupNavigatorState();
}

class _PopupNavigatorState extends State<_PopupNavigator> {
  @override
  void dispose() {
    widget.session.focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final session = widget.session;
    return PopupControls(
      sessionId: session.id,
      minimize: widget.onMinimize,
      home: widget.onHome,
      child: FocusScope(
        node: session.focus,
        child: HeroControllerScope.none(
          child: Navigator(
            key: session.navigator,
            onGenerateInitialRoutes: (_, _) {
              final dialog = DialogRoute<dynamic>(
                context: context,
                themes: session.themes,
                barrierDismissible: session.barrierDismissible,
                barrierColor: session.barrierColor,
                useSafeArea: session.useSafeArea,
                builder: (dialogContext) => CallbackShortcuts(
                  bindings: {
                    const SingleActivator(LogicalKeyboardKey.escape): () =>
                        Navigator.of(dialogContext).maybePop(),
                  },
                  child: Focus(
                    autofocus: true,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(
                            top: session.showMinimizeControl ? 48 : 0,
                          ),
                          child: session.builder(dialogContext),
                        ),
                        if (session.showMinimizeControl)
                          Positioned(
                            top: 4,
                            right: 8,
                            child: Material(
                              color: Colors.white,
                              elevation: 3,
                              borderRadius: BorderRadius.circular(6),
                              child: IconButton(
                                tooltip: 'Minimizar popup',
                                onPressed: widget.onMinimize,
                                icon: const Icon(Icons.minimize_rounded),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
              dialog.popped.then(widget.onFinish);
              return [
                PageRouteBuilder<void>(
                  pageBuilder: (_, _, _) => const SizedBox.shrink(),
                  transitionDuration: Duration.zero,
                  opaque: false,
                ),
                dialog,
              ];
            },
            onGenerateRoute: (_) => null,
          ),
        ),
      ),
    );
  }
}

/// Fecha os popups quando a pilha principal é substituída (por exemplo logout).
class PopupWorkspaceObserver extends NavigatorObserver {
  final GlobalKey<PopupWorkspaceState> workspaceKey;
  final _routes = <Route<dynamic>>[];
  PopupWorkspaceObserver(this.workspaceKey);

  void _clear() => WidgetsBinding.instance.addPostFrameCallback(
    (_) => workspaceKey.currentState?.closeAll(),
  );
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      _routes.add(route);
  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _routes.remove(route);
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (_routes.isNotEmpty && _routes.first == route) _clear();
    _routes.remove(route);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    final index = _routes.indexOf(oldRoute!);
    if (index >= 0) {
      if (newRoute != null) {
        _routes[index] = newRoute;
      } else {
        _routes.removeAt(index);
      }
    }
    _clear();
  }
}
