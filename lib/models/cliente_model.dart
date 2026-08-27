import 'package:cloud_firestore/cloud_firestore.dart';

enum TipoCliente {
  fisica,
  juridica,
  rural,
}

class ClienteModel {
  final String id;

  final TipoCliente tipoCliente;

  // Pessoa Física
  final String nome;
  final String sobrenome;

  // Pessoa Jurídica
  final String razaoSocial;
  final String nomeFantasia;
  final String inscricaoEstadual;

  // Documento
  final String cpfCnpj;

  final String telefone;
  final String email;

  // Data de nascimento (necessária para o ClickSign
  // identificar o signatário na assinatura do contrato)
  final Timestamp? dataNascimento;

  // Endereço Principal
  final String cep;
  final String endereco;
  final String numero;
  final String complemento;
  final String bairro;
  final String cidade;
  final String estado;

  // Dados do Haras / Fazenda
  final String nomeHaras;
  final String idRural;
  final String enderecoHaras;
  final String cidadeHaras;
  final String estadoHaras;

  final String ccir;
  final String itr;
  final String areaPropriedade;

  final bool ativo;

  final Timestamp dataCadastro;

  const ClienteModel({
    required this.id,
    required this.tipoCliente,

    this.nome = '',
    this.sobrenome = '',

    this.razaoSocial = '',
    this.nomeFantasia = '',
    this.inscricaoEstadual = '',

    this.cpfCnpj = '',

    this.telefone = '',
    this.email = '',
    this.dataNascimento,

    this.cep = '',
    this.endereco = '',
    this.numero = '',
    this.complemento = '',
    this.bairro = '',
    this.cidade = '',
    this.estado = '',

    this.nomeHaras = '',
    this.idRural = '',
    this.enderecoHaras = '',
    this.cidadeHaras = '',
    this.estadoHaras = '',

    this.ccir = '',
    this.itr = '',
    this.areaPropriedade = '',

    this.ativo = true,

    required this.dataCadastro,
  });

  factory ClienteModel.fromMap(
    Map<String, dynamic> map,
    String id,
  ) {
    return ClienteModel(
      id: id,

      tipoCliente: TipoCliente.values.firstWhere(
        (e) => e.name == (map['tipoCliente'] ?? 'fisica'),
        orElse: () => TipoCliente.fisica,
      ),

      nome: map['nome'] ?? '',
      sobrenome: map['sobrenome'] ?? '',

      razaoSocial: map['razaoSocial'] ?? '',
      nomeFantasia: map['nomeFantasia'] ?? '',
      inscricaoEstadual: map['inscricaoEstadual'] ?? '',

      cpfCnpj: map['cpfCnpj'] ?? '',

      telefone: map['telefone'] ?? '',
      email: map['email'] ?? '',
      dataNascimento: map['dataNascimento'] is Timestamp
          ? map['dataNascimento']
          : null,

      cep: map['cep'] ?? '',
      endereco: map['endereco'] ?? '',
      numero: map['numero'] ?? '',
      complemento: map['complemento'] ?? '',
      bairro: map['bairro'] ?? '',
      cidade: map['cidade'] ?? '',
      estado: map['estado'] ?? '',

      nomeHaras: map['nomeHaras'] ?? '',
      idRural: map['idRural'] ?? '',
      enderecoHaras: map['enderecoHaras'] ?? '',
      cidadeHaras: map['cidadeHaras'] ?? '',
      estadoHaras: map['estadoHaras'] ?? '',

      ccir: map['ccir'] ?? '',
      itr: map['itr'] ?? '',
      areaPropriedade: map['areaPropriedade'] ?? '',

      ativo: map['ativo'] ?? true,

      dataCadastro: map['dataCadastro'] is Timestamp
          ? map['dataCadastro']
          : Timestamp.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'tipoCliente': tipoCliente.name,

      'nome': nome,
      'sobrenome': sobrenome,

      'razaoSocial': razaoSocial,
      'nomeFantasia': nomeFantasia,
      'inscricaoEstadual': inscricaoEstadual,

      'cpfCnpj': cpfCnpj,

      'telefone': telefone,
      'email': email,
      'dataNascimento': dataNascimento,

      'cep': cep,
      'endereco': endereco,
      'numero': numero,
      'complemento': complemento,
      'bairro': bairro,
      'cidade': cidade,
      'estado': estado,

      'nomeHaras': nomeHaras,
      'idRural': idRural,
      'enderecoHaras': enderecoHaras,
      'cidadeHaras': cidadeHaras,
      'estadoHaras': estadoHaras,

      'ccir': ccir,
      'itr': itr,
      'areaPropriedade': areaPropriedade,

      'ativo': ativo,

      'dataCadastro': dataCadastro,
    };
  }

  String get nomeExibicao {
    if (tipoCliente == TipoCliente.fisica) {
      return '$nome $sobrenome'.trim();
    }

    if (nomeHaras.isNotEmpty) {
      return nomeHaras;
    }

    if (razaoSocial.isNotEmpty) {
      return razaoSocial;
    }

    return nomeFantasia;
  }

  // Compatibilidade

  String get documento => cpfCnpj;

  String get harasNome => nomeHaras;

  String get propriedadeNome => nomeHaras;

  bool get isAtivo => ativo;
}