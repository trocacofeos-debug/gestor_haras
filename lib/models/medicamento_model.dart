import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';

enum TipoTratamento { remedio, vacina, suplemento }

extension TipoTratamentoExt on TipoTratamento {
  String get singular => switch (this) {
    TipoTratamento.remedio => 'remédio',
    TipoTratamento.vacina => 'vacina',
    TipoTratamento.suplemento => 'suplemento',
  };

  String get singularCapital => switch (this) {
    TipoTratamento.remedio => 'Remédio',
    TipoTratamento.vacina => 'Vacina',
    TipoTratamento.suplemento => 'Suplemento',
  };

  String get pluralCapital => switch (this) {
    TipoTratamento.remedio => 'Remédios',
    TipoTratamento.vacina => 'Vacinas',
    TipoTratamento.suplemento => 'Suplementos',
  };

  String get colecao => switch (this) {
    TipoTratamento.remedio => 'medicamentos',
    TipoTratamento.vacina => 'vacinas',
    TipoTratamento.suplemento => 'suplementos',
  };

  String get categoriaDespesa => switch (this) {
    TipoTratamento.remedio => 'remedio',
    TipoTratamento.vacina => 'vacina',
    TipoTratamento.suplemento => 'suplemento',
  };
}

enum FrequenciaMedicamento { diario, semanal, quinzenal, mensal }

extension FrequenciaMedicamentoExt on FrequenciaMedicamento {
  String get label => switch (this) {
    FrequenciaMedicamento.diario => 'Diário',
    FrequenciaMedicamento.semanal => 'Semanal',
    FrequenciaMedicamento.quinzenal => 'Quinzenal',
    FrequenciaMedicamento.mensal => 'Mensal',
  };
}

DateTime somenteData(DateTime data) =>
    DateTime(data.year, data.month, data.day);

class MedicamentoModel {
  const MedicamentoModel({
    required this.id,
    required this.nome,
    required this.dose,
    required this.valorCentavos,
    required this.frequencia,
    required this.dataInicio,
    required this.animalIds,
    required this.animalNomes,
    this.orientacoes = '',
    this.dataFim,
    this.sincronizadoAte,
    this.ativo = true,
    this.tipo = TipoTratamento.remedio,
  });

  final String id;
  final String nome;
  final String dose;
  final String orientacoes;
  final int valorCentavos;
  final FrequenciaMedicamento frequencia;
  final DateTime dataInicio;
  final DateTime? dataFim;
  final DateTime? sincronizadoAte;
  final List<String> animalIds;
  final Map<String, String> animalNomes;
  final bool ativo;
  final TipoTratamento tipo;

  double get valor => valorCentavos / 100;

  MedicamentoModel copyWith({
    String? id,
    DateTime? sincronizadoAte,
    bool? ativo,
    TipoTratamento? tipo,
  }) {
    return MedicamentoModel(
      id: id ?? this.id,
      nome: nome,
      dose: dose,
      orientacoes: orientacoes,
      valorCentavos: valorCentavos,
      frequencia: frequencia,
      dataInicio: dataInicio,
      dataFim: dataFim,
      sincronizadoAte: sincronizadoAte ?? this.sincronizadoAte,
      animalIds: animalIds,
      animalNomes: animalNomes,
      ativo: ativo ?? this.ativo,
      tipo: tipo ?? this.tipo,
    );
  }

  factory MedicamentoModel.fromMap(Map<String, dynamic> map, String id) {
    final frequencia = FrequenciaMedicamento.values.firstWhere(
      (item) => item.name == map['frequencia'],
      orElse: () => FrequenciaMedicamento.diario,
    );
    final tipo = TipoTratamento.values.firstWhere(
      (item) => item.name == map['tipo'],
      orElse: () => TipoTratamento.remedio,
    );
    final nomes = map['animalNomes'] is Map
        ? Map<String, String>.from(
            (map['animalNomes'] as Map).map(
              (key, value) => MapEntry(key.toString(), value.toString()),
            ),
          )
        : <String, String>{};
    return MedicamentoModel(
      id: id,
      nome: (map['nome'] ?? '').toString(),
      dose: (map['dose'] ?? '').toString(),
      orientacoes: (map['orientacoes'] ?? '').toString(),
      valorCentavos: map['valorCentavos'] is num
          ? (map['valorCentavos'] as num).round()
          : (((map['valor'] as num?) ?? 0) * 100).round(),
      frequencia: frequencia,
      dataInicio: _lerData(map['dataInicio']) ?? DateTime.now(),
      dataFim: _lerData(map['dataFim']),
      sincronizadoAte: _lerData(map['sincronizadoAte']),
      animalIds: List<String>.from(map['animalIds'] ?? const []),
      animalNomes: nomes,
      ativo: map['ativo'] != false,
      tipo: tipo,
    );
  }

  Map<String, dynamic> toMap() => {
    'nome': nome.trim(),
    'dose': dose.trim(),
    'orientacoes': orientacoes.trim(),
    'valorCentavos': valorCentavos,
    'valor': valor,
    'frequencia': frequencia.name,
    'dataInicio': Timestamp.fromDate(somenteData(dataInicio)),
    'dataFim': dataFim == null
        ? null
        : Timestamp.fromDate(somenteData(dataFim!)),
    'sincronizadoAte': sincronizadoAte == null
        ? null
        : Timestamp.fromDate(somenteData(sincronizadoAte!)),
    'animalIds': animalIds,
    'animalNomes': animalNomes,
    'ativo': ativo,
    'tipo': tipo.name,
    'atualizadoEm': FieldValue.serverTimestamp(),
  };

  List<DateTime> ocorrenciasPendentes(DateTime ate) {
    if (!ativo) return const [];
    final limiteHoje = somenteData(ate);
    final limite = dataFim == null
        ? limiteHoje
        : (somenteData(dataFim!).isBefore(limiteHoje)
              ? somenteData(dataFim!)
              : limiteHoje);
    final inicio = somenteData(dataInicio);
    if (inicio.isAfter(limite)) return const [];
    final sincronizado = sincronizadoAte == null
        ? null
        : somenteData(sincronizadoAte!);
    final resultado = <DateTime>[];

    void adicionar(DateTime data) {
      if (!data.isAfter(limite) &&
          (sincronizado == null || data.isAfter(sincronizado))) {
        resultado.add(data);
      }
    }

    if (frequencia == FrequenciaMedicamento.mensal) {
      for (var indice = 0; ; indice++) {
        final totalMes = inicio.month - 1 + indice;
        final ano = inicio.year + totalMes ~/ 12;
        final mes = totalMes % 12 + 1;
        final ultimoDia = DateTime(ano, mes + 1, 0).day;
        final data = DateTime(ano, mes, math.min(inicio.day, ultimoDia));
        if (data.isAfter(limite)) break;
        adicionar(data);
      }
      return resultado;
    }

    final dias = switch (frequencia) {
      FrequenciaMedicamento.diario => 1,
      FrequenciaMedicamento.semanal => 7,
      FrequenciaMedicamento.quinzenal => 15,
      FrequenciaMedicamento.mensal => 0,
    };
    for (
      var data = inicio;
      !data.isAfter(limite);
      data = data.add(Duration(days: dias))
    ) {
      adicionar(data);
    }
    return resultado;
  }

  static DateTime? _lerData(dynamic valor) {
    if (valor is Timestamp) return somenteData(valor.toDate());
    if (valor is DateTime) return somenteData(valor);
    return null;
  }
}
