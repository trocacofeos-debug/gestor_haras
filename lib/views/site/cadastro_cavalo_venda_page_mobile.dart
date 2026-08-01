// ignore_for_file: deprecated_member_use

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../models/cavalo_venda_model.dart';
import '../../services/cloudflare_r2_service.dart';
import '../home/admin_top_bar.dart';

class CadastroCavaloVendaPageDesktop extends StatefulWidget {
  final CavaloVendaModel? cavaloParaEditar;

  const CadastroCavaloVendaPageDesktop({super.key, this.cavaloParaEditar});

  @override
  State<CadastroCavaloVendaPageDesktop> createState() =>
      _CadastroCavaloVendaPageDesktopState();
}

class _CadastroCavaloVendaPageDesktopState extends State<CadastroCavaloVendaPageDesktop> {
  final _formKey = GlobalKey<FormState>();
  final _r2 = CloudflareR2Service();

  final nomeController = TextEditingController();
  final valorController = TextEditingController();
  final pelagemController = TextEditingController();
  final idadeController = TextEditingController();
  final racaController = TextEditingController();
  final descricaoController = TextEditingController();

  String sexo = 'Macho';

  List<String> fotosExistentes = [];
  List<PlatformFile> fotosNovas = [];

  bool salvando = false;
  bool enviandoFotos = false;

  bool get editando => widget.cavaloParaEditar != null;

  static const Color primaria = Color(0xFF4F46E5);
  static const Color fundo = Color(0xFFF3F4F6);

  @override
  void initState() {
    super.initState();

    final c = widget.cavaloParaEditar;

    if (c != null) {
      nomeController.text = c.nome;
      valorController.text = c.valor.toStringAsFixed(2);
      pelagemController.text = c.pelagem;
      idadeController.text = c.idade > 0 ? c.idade.toString() : '';
      racaController.text = c.raca;
      descricaoController.text = c.descricao;
      sexo = c.sexo.isEmpty ? 'Macho' : c.sexo;
      fotosExistentes = List<String>.from(c.fotos);
    }
  }

  @override
  void dispose() {
    nomeController.dispose();
    valorController.dispose();
    pelagemController.dispose();
    idadeController.dispose();
    racaController.dispose();
    descricaoController.dispose();
    super.dispose();
  }

  double get valorNumero =>
      double.tryParse(
        valorController.text.replaceAll('.', '').replaceAll(',', '.'),
      ) ??
      0;

  Future<void> selecionarFotos() async {
    final resultado = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: true,
      withData: true,
    );

    if (resultado == null) return;

    setState(() {
      fotosNovas.addAll(resultado.files);
    });
  }

  void removerFotoExistente(String url) {
    setState(() {
      fotosExistentes.remove(url);
    });
  }

  void removerFotoNova(PlatformFile arquivo) {
    setState(() {
      fotosNovas.remove(arquivo);
    });
  }

  Future<void> salvar() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      salvando = true;
    });

    try {
      var urlsFinais = List<String>.from(fotosExistentes);

      if (fotosNovas.isNotEmpty) {
        setState(() {
          enviandoFotos = true;
        });

        final novasUrls = await _r2.uploadMultiplosArquivos(
          arquivos: fotosNovas,
          pasta: 'cavalos_venda',
        );

        urlsFinais.addAll(novasUrls);

        setState(() {
          enviandoFotos = false;
        });
      }

      final cavalo = CavaloVendaModel(
        id: widget.cavaloParaEditar?.id ?? '',
        nome: nomeController.text.trim(),
        raca: racaController.text.trim(),
        sexo: sexo,
        pelagem: pelagemController.text.trim(),
        idade: int.tryParse(idadeController.text.trim()) ?? 0,
        valor: valorNumero,
        fotos: urlsFinais,
        descricao: descricaoController.text.trim(),
        dataCadastro:
            widget.cavaloParaEditar?.dataCadastro ?? Timestamp.now(),
      );

      if (editando) {
        await FirebaseFirestore.instance
            .collection('cavalos_venda')
            .doc(cavalo.id)
            .update(cavalo.toMap());
      } else {
        await FirebaseFirestore.instance
            .collection('cavalos_venda')
            .add(cavalo.toMap());
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            editando
                ? 'Cavalo atualizado com sucesso'
                : 'Cavalo publicado com sucesso',
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
          enviandoFotos = false;
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

  Widget _fotosSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.photo_library_outlined, color: primaria),
              const SizedBox(width: 8),
              const Text(
                'Fotos',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: selecionarFotos,
                icon: const Icon(Icons.add_photo_alternate_outlined),
                label: const Text('Adicionar'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (fotosExistentes.isEmpty && fotosNovas.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Text(
                  'Nenhuma foto selecionada',
                  style: TextStyle(color: Colors.grey.shade500),
                ),
              ),
            )
          else
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                ...fotosExistentes.map((url) {
                  return Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          url,
                          width: 90,
                          height: 90,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 2,
                        right: 2,
                        child: InkWell(
                          onTap: () => removerFotoExistente(url),
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(
                              color: Colors.black54,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              size: 14,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }),
                ...fotosNovas.map((arquivo) {
                  return Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: arquivo.bytes != null
                            ? Image.memory(
                                arquivo.bytes!,
                                width: 90,
                                height: 90,
                                fit: BoxFit.cover,
                              )
                            : Container(
                                width: 90,
                                height: 90,
                                color: primaria.withOpacity(.1),
                                child: const Icon(Icons.image_outlined),
                              ),
                      ),
                      Positioned(
                        top: 2,
                        right: 2,
                        child: InkWell(
                          onTap: () => removerFotoNova(arquivo),
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(
                              color: Colors.black54,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              size: 14,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }),
              ],
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: fundo,
      body: Column(
        children: [
          const AdminTopBar(),
          Container(
            height: 56,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            color: Colors.white,
            alignment: Alignment.centerLeft,
            child: Text(
              editando ? 'Editar Cavalo à Venda' : 'Novo Cavalo à Venda',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ),
          Expanded(
            child: Form(
              key: _formKey,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 700),
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
                    editando ? 'Editar Cavalo à Venda' : 'Novo Cavalo à Venda',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Esse cavalo vai aparecer no site público.',
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _fotosSection(),
            const SizedBox(height: 16),
            campo(
              label: 'Nome',
              icon: Icons.badge_outlined,
              controller: nomeController,
            ),
            campo(
              label: 'Valor (R\$)',
              icon: Icons.attach_money,
              controller: valorController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            campo(
              label: 'Raça',
              icon: Icons.category_outlined,
              controller: racaController,
              required: false,
            ),
            campo(
              label: 'Pelagem',
              icon: Icons.palette_outlined,
              controller: pelagemController,
              required: false,
            ),
            campo(
              label: 'Idade (anos)',
              icon: Icons.cake_outlined,
              controller: idadeController,
              required: false,
              keyboardType: TextInputType.number,
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: DropdownButtonFormField<String>(
                  value: sexo,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    prefixIcon: Icon(Icons.male, color: primaria),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'Macho', child: Text('Macho')),
                    DropdownMenuItem(value: 'Fêmea', child: Text('Fêmea')),
                  ],
                  onChanged: (v) {
                    setState(() {
                      sexo = v ?? 'Macho';
                    });
                  },
                ),
              ),
            ),
            campo(
              label: 'Descrição',
              icon: Icons.notes_outlined,
              controller: descricaoController,
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
                      ? (enviandoFotos ? 'ENVIANDO FOTOS...' : 'SALVANDO...')
                      : (editando ? 'SALVAR ALTERAÇÕES' : 'PUBLICAR CAVALO'),
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
        ),
      ),
    ),
        ],
      ),
    );
  }
}