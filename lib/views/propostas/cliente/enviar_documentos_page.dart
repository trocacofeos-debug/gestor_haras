// ignore_for_file: deprecated_member_use

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../../services/cloudflare_r2_service.dart';


class EnviarDocumentosPage extends StatefulWidget {

  final String propostaId;


  const EnviarDocumentosPage({
    super.key,
    required this.propostaId,
  });


  @override
  State<EnviarDocumentosPage> createState() =>
      _EnviarDocumentosPageState();

}



class _EnviarDocumentosPageState
    extends State<EnviarDocumentosPage> {


  final CloudflareR2Service r2Service =
      CloudflareR2Service();



  bool loading = false;



  PlatformFile? rgOuCnh;

  PlatformFile? comprovante;

  PlatformFile? selfieDocumento;





  // =====================================================
  // SELECIONAR ARQUIVO
  // =====================================================


  Future<void> selecionarArquivo(
    Function(PlatformFile) callback,
  ) async {


    final result =
        await FilePicker.platform.pickFiles(

      type: FileType.image,

      withData: true,

    );



    if(result == null) return;



    callback(
      result.files.first,
    );


    setState(() {});

  }





  // =====================================================
  // ENVIAR DOCUMENTOS
  // =====================================================


  Future<void> enviarDocumentos() async {


    if(
      rgOuCnh == null ||
      comprovante == null ||
      selfieDocumento == null
    ){

      ScaffoldMessenger.of(context)
          .showSnackBar(

        const SnackBar(

          content: Text(
            "Selecione todos os documentos",
          ),

        ),

      );


      return;

    }



    try {


      setState(() {

        loading = true;

      });





      final rgUrl =
          await r2Service.uploadArquivo(

        arquivo: rgOuCnh!,

        pasta:
            "propostas/rg",

      );





      final comprovanteUrl =
          await r2Service.uploadArquivo(

        arquivo: comprovante!,

        pasta:
            "propostas/comprovantes",

      );





      final selfieUrl =
          await r2Service.uploadArquivo(

        arquivo: selfieDocumento!,

        pasta:
            "propostas/selfies",

      );





      await FirebaseFirestore.instance
          .collection("propostas")
          .doc(widget.propostaId)
          .update({


        "rgUrl":
            rgUrl,


        "comprovanteUrl":
            comprovanteUrl,


        "selfieDocumentoUrl":
            selfieUrl,


        "status":
            "documentos_enviados",


        "dataEnvioDocumentos":
            Timestamp.now(),


      });





      if(!mounted) return;



      ScaffoldMessenger.of(context)
          .showSnackBar(

        const SnackBar(

          backgroundColor:
              Colors.green,


          content:
              Text(
            "Documentos enviados com sucesso",
          ),

        ),

      );



      Navigator.pop(context);



    } catch(e){


      if(!mounted) return;



      ScaffoldMessenger.of(context)
          .showSnackBar(

        SnackBar(

          content:
              Text(
            "Erro: $e",
          ),

        ),

      );



    } finally {


      if(mounted){

        setState(() {

          loading = false;

        });

      }

    }


  }







  Widget documentoCard({

    required String titulo,

    required String descricao,

    required PlatformFile? arquivo,

    required VoidCallback onTap,

    required IconData icon,

  }) {


    return Container(

      margin:
          const EdgeInsets.only(
            bottom:16,
          ),


      decoration:
          BoxDecoration(

        color:
            Colors.white,


        borderRadius:
            BorderRadius.circular(20),


        boxShadow:[

          BoxShadow(

            color:
                Colors.black.withOpacity(.05),

            blurRadius:
                10,

          ),

        ],

      ),



      child:

          Padding(

        padding:
            const EdgeInsets.all(16),



        child:

            Column(

          children:[



            Row(

              children:[


                CircleAvatar(

                  backgroundColor:
                      Colors.blue.shade50,


                  child:

                      Icon(

                    icon,

                    color:
                        Colors.blue.shade700,

                  ),

                ),



                const SizedBox(
                  width:12,
                ),



                Expanded(

                  child:

                      Column(

                    crossAxisAlignment:
                        CrossAxisAlignment.start,


                    children:[


                      Text(

                        titulo,

                        style:
                            const TextStyle(

                          fontWeight:
                              FontWeight.bold,

                          fontSize:
                              16,

                        ),

                      ),



                      Text(

                        descricao,

                        style:
                            TextStyle(

                          color:
                              Colors.grey.shade600,

                        ),

                      ),


                    ],

                  ),

                ),

              ],

            ),




            const SizedBox(
              height:16,
            ),




            SizedBox(

              width:
                  double.infinity,


              child:

                  ElevatedButton.icon(

                onPressed:
                    onTap,


                icon:
                    const Icon(
                      Icons.upload_file,
                    ),



                label:

                    Text(

                  arquivo == null

                      ? "Selecionar Arquivo"

                      :

                  arquivo.name,

                ),


              ),

            ),


          ],

        ),

      ),

    );

  }







  @override
  Widget build(BuildContext context) {


    return Scaffold(

      backgroundColor:
          const Color(0xffF4F6FA),


      appBar:
          AppBar(

        title:
            const Text(
              "Enviar Documentos",
            ),

      ),



      body:

          loading

          ?

          const Center(

            child:
                CircularProgressIndicator(),

          )


          :


          ListView(

            padding:
                const EdgeInsets.all(16),


            children:[



              documentoCard(

                titulo:
                    "RG ou CNH",


                descricao:
                    "Foto frente e verso",


                arquivo:
                    rgOuCnh,


                icon:
                    Icons.badge,


                onTap:(){

                  selecionarArquivo(

                    (arquivo){

                      rgOuCnh =
                          arquivo;

                    },

                  );

                },

              ),





              documentoCard(

                titulo:
                    "Comprovante de Residência",


                descricao:
                    "Conta de água, luz ou internet",


                arquivo:
                    comprovante,


                icon:
                    Icons.home,


                onTap:(){

                  selecionarArquivo(

                    (arquivo){

                      comprovante =
                          arquivo;

                    },

                  );

                },

              ),





              documentoCard(

                titulo:
                    "Selfie com Documento",


                descricao:
                    "Foto segurando RG ou CNH",


                arquivo:
                    selfieDocumento,


                icon:
                    Icons.camera_alt,


                onTap:(){

                  selecionarArquivo(

                    (arquivo){

                      selfieDocumento =
                          arquivo;

                    },

                  );

                },

              ),





              const SizedBox(
                height:30,
              ),





              SizedBox(

                height:
                    60,


                child:

                    ElevatedButton.icon(

                  style:

                      ElevatedButton.styleFrom(

                    backgroundColor:
                        const Color(0xff1565C0),


                    shape:

                        RoundedRectangleBorder(

                      borderRadius:
                          BorderRadius.circular(18),

                    ),

                  ),



                  onPressed:
                      enviarDocumentos,



                  icon:
                      const Icon(

                    Icons.send,

                    color:
                        Colors.white,

                  ),



                  label:

                      const Text(

                    "ENVIAR DOCUMENTOS",


                    style:
                        TextStyle(

                      color:
                          Colors.white,


                      fontWeight:
                          FontWeight.bold,


                    ),

                  ),

                ),

              ),


            ],

          ),

    );


  }


}