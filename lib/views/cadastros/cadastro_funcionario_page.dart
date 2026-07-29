import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../models/funcionario_model.dart';

class CadastroFuncionarioPage extends StatefulWidget {
  final FuncionarioModel? funcionarioParaEditar;

  const CadastroFuncionarioPage({super.key, this.funcionarioParaEditar});

  @override
  State<CadastroFuncionarioPage> createState() =>
      _CadastroFuncionarioPageState();
}

class _CadastroFuncionarioPageState extends State<CadastroFuncionarioPage> {
  final _formKey = GlobalKey<FormState>();

  final nomeController = TextEditingController();
  final cargoController = TextEditingController();
  final cpfController = TextEditingController();
  final telefoneController = TextEditingController();
  final emailController = TextEditingController();
  final salarioController = TextEditingController();
  final observacoesController = TextEditingController();

  DateTime dataAdmissao = DateTime.now();

  bool salvando = false;

  bool get editando => widget.funcionarioParaEditar != null;

  static const Color primaria = Color(0xFF4F46E5);
  static const Color fundo = Color(0xFFF3F4F6);

  @override
  void initState() {
    super.initState();

    final f = widget.funcionarioParaEditar;

    if (f != null) {
      nomeController.text = f.nome;
      cargoController.text = f.cargo;
      cpfController.text = f.cpf;
      telefoneController.text = f.telefone;
      emailController.text = f.email;
      salarioController.text = f.salario.toStringAsFixed(2);
      observacoesController.text = f.observacoes;
      dataAdmissao = f.dataAdmissao?.toDate() ?? DateTime.now();
    }
  }

  @override
  void dispose() {
    nomeController.dispose();
    cargoController.dispose();
    cpfController.dispose();
    telefoneController.dispose();
    emailController.dispose();
    salarioController.dispose();
    observacoesController.dispose();
    super.dispose();
  }

  double get salario =>
      double.tryParse(
        salarioController.text.replaceAll('.', '').replaceAll(',', '.'),
      ) ??
      0;

  Future<void> escolherDataAdmissao() async {
    final data = await showDatePicker(
      context: context,
      initialDate: dataAdmissao,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (data != null) {
      setState(() {
        dataAdmissao = data;
      });
    }
  }

  Future<void> salvar() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      salvando = true;
    });

    try {
      final funcionario = FuncionarioModel(
        id: widget.funcionarioParaEditar?.id ?? '',
        nome: nomeController.text.trim(),
        cargo: cargoController.text.trim(),
        cpf: cpfController.text.trim(),
        telefone: telefoneController.text.trim(),
        email: emailController.text.trim(),
        salario: salario,
        observacoes: observacoesController.text.trim(),
        dataAdmissao: Timestamp.fromDate(dataAdmissao),
        dataCadastro:
            widget.funcionarioParaEditar?.dataCadastro ?? Timestamp.now(),
      );

      if (editando) {
        await FirebaseFirestore.instance
            .collection('funcionarios')
            .doc(funcionario.id)
            .update(funcionario.toMap());
      } else {
        await FirebaseFirestore.instance
            .collection('funcionarios')
            .add(funcionario.toMap());
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            editando
                ? 'Funcionário atualizado com sucesso'
                : 'Funcionário cadastrado com sucesso',
          ),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          salvando = false;
        });
      }
    }
  }

  Widget campo({
    required String label,
    required IconData icon,
    required TextEditingController controller,
    bool required = true,
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: required
            ? (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Campo obrigatório';
                }
                return null;
              }
            : null,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: primaria),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: fundo,
      appBar: AppBar(
        backgroundColor: primaria,
        foregroundColor: Colors.white,
        title: Text(editando ? 'Editar Funcionário' : 'Cadastro de Funcionário'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF4F46E5), Color(0xFF7C7AF0)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    editando ? 'Editar Funcionário' : 'Novo Funcionário',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    editando
                        ? 'Atualize os dados do funcionário.'
                        : 'Cadastre os dados do funcionário.',
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            campo(
              label: 'Nome completo',
              icon: Icons.person_outline,
              controller: nomeController,
            ),

            campo(
              label: 'Cargo',
              icon: Icons.work_outline,
              controller: cargoController,
            ),

            campo(
              label: 'CPF',
              icon: Icons.badge_outlined,
              controller: cpfController,
              keyboardType: TextInputType.number,
              required: false,
            ),

            campo(
              label: 'Telefone',
              icon: Icons.phone_outlined,
              controller: telefoneController,
              keyboardType: TextInputType.phone,
              required: false,
            ),

            campo(
              label: 'Email',
              icon: Icons.email_outlined,
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              required: false,
            ),

            campo(
              label: 'Salário',
              icon: Icons.attach_money,
              controller: salarioController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              required: false,
            ),

            InkWell(
              onTap: escolherDataAdmissao,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.event, color: primaria),
                    const SizedBox(width: 12),
                    Text(
                      'Admissão: '
                      '${dataAdmissao.day.toString().padLeft(2, '0')}/'
                      '${dataAdmissao.month.toString().padLeft(2, '0')}/'
                      '${dataAdmissao.year}',
                    ),
                  ],
                ),
              ),
            ),

            campo(
              label: 'Observações',
              icon: Icons.notes_outlined,
              controller: observacoesController,
              required: false,
            ),

            const SizedBox(height: 20),

            SizedBox(
              height: 55,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaria,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: salvando ? null : salvar,
                icon: salvando
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.save, color: Colors.white),
                label: Text(
                  salvando
                      ? 'SALVANDO...'
                      : (editando
                          ? 'SALVAR ALTERAÇÕES'
                          : 'CADASTRAR FUNCIONÁRIO'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}