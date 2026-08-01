// ignore_for_file: deprecated_member_use, unnecessary_non_null_assertion

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../models/noticia_model.dart';
import '../../services/cloudflare_r2_service.dart';
import '../home/admin_top_bar.dart';

class NoticiasPageDesktop extends StatefulWidget {
  const NoticiasPageDesktop({super.key});

  @override
  State<NoticiasPageDesktop> createState() => _NoticiasPageDesktopState();
}

class _NoticiasPageDesktopState extends State<NoticiasPageDesktop> {
  final _r2 = CloudflareR2Service();

  static const Color primaria = Color(0xFF4F46E5);
  static const Color fundo = Color(0xFFF3F4F6);
  static const Color corTextoPrimario = Color(0xFF111827);
  static const Color corTextoSecundario = Color(0xFF6B7280);
  static const Color corBorda = Color(0xFFE5E7EB);

  Future<void> _abrirFormulario({NoticiaModel? noticiaParaEditar}) async {
    final tituloController =
        TextEditingController(text: noticiaParaEditar?.titulo ?? '');
    final linkController =
        TextEditingController(text: noticiaParaEditar?.link ?? '');
    final descricaoController =
        TextEditingController(text: noticiaParaEditar?.descricao ?? '');

    PlatformFile? arquivoSelecionado;
    String? imagemAtualUrl = noticiaParaEditar?.imagemUrl;
    bool enviando = false;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: Text(
                noticiaParaEditar == null ? 'Nova Notícia' : 'Editar Notícia',
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InkWell(
                      onTap: () async {
                        final resultado = await FilePicker.platform.pickFiles(
                          type: FileType.image,
                          withData: true,
                        );

                        if (resultado != null && resultado.files.isNotEmpty) {
                          setStateDialog(() {
                            arquivoSelecionado = resultado.files.first;
                          });
                        }
                      },
                      child: Container(
                        height: 140,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: primaria.withOpacity(.06),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: corBorda),
                        ),
                        child: arquivoSelecionado?.bytes != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.memory(
                                  arquivoSelecionado!.bytes!,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
                                ),
                              )
                            : (imagemAtualUrl != null &&
                                    imagemAtualUrl!.isNotEmpty)
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.network(
                                      imagemAtualUrl!,
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      height: double.infinity,
                                    ),
                                  )
                                : Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.add_photo_alternate_outlined,
                                        color: primaria,
                                        size: 32,
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        'Toque para escolher o banner',
                                        style: TextStyle(
                                          color: Colors.grey.shade600,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: tituloController,
                      decoration: const InputDecoration(
                        labelText: 'Título',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: linkController,
                      decoration: const InputDecoration(
                        labelText: 'Link (opcional)',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: descricaoController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Descrição (opcional)',
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed:
                      enviando ? null : () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: primaria),
                  onPressed: enviando
                      ? null
                      : () async {
                          if (tituloController.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Informe um título'),
                              ),
                            );
                            return;
                          }

                          setStateDialog(() {
                            enviando = true;
                          });

                          try {
                            String urlFinal = imagemAtualUrl ?? '';

                            if (arquivoSelecionado != null) {
                              urlFinal = await _r2.uploadArquivo(
                                arquivo: arquivoSelecionado!,
                                pasta: 'noticias',
                              );
                            }

                            final noticia = NoticiaModel(
                              id: noticiaParaEditar?.id ?? '',
                              titulo: tituloController.text.trim(),
                              imagemUrl: urlFinal,
                              link: linkController.text.trim(),
                              descricao: descricaoController.text.trim(),
                              dataPublicacao: noticiaParaEditar
                                      ?.dataPublicacao ??
                                  Timestamp.now(),
                            );

                            if (noticiaParaEditar != null) {
                              await FirebaseFirestore.instance
                                  .collection('noticias')
                                  .doc(noticia.id)
                                  .update(noticia.toMap());
                            } else {
                              await FirebaseFirestore.instance
                                  .collection('noticias')
                                  .add(noticia.toMap());
                            }

                            if (context.mounted) {
                              Navigator.pop(context);
                            }
                          } catch (e) {
                            setStateDialog(() {
                              enviando = false;
                            });

                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Erro: $e')),
                              );
                            }
                          }
                        },
                  child: enviando
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Salvar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _excluir(NoticiaModel noticia) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remover notícia'),
        content: Text('Remover "${noticia.titulo}" do site?'),
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

    if (noticia.imagemUrl.isNotEmpty) {
      try {
        await _r2.excluirArquivo(arquivoUrl: noticia.imagemUrl);
      } catch (_) {}
    }

    await FirebaseFirestore.instance
        .collection('noticias')
        .doc(noticia.id)
        .delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: fundo,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: primaria,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Nova Notícia',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        onPressed: () => _abrirFormulario(),
      ),
      body: Column(
        children: [
          const AdminTopBar(),
          Container(
            height: 56,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            color: Colors.white,
            alignment: Alignment.centerLeft,
            child: const Text(
              'Notícias (site)',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('noticias')
            .orderBy('dataPublicacao', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          }

          final noticias = (snapshot.data?.docs ?? [])
              .map((doc) => NoticiaModel.fromMap(doc.data(), doc.id))
              .toList();

          if (noticias.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.campaign_outlined,
                    size: 50,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Nenhuma notícia publicada ainda',
                    style: TextStyle(color: corTextoSecundario),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
            itemCount: noticias.length,
            itemBuilder: (context, index) {
              final noticia = noticias[index];

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: corBorda),
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.horizontal(
                        left: Radius.circular(16),
                      ),
                      child: noticia.imagemUrl.isNotEmpty
                          ? Image.network(
                              noticia.imagemUrl,
                              width: 100,
                              height: 80,
                              fit: BoxFit.cover,
                            )
                          : Container(
                              width: 100,
                              height: 80,
                              color: primaria.withOpacity(.08),
                              child: Icon(
                                Icons.image_outlined,
                                color: primaria.withOpacity(.4),
                              ),
                            ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            noticia.titulo.isEmpty
                                ? 'Sem título'
                                : noticia.titulo,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: corTextoPrimario,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (noticia.descricao.isNotEmpty)
                            Text(
                              noticia.descricao,
                              style: const TextStyle(
                                color: corTextoSecundario,
                                fontSize: 12.5,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, color: primaria),
                      onPressed: () =>
                          _abrirFormulario(noticiaParaEditar: noticia),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.delete_outline,
                        color: Colors.redAccent,
                      ),
                      onPressed: () => _excluir(noticia),
                    ),
                    const SizedBox(width: 8),
                  ],
                ),
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