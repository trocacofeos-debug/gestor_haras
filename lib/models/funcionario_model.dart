import 'package:cloud_firestore/cloud_firestore.dart';

class FuncionarioModel {
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

  factory FuncionarioModel.fromMap(
    Map<String, dynamic> map,
    String id,
  ) {
    return FuncionarioModel(
      id: id,
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