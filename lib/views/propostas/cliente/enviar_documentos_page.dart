// ignore_for_file: unnecessary_import, use_build_context_synchronously, deprecated_member_use

import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

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
    extends State<EnviarDocumentosPage>
    with WidgetsBindingObserver {



  final CloudflareR2Service r2Service =
      CloudflareR2Service();



  final ImagePicker picker =
      ImagePicker();




  bool loading = false;



  PlatformFile? rgOuCnh;

  PlatformFile? comprovante;

  PlatformFile? selfieDocumento;




  @override
  void initState() {

    super.initState();

    WidgetsBinding.instance.addObserver(this);

  }




  @override
  void dispose() {

    WidgetsBinding.instance.removeObserver(this);

    super.dispose();

  }






  // =====================================================
  // SELECIONAR IMAGEM DO CELULAR
  // =====================================================


  Future<void> selecionarArquivo(
      Function(PlatformFile) callback,
      ) async {


    try {


      final result =
      await FilePicker.platform.pickFiles(


        type:
        FileType.image,


        withData:
        true,


      );



      if(result == null) return;



      if(!mounted) return;



      callback(
        result.files.first,
      );



      setState(() {});



    }catch(e){


      if(!mounted)return;


      ScaffoldMessenger.of(context)
          .showSnackBar(


        SnackBar(

          content:
          Text(
            "Erro ao selecionar arquivo: $e",
          ),

        ),


      );


    }


  }









  // =====================================================
  // CAMERA SELFIE DOCUMENTO
  // =====================================================


  Future<void> tirarSelfieDocumento() async {


    try {



      final XFile? foto =
      await picker.pickImage(



        source:
        ImageSource.camera,



        preferredCameraDevice:
        CameraDevice.front,



        imageQuality:
        85,


      );





      if(foto == null) return;






      Uint8List bytes;





      if(kIsWeb){



        bytes =
        await foto.readAsBytes();



      }else{



        final arquivo =
        File(
          foto.path,
        );



        bytes =
        await arquivo.readAsBytes();



      }






      if(!mounted) return;







      selfieDocumento =

          PlatformFile(


            name:
            "selfie_documento.jpg",



            size:
            bytes.length,



            bytes:
            bytes,



            path:
            foto.path,


          );






      setState(() {});







    }catch(e){



      if(!mounted)return;



      ScaffoldMessenger.of(context)
          .showSnackBar(


        SnackBar(

          backgroundColor:
          Colors.red,


          content:

          Text(

            "Erro câmera: $e",

          ),


        ),


      );



    }


  }









  // =====================================================
  // ENVIO DOCUMENTOS PARA R2
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


          content:

          Text(

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


        arquivo:
        rgOuCnh!,



        pasta:

        "propostas/rg",


      );








      final comprovanteUrl =

      await r2Service.uploadArquivo(



        arquivo:

        comprovante!,



        pasta:

        "propostas/comprovantes",


      );









      final selfieUrl =

      await r2Service.uploadArquivo(



        arquivo:

        selfieDocumento!,



        pasta:

        "propostas/selfies",


      );









      await FirebaseFirestore.instance

          .collection(
          "propostas"
      )

          .doc(
          widget.propostaId
      )

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








      if(!mounted)return;






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







      // volta somente para proposta
      // não perde autenticação

      Navigator.pop(context);







    }catch(e){



      if(!mounted)return;



      ScaffoldMessenger.of(context)
          .showSnackBar(



        SnackBar(

          backgroundColor:
          Colors.red,


          content:

          Text(

            "Erro ao enviar documentos: $e",

          ),


        ),


      );



    }finally{



      if(mounted){


        setState(() {


          loading = false;


        });


      }


    }


  }

    // =====================================================
  // CARD DOCUMENTO
  // =====================================================


  Widget documentoCard({

    required String titulo,

    required String descricao,

    required PlatformFile? arquivo,

    required VoidCallback onTap,

    required IconData icon,

    String textoBotao = "Selecionar Arquivo",

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


            offset:
            const Offset(
              0,
              4,
            ),

          ),


        ],


      ),



      child:

      Padding(

        padding:
        const EdgeInsets.all(16),



        child:

        Column(

          crossAxisAlignment:
          CrossAxisAlignment.start,


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

                          fontSize:
                          16,

                          fontWeight:
                          FontWeight.bold,

                        ),


                      ),





                      const SizedBox(
                        height:4,
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



                style:

                ElevatedButton.styleFrom(


                  backgroundColor:
                  Colors.blue.shade700,


                  foregroundColor:
                  Colors.white,


                  shape:

                  RoundedRectangleBorder(

                    borderRadius:
                    BorderRadius.circular(14),

                  ),

                ),





                onPressed:
                onTap,



                icon:

                Icon(

                  icon ==
                      Icons.camera_alt

                      ?

                  Icons.camera_alt

                      :

                  Icons.upload_file,

                ),




                label:

                Text(


                  arquivo == null

                      ?

                  textoBotao

                      :

                  arquivo.name,


                  overflow:
                  TextOverflow.ellipsis,


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

        centerTitle:
        true,


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

            "Segure RG ou CNH próximo ao rosto",




            arquivo:

            selfieDocumento,




            icon:

            Icons.camera_alt,




            textoBotao:

            "Abrir Câmera",




            onTap:(){


              tirarSelfieDocumento();



            },


          ),







          const SizedBox(
            height:30,
          ),







          SizedBox(


            width:

            double.infinity,



            height:

            58,



            child:

            ElevatedButton.icon(



              style:

              ElevatedButton.styleFrom(



                backgroundColor:

                const Color(
                  0xff1565C0,
                ),



                shape:

                RoundedRectangleBorder(



                  borderRadius:

                  BorderRadius.circular(
                    18,
                  ),


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



                  fontSize:

                  16,


                ),


              ),



            ),


          ),




        ],


      ),



    );


  }


}