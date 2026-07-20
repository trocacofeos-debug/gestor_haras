import 'package:cloud_firestore/cloud_firestore.dart';

enum TipoCliente { fisica, juridica, rural }

class ClienteModel {
  final String id;
  final TipoCliente tipoCliente;

  final String nome;
  final String sobrenome;

  final String razaoSocial;
  final String nomeFantasia;

  final String cpfCnpj;
  final String telefone;
  final String email;

  final String cep;
  final String endereco;
  final String numero;
  final String complemento;
  final String bairro;
  final String cidade;
  final String estado;

  final String nomeHaras;
  final String idRural;

  final String enderecoHaras;
  final String cidadeHaras;
  final String estadoHaras;

  final bool ativo;
  final Timestamp dataCadastro;

  ClienteModel({
    required this.id,
    required this.tipoCliente,
    this.nome = '',
    this.sobrenome = '',
    this.razaoSocial = '',
    this.nomeFantasia = '',
    this.cpfCnpj = '',
    this.telefone = '',
    this.email = '',
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
    this.ativo = true,
    required this.dataCadastro,
  });

  factory ClienteModel.fromMap(Map<String, dynamic> map, String id) {
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
      cpfCnpj: map['cpfCnpj'] ?? '',
      telefone: map['telefone'] ?? '',
      email: map['email'] ?? '',
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
      ativo: map['ativo'] ?? true,
      dataCadastro: map['dataCadastro'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'tipoCliente': tipoCliente.name,
      'nome': nome,
      'sobrenome': sobrenome,
      'razaoSocial': razaoSocial,
      'nomeFantasia': nomeFantasia,
      'cpfCnpj': cpfCnpj,
      'telefone': telefone,
      'email': email,
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
      'ativo': ativo,
      'dataCadastro': dataCadastro,
    };
  }

  String get nomeExibicao {
    switch (tipoCliente) {
      case TipoCliente.fisica:
        return '$nome $sobrenome';
      case TipoCliente.juridica:
        return razaoSocial;
      case TipoCliente.rural:
        return nomeHaras.isNotEmpty ? nomeHaras : '$nome $sobrenome';
    }
  }
}