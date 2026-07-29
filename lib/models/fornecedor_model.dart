import 'package:cloud_firestore/cloud_firestore.dart';

class FornecedorModel {
  final String id;

  final String nome;
  final String cpfCnpj;
  final String categoria;
  final String telefone;
  final String email;
  final String endereco;

  final String observacoes;

  final bool ativo;

  final Timestamp? dataCadastro;

  const FornecedorModel({
    required this.id,
    this.nome = '',
    this.cpfCnpj = '',
    this.categoria = '',
    this.telefone = '',
    this.email = '',
    this.endereco = '',
    this.observacoes = '',
    this.ativo = true,
    this.dataCadastro,
  });

  factory FornecedorModel.fromMap(
    Map<String, dynamic> map,
    String id,
  ) {
    return FornecedorModel(
      id: id,
      nome: map['nome'] ?? '',
      cpfCnpj: map['cpfCnpj'] ?? '',
      categoria: map['categoria'] ?? '',
      telefone: map['telefone'] ?? '',
      email: map['email'] ?? '',
      endereco: map['endereco'] ?? '',
      observacoes: map['observacoes'] ?? '',
      ativo: map['ativo'] ?? true,
      dataCadastro: map['dataCadastro'] as Timestamp?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'cpfCnpj': cpfCnpj,
      'categoria': categoria,
      'telefone': telefone,
      'email': email,
      'endereco': endereco,
      'observacoes': observacoes,
      'ativo': ativo,
      'dataCadastro': dataCadastro ?? Timestamp.now(),
    };
  }
}