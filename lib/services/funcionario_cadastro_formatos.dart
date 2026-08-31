import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class FuncionarioCadastroFormatos {
  static double? lerSalario(String texto) {
    final valor = texto.trim();
    if (valor.isEmpty) return 0;
    if (RegExp(r'^\d+(?:\.\d{1,2})?$').hasMatch(valor)) {
      return double.tryParse(valor);
    }
    if (RegExp(r'^(?:\d+|\d{1,3}(?:\.\d{3})+)(?:,\d{1,2})?$').hasMatch(valor)) {
      return double.tryParse(valor.replaceAll('.', '').replaceAll(',', '.'));
    }
    return null;
  }

  static String salario(double valor) =>
      NumberFormat('#,##0.00', 'pt_BR').format(valor);
  static String data(Timestamp? valor) =>
      valor == null ? '' : DateFormat('dd/MM/yyyy').format(valor.toDate());
  static DateTime? lerData(String texto) {
    if (!RegExp(r'^\d{2}/\d{2}/\d{4}$').hasMatch(texto.trim())) return null;
    try {
      return DateFormat('dd/MM/yyyy').parseStrict(texto.trim());
    } catch (_) {
      return null;
    }
  }

  static Timestamp? timestamp(String texto) {
    final valor = lerData(texto);
    return valor == null ? null : Timestamp.fromDate(valor);
  }
}
