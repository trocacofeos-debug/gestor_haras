import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Endpoint do ClickSign usado pelo widget embutido.
/// Deve bater com CLICKSIGN_ENV configurado no backend.
const String _clicksignEndpoint = "https://app.clicksign.com";

class ClicksignSignaturePage extends StatefulWidget {
  final String propostaId;

  const ClicksignSignaturePage({
    super.key,
    required this.propostaId,
  });

  @override
  State<ClicksignSignaturePage> createState() =>
      _ClicksignSignaturePageState();
}

class _ClicksignSignaturePageState extends State<ClicksignSignaturePage> {
  WebViewController? _controller;
  String? _erro;
  bool _assinouNoWidget = false;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    final doc = await FirebaseFirestore.instance
        .collection("propostas")
        .doc(widget.propostaId)
        .get();

    if (!doc.exists) {
      setState(() => _erro = "Proposta não encontrada");
      return;
    }

    final signerId = doc.data()?["clicksignSignerId"]?.toString();

    if (signerId == null || signerId.isEmpty) {
      setState(
        () => _erro =
            "Contrato ainda não foi gerado para esta proposta.",
      );
      return;
    }

    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..addJavaScriptChannel(
        "ClicksignFlutter",
        onMessageReceived: (message) {
          if (message.message == "signed") {
            setState(() => _assinouNoWidget = true);
          }
        },
      )
      ..loadHtmlString(
        _htmlWidget(signerId),
        baseUrl: _clicksignEndpoint,
      );

    setState(() => _controller = controller);
  }

  String _htmlWidget(String signerId) {
    return """
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <style>
    html, body { margin: 0; padding: 0; height: 100%; }
    #container { width: 100%; min-height: 100vh; }
  </style>
</head>
<body>
  <div id="container"></div>
  <script src="https://cdn-public-library.clicksign.com/embedded/embedded.min-2.1.0.js"></script>
  <script>
    var widget = new Clicksign('$signerId');
    widget.endpoint = '$_clicksignEndpoint';
    widget.origin = window.location.origin;

    widget.on('signed', function(event) {
      if (window.ClicksignFlutter) {
        window.ClicksignFlutter.postMessage('signed');
      }
    });

    widget.mount('container');
  </script>
</body>
</html>
""";
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> _statusProposta() {
    return FirebaseFirestore.instance
        .collection("propostas")
        .doc(widget.propostaId)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: AppBar(
        title: const Text("Assinatura do Contrato"),
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
      ),
      body: _erro != null
          ? _telaErro(_erro!)
          : StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              stream: _statusProposta(),
              builder: (context, snapshot) {
                final assinado =
                    snapshot.data?.data()?["status"] == "assinado";

                if (assinado) {
                  return _telaAssinado();
                }

                if (_assinouNoWidget) {
                  return _telaProcessando();
                }

                if (_controller == null) {
                  return const Center(child: CircularProgressIndicator());
                }

                return WebViewWidget(controller: _controller!);
              },
            ),
    );
  }

  Widget _telaErro(String erro) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 60),
            const SizedBox(height: 16),
            Text(erro, textAlign: TextAlign.center),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Voltar"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _telaProcessando() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text(
              "Assinatura recebida. Confirmando com o ClickSign...",
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _telaAssinado() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 90),
            const SizedBox(height: 20),
            const Text(
              "Contrato assinado com sucesso!",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text("Voltar"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
