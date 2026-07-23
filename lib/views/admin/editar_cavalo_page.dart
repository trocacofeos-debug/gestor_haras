import 'package:flutter/material.dart';

import '../../models/cavalo_model.dart';
import '../../services/cavalo_service.dart';

class EditarCavaloPage extends StatefulWidget {
  final CavaloModel cavalo;

  const EditarCavaloPage({
    super.key,
    required this.cavalo,
  });

  @override
  State<EditarCavaloPage> createState() =>
      _EditarCavaloPageState();
}

class _EditarCavaloPageState
    extends State<EditarCavaloPage> {
  final _formKey =
      GlobalKey<FormState>();

  final CavaloService service =
      CavaloService();

  late TextEditingController nome;
  late TextEditingController raca;
  late TextEditingController sexo;
  late TextEditingController pelagem;
  late TextEditingController registro;
  late TextEditingController idade;
  late TextEditingController descricao;
  late TextEditingController preco;

  bool destaque = false;
  bool vendido = false;

  bool salvando = false;

  @override
  void initState() {
    super.initState();

    nome = TextEditingController(
      text: widget.cavalo.nome,
    );

    raca = TextEditingController(
      text: widget.cavalo.raca,
    );

    sexo = TextEditingController(
      text: widget.cavalo.sexo,
    );

    pelagem = TextEditingController(
      text: widget.cavalo.pelagem,
    );

    registro = TextEditingController(
      text: widget.cavalo.registro,
    );

    idade = TextEditingController(
      text: widget.cavalo.idade.toString(),
    );

    descricao = TextEditingController(
      text: widget.cavalo.descricao,
    );

    preco = TextEditingController(
      text: widget.cavalo.preco.toString(),
    );

    destaque =
        widget.cavalo.destaque;

    vendido =
        widget.cavalo.vendido;
  }

  @override
  void dispose() {
    nome.dispose();
    raca.dispose();
    sexo.dispose();
    pelagem.dispose();
    registro.dispose();
    idade.dispose();
    descricao.dispose();
    preco.dispose();
    super.dispose();
  }

  Future<void> salvar() async {
    if (!_formKey.currentState!
        .validate()) {
      return;
    }

    setState(() {
      salvando = true;
    });

    try {
      final atualizado =
          widget.cavalo.copyWith(
        nome: nome.text.trim(),
        raca: raca.text.trim(),
        sexo: sexo.text.trim(),
        pelagem: pelagem.text.trim(),
        registro: registro.text.trim(),
        idade: int.tryParse(
              idade.text,
            ) ??
            0,
        descricao:
            descricao.text.trim(),
        preco: double.tryParse(
              preco.text.replaceAll(
                ",",
                ".",
              ),
            ) ??
            0,
        destaque: destaque,
        vendido: vendido,
        status: vendido
            ? "vendido"
            : "disponivel",
      );

      await service.atualizar(
        widget.cavalo.id!,
        atualizado,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            "Cavalo atualizado com sucesso",
          ),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            "Erro: $e",
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          salvando = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xffF7F4F0),

      appBar: AppBar(
        title: const Text(
          "Editar Cavalo",
        ),
        backgroundColor:
            const Color(0xFF5D4037),
        foregroundColor:
            Colors.white,
      ),

      body: SingleChildScrollView(
        padding:
            const EdgeInsets.all(16),

        child: Form(
          key: _formKey,

          child: Column(
            children: [
              campo(
                "Nome",
                nome,
                Icons.pets,
              ),

              campo(
                "Raça",
                raca,
                Icons.category,
              ),

              campo(
                "Sexo",
                sexo,
                Icons.male,
              ),

              campo(
                "Pelagem",
                pelagem,
                Icons.color_lens,
              ),

              campo(
                "Registro",
                registro,
                Icons.badge,
              ),

                            campo(
                "Idade",
                idade,
                Icons.calendar_month,
                teclado:
                    TextInputType.number,
              ),

              campo(
                "Preço",
                preco,
                Icons.attach_money,
                teclado:
                    TextInputType.number,
              ),

              campo(
                "Descrição",
                descricao,
                Icons.description,
                linhas: 4,
              ),

              const SizedBox(
                height: 20,
              ),

              SwitchListTile(
                title: const Text(
                  "Cavalo em destaque",
                ),
                subtitle: const Text(
                  "Mostrar na área premium",
                ),
                value: destaque,
                activeThumbColor:
                    const Color(
                  0xFF5D4037,
                ),
                onChanged: (value) {
                  setState(() {
                    destaque = value;
                  });
                },
              ),

              SwitchListTile(
                title: const Text(
                  "Cavalo vendido",
                ),
                subtitle: const Text(
                  "Marcar como vendido",
                ),
                value: vendido,
                activeThumbColor:
                    Colors.red,
                onChanged: (value) {
                  setState(() {
                    vendido = value;
                  });
                },
              ),

              const SizedBox(
                height: 30,
              ),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton.icon(
                  icon: salvando
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child:
                              CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(
                          Icons.save,
                        ),
                  label: Text(
                    salvando
                        ? "Salvando..."
                        : "Salvar Alterações",
                  ),
                  onPressed:
                      salvando
                          ? null
                          : salvar,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget campo(
    String label,
    TextEditingController controller,
    IconData icon, {
    TextInputType? teclado,
    int linhas = 1,
  }) {
    return Padding(
      padding:
          const EdgeInsets.only(
        bottom: 12,
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: teclado,
        maxLines: linhas,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(
            icon,
          ),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(
              15,
            ),
            borderSide:
                BorderSide.none,
          ),
        ),
        validator: (value) {
          if (value == null ||
              value.trim().isEmpty) {
            return "Informe $label";
          }

          return null;
        },
      ),
    );
  }
}