// ignore_for_file: unused_field, unnecessary_underscores

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../../widgets/app_dialogs.dart';

import '../../models/imagem_galeria_model.dart';
import '../../services/cloudflare_r2_service.dart';
import '../home/admin_top_bar.dart';
import '../../widgets/site_admin_header.dart';

class GaleriaPageDesktop extends StatefulWidget {
  const GaleriaPageDesktop({super.key});

  @override
  State<GaleriaPageDesktop> createState() => _GaleriaPageDesktopState();
}

class _GaleriaPageDesktopState extends State<GaleriaPageDesktop> {
  final _r2 = CloudflareR2Service();

  bool enviando = false;

  static const Color primaria = Color(0xFF4F46E5);
  static const Color fundo = Color(0xFFF3F4F6);
  static const Color corTextoPrimario = Color(0xFF111827);
  static const Color corTextoSecundario = Color(0xFF6B7280);
  static const Color corBorda = Color(0xFFE5E7EB);

  Future<void> _adicionarImagens() async {
    final resultado = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: true,
      withData: true,
    );

    if (resultado == null || resultado.files.isEmpty) return;

    setState(() {
      enviando = true;
    });

    try {
      final urls = await _r2.uploadMultiplosArquivos(
        arquivos: resultado.files,
        pasta: 'galeria',
      );

      for (final url in urls) {
        final imagem = ImagemGaleriaModel(
          id: '',
          url: url,
          dataUpload: Timestamp.now(),
        );

        await FirebaseFirestore.instance
            .collection('galeria')
            .add(imagem.toMap());
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            urls.length == 1
                ? 'Imagem adicionada à galeria'
                : '${urls.length} imagens adicionadas à galeria',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro no upload: $e')));
    } finally {
      if (mounted) {
        setState(() {
          enviando = false;
        });
      }
    }
  }

  Future<void> _excluir(ImagemGaleriaModel imagem) async {
    final confirmar = await showAppDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remover da galeria'),
        content: const Text('Deseja remover esta imagem do site?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Remover'),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    try {
      await _r2.excluirArquivo(arquivoUrl: imagem.url);
    } catch (_) {
      // mesmo se falhar ao apagar do R2, removemos o registro
      // pra não deixar item "quebrado" na galeria.
    }

    await FirebaseFirestore.instance
        .collection('galeria')
        .doc(imagem.id)
        .delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: fundo,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: primaria,
        icon: enviando
            ? const SizedBox(
                height: 18,
                width: 18,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Icon(
                Icons.add_photo_alternate_outlined,
                color: Colors.white,
              ),
        label: Text(
          enviando ? 'Enviando...' : 'Adicionar Imagens',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        onPressed: enviando ? null : _adicionarImagens,
      ),
      body: Column(
        children: [
          const AdminTopBar(),
          const SiteAdminHeader(
            title: 'Galeria',
            subtitle: 'Organize as imagens que apresentam o haras ao público',
            icon: Icons.photo_library_rounded,
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection('galeria')
                  .orderBy('dataUpload', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Erro: ${snapshot.error}'));
                }

                final imagens = (snapshot.data?.docs ?? [])
                    .map(
                      (doc) => ImagemGaleriaModel.fromMap(doc.data(), doc.id),
                    )
                    .toList();

                if (imagens.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.photo_library_outlined,
                          size: 50,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Nenhuma imagem na galeria ainda',
                          style: TextStyle(color: corTextoSecundario),
                        ),
                      ],
                    ),
                  );
                }

                return LayoutBuilder(
                  builder: (context, constraints) {
                    final colunas = constraints.maxWidth >= 1200
                        ? 5
                        : constraints.maxWidth >= 900
                        ? 4
                        : constraints.maxWidth >= 600
                        ? 3
                        : 2;

                    return GridView.builder(
                      padding: const EdgeInsets.fromLTRB(24, 20, 24, 96),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: colunas,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1,
                      ),
                      itemCount: imagens.length,
                      itemBuilder: (context, index) {
                        final imagem = imagens[index];

                        return Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.network(
                                imagem.url,
                                width: double.infinity,
                                height: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  color: corBorda,
                                  child: const Icon(
                                    Icons.broken_image_outlined,
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              top: 6,
                              right: 6,
                              child: InkWell(
                                onTap: () => _excluir(imagem),
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: const Color(0xDD0F172A),
                                    borderRadius: BorderRadius.circular(9),
                                    border: Border.all(color: Colors.white24),
                                  ),
                                  child: const Icon(
                                    Icons.delete_outline,
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

