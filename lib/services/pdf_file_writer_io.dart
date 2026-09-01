import 'dart:io';
import 'dart:typed_data';

Future<bool> escreverArquivoPdf(String caminho, Uint8List bytes) async {
  final arquivo = File(caminho);
  await arquivo.writeAsBytes(bytes, flush: true);
  return await arquivo.exists() && await arquivo.length() == bytes.length;
}
