import 'package:flutter/material.dart';

/// Mantém formulários e painéis inteiros visíveis em uma janela desktop.
///
/// Em resoluções normais o conteúdo usa tamanho natural. Se faltar pouca
/// altura, ele reduz proporcionalmente em vez de criar rolagem na página.
/// Janelas realmente pequenas recebem rolagem como último recurso.
class DesktopFitViewport extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final EdgeInsets padding;
  final double alturaMinimaParaAjuste;

  const DesktopFitViewport({
    super.key,
    required this.child,
    this.maxWidth = 1440,
    this.padding = const EdgeInsets.all(20),
    this.alturaMinimaParaAjuste = 560,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final desktop = constraints.maxWidth >= 900;
        final largura = (constraints.maxWidth - padding.horizontal).clamp(
          320.0,
          maxWidth,
        );

        final conteudo = SizedBox(width: largura, child: child);

        if (!desktop || constraints.maxHeight < alturaMinimaParaAjuste) {
          return SingleChildScrollView(
            padding: padding,
            child: Center(child: conteudo),
          );
        }

        return Padding(
          padding: padding,
          child: Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.topCenter,
              child: conteudo,
            ),
          ),
        );
      },
    );
  }
}

/// Barra fixa de ações para formulários desktop.
class DesktopFormActions extends StatelessWidget {
  final String primaryLabel;
  final VoidCallback? onPrimary;
  final VoidCallback? onCancel;
  final bool loading;
  final IconData primaryIcon;

  const DesktopFormActions({
    super.key,
    required this.primaryLabel,
    required this.onPrimary,
    this.onCancel,
    this.loading = false,
    this.primaryIcon = Icons.save_rounded,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 62,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 9),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (onCancel != null) ...[
            OutlinedButton.icon(
              onPressed: loading ? null : onCancel,
              icon: const Icon(Icons.close_rounded, size: 18),
              label: const Text('Cancelar'),
            ),
            const SizedBox(width: 10),
          ],
          FilledButton.icon(
            onPressed: loading ? null : onPrimary,
            icon: loading
                ? const SizedBox.square(
                    dimension: 17,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(primaryIcon, size: 18),
            label: Text(primaryLabel),
          ),
        ],
      ),
    );
  }
}
