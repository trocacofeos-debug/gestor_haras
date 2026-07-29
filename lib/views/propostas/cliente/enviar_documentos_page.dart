// ignore_for_file: use_build_context_synchronously, deprecated_member_use

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
  // SELECIONAR DOCUMENTO
  // =====================================================


  Future<void> selecionarArquivo(

      Function(PlatformFile) callback

      ) async {


    try{


      final result =

      await FilePicker.platform.pickFiles(


        type:
        FileType.image,


        withData:
        true,


      );




      if(result == null){

        return;

      }




      if(!mounted){

        return;

      }




      callback(

        result.files.first,

      );




      setState(() {});




    }catch(e){


      if(!mounted){

        return;

      }




      ScaffoldMessenger.of(context)
          .showSnackBar(



        SnackBar(

          backgroundColor:
          Colors.red,


          content:

          Text(

            "Erro selecionar arquivo: $e",

          ),

        ),


      );


    }


  }









  // =====================================================
  // ENVIO DOCUMENTOS
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

          backgroundColor:
          Colors.orange,


          content:

          Text(

            "Selecione todos os documentos",

          ),

        ),


      );



      return;


    }







    try{


      setState((){

        loading = true;

      });







      final rgUrl =

      await r2Service.uploadArquivo(

        arquivo:

        rgOuCnh!,


        pasta:

        "propostas/${widget.propostaId}/rg",

      );








      final comprovanteUrl =

      await r2Service.uploadArquivo(

        arquivo:

        comprovante!,


        pasta:

        "propostas/${widget.propostaId}/comprovante",

      );








      final selfieUrl =

      await r2Service.uploadArquivo(

        arquivo:

        selfieDocumento!,


        pasta:

        "propostas/${widget.propostaId}/selfie",

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



        "documentosEnviados":

        true,



        "status":

        "documentos_enviados",



        "dataEnvioDocumentos":

        Timestamp.now(),



      });






      if(!mounted){

        return;

      }






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





    }catch(e){



      if(!mounted){

        return;

      }



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


        setState((){

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


    String textoBotao =
    "Selecionar Arquivo",



  }){



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

                        height:5,

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

                Icon(icon),







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









  // =====================================================
  // BUILD
  // =====================================================


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



        centerTitle:

        true,


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

            "Selecione frente e verso do documento",





            arquivo:

            rgOuCnh,





            icon:

            Icons.badge_outlined,





            onTap:(){



              selecionarArquivo(


                    (arquivo){



                  rgOuCnh = arquivo;



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

            Icons.home_outlined,





            onTap:(){



              selecionarArquivo(


                    (arquivo){



                  comprovante = arquivo;



                },


              );



            },



          ),










          documentoCard(



            titulo:

            "Selfie com Documento",





            descricao:

            "Envie uma foto segurando RG ou CNH",





            arquivo:

            selfieDocumento,





            icon:

            Icons.person_outline,





            textoBotao:

            "Selecionar Foto",





            onTap:(){



              selecionarArquivo(


                    (arquivo){



                  selfieDocumento = arquivo;



                },


              );



            },



          ),







          const SizedBox(

            height:30,

          ),          SizedBox(



            width:

            double.infinity,



            height:

            58,








            child:

            ElevatedButton.icon(





              style:

              ElevatedButton.styleFrom(



                backgroundColor:

                const Color(0xff1565C0),





                foregroundColor:

                Colors.white,





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



                Icons.cloud_upload,



              ),







              label:

              const Text(



                "ENVIAR DOCUMENTOS",






                style:



                TextStyle(





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