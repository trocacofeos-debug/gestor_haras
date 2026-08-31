import 'package:cloud_firestore/cloud_firestore.dart';

class FuncionarioModel {
  static const camposAdicionais = <String, String>{
    'matricula': 'Matrícula',
    'tipoVinculo': 'Tipo de vínculo',
    'jornada': 'Jornada / horário',
    'ctpsNumero': 'Carteira de trabalho (número)',
    'ctpsSerie': 'Série da CTPS',
    'ctpsUf': 'UF da CTPS',
    'pisPasep': 'PIS / PASEP',
    'cep': 'CEP',
    'endereco': 'Endereço',
    'numero': 'Número',
    'complemento': 'Complemento',
    'bairro': 'Bairro',
    'cidade': 'Cidade',
    'estado': 'UF',
    'emergenciaNome': 'Contato de emergência',
    'emergenciaTelefone': 'Telefone de emergência',
    'emergenciaParentesco': 'Parentesco / relação',
  };
  final String matricula;
  final String tipoVinculo;
  final String jornada;
  final String ctpsNumero;
  final String ctpsSerie;
  final String ctpsUf;
  final String pisPasep;
  final String cep;
  final String endereco;
  final String numero;
  final String complemento;
  final String bairro;
  final String cidade;
  final String estado;
  final String emergenciaNome;
  final String emergenciaTelefone;
  final String emergenciaParentesco;
  final String fotoUrl;
  final Timestamp? dataNascimento;
  final Timestamp? dataDesligamento;
  final String id;

  final String nome;
  final String cargo;
  final String cpf;
  final String telefone;
  final String email;

  final double salario;

  final String observacoes;

  final bool ativo;

  final Timestamp? dataAdmissao;
  final Timestamp? dataCadastro;

  const FuncionarioModel({
    required this.id,
    this.matricula = '',
    this.tipoVinculo = '',
    this.jornada = '',
    this.ctpsNumero = '',
    this.ctpsSerie = '',
    this.ctpsUf = '',
    this.pisPasep = '',
    this.cep = '',
    this.endereco = '',
    this.numero = '',
    this.complemento = '',
    this.bairro = '',
    this.cidade = '',
    this.estado = '',
    this.emergenciaNome = '',
    this.emergenciaTelefone = '',
    this.emergenciaParentesco = '',
    this.fotoUrl = '',
    this.dataNascimento,
    this.dataDesligamento,
    this.nome = '',
    this.cargo = '',
    this.cpf = '',
    this.telefone = '',
    this.email = '',
    this.salario = 0,
    this.observacoes = '',
    this.ativo = true,
    this.dataAdmissao,
    this.dataCadastro,
  });

  factory FuncionarioModel.fromMap(Map<String, dynamic> map, String id) {
    return FuncionarioModel(
      id: id,
      matricula: map['matricula'] as String? ?? '',
      tipoVinculo: map['tipoVinculo'] as String? ?? '',
      jornada: map['jornada'] as String? ?? '',
      ctpsNumero: map['ctpsNumero'] as String? ?? '',
      ctpsSerie: map['ctpsSerie'] as String? ?? '',
      ctpsUf: map['ctpsUf'] as String? ?? '',
      pisPasep: map['pisPasep'] as String? ?? '',
      cep: map['cep'] as String? ?? '',
      endereco: map['endereco'] as String? ?? '',
      numero: map['numero'] as String? ?? '',
      complemento: map['complemento'] as String? ?? '',
      bairro: map['bairro'] as String? ?? '',
      cidade: map['cidade'] as String? ?? '',
      estado: map['estado'] as String? ?? '',
      emergenciaNome: map['emergenciaNome'] as String? ?? '',
      emergenciaTelefone: map['emergenciaTelefone'] as String? ?? '',
      emergenciaParentesco: map['emergenciaParentesco'] as String? ?? '',
      fotoUrl: map['fotoUrl'] as String? ?? '',
      dataNascimento: map['dataNascimento'] as Timestamp?,
      dataDesligamento: map['dataDesligamento'] as Timestamp?,
      nome: map['nome'] ?? '',
      cargo: map['cargo'] ?? '',
      cpf: map['cpf'] ?? '',
      telefone: map['telefone'] ?? '',
      email: map['email'] ?? '',
      salario: (map['salario'] ?? 0).toDouble(),
      observacoes: map['observacoes'] ?? '',
      ativo: map['ativo'] ?? true,
      dataAdmissao: map['dataAdmissao'] as Timestamp?,
      dataCadastro: map['dataCadastro'] as Timestamp?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'matricula': matricula,
      'tipoVinculo': tipoVinculo,
      'jornada': jornada,
      'ctpsNumero': ctpsNumero,
      'ctpsSerie': ctpsSerie,
      'ctpsUf': ctpsUf,
      'pisPasep': pisPasep,
      'cep': cep,
      'endereco': endereco,
      'numero': numero,
      'complemento': complemento,
      'bairro': bairro,
      'cidade': cidade,
      'estado': estado,
      'emergenciaNome': emergenciaNome,
      'emergenciaTelefone': emergenciaTelefone,
      'emergenciaParentesco': emergenciaParentesco,
      'fotoUrl': fotoUrl,
      'dataNascimento': dataNascimento,
      'dataDesligamento': dataDesligamento,
      'cargo': cargo,
      'cpf': cpf,
      'telefone': telefone,
      'email': email,
      'salario': salario,
      'observacoes': observacoes,
      'ativo': ativo,
      'dataAdmissao': dataAdmissao,
      'dataCadastro': dataCadastro ?? Timestamp.now(),
    };
  }
}
