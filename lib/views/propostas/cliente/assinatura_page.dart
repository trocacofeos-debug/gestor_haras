import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:signature/signature.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http_parser/http_parser.dart';



class AssinaturaPage extends StatefulWidget {


  final String propostaId;


  final String contratoUrl;



  const AssinaturaPage({

    super.key,

    required this.propostaId,

    required this.contratoUrl,

  });



  @override
  State<AssinaturaPage> createState() =>
      _AssinaturaPageState();

}





class _AssinaturaPageState
    extends State<AssinaturaPage> {



  final SignatureController controller =
  SignatureController(

    penStrokeWidth: 3,

    penColor: Colors.black,

  );




  final Dio dio = Dio();




  bool salvando = false;




  static const String api =
      "https://gestor-haras-api.onrender.com";



  static const String uploadContratoAssinado =
      "$api/upload_contrato_assinado";






  @override
  void dispose(){


    controller.dispose();


    super.dispose();


  }







  Future<String> enviarContratoAssinado(

      Uint8List assinatura,

      ) async {



    final arquivo =
    MultipartFile.fromBytes(


      assinatura,


      filename:

      "assinatura_${widget.propostaId}.png",



      contentType:

      MediaType(

        "image",

        "png",

      ),


    );






    final formData =
    FormData.fromMap({




      "proposta_id":

      widget.propostaId,





      "contrato_url":

      widget.contratoUrl,





      "file":

      arquivo,



    });








    final response =
    await dio.post(



      uploadContratoAssinado,



      data:

      formData,



      options:

      Options(

        headers: {


          "Accept":

          "application/json",


        },


      ),



    );








    if(response.statusCode == 200){



      final data = response.data;





      if(data["contratoAssinadoUrl"] != null){



        return data["contratoAssinadoUrl"].toString();



      }


    }







    throw Exception(

      "Erro ao gerar contrato assinado no R2",

    );



  }

    Future<void> salvarAssinatura() async {


    if(salvando){

      return;

    }




    if(controller.isEmpty){


      ScaffoldMessenger.of(context)

          .showSnackBar(

        const SnackBar(

          backgroundColor:

          Colors.orange,


          content:

          Text(

            "Faça sua assinatura",

          ),


        ),


      );


      return;


    }







    if(widget.contratoUrl.isEmpty){



      ScaffoldMessenger.of(context)

          .showSnackBar(


        const SnackBar(


          backgroundColor:

          Colors.red,


          content:

          Text(

            "Contrato original não encontrado",

          ),


        ),


      );



      return;


    }







    setState((){


      salvando = true;


    });







    try{





      final Uint8List? assinatura =

      await controller.toPngBytes();







      if(assinatura == null){



        throw Exception(

          "Erro ao gerar imagem da assinatura",

        );


      }







      final contratoAssinadoUrl =

      await enviarContratoAssinado(

        assinatura,

      );








      await FirebaseFirestore.instance

          .collection("propostas")

          .doc(widget.propostaId)

          .update({





        "status":

        "assinado",





        "documentoAssinado":

        true,





        "contratoAssinadoUrl":

        contratoAssinadoUrl,





        "assinaturaUrl":

        contratoAssinadoUrl,





        "dataAssinatura":

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

            "Contrato assinado e salvo com sucesso",

          ),


        ),



      );









      Navigator.pop(

        context,

        true,

      );







    } on DioException catch(e){





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

            "Erro API: ${e.response?.data ?? e.message}",

          ),



        ),



      );








    } catch(e){



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

            e.toString(),

          ),


        ),



      );





    } finally {



      if(mounted){



        setState((){


          salvando = false;



        });


      }


    }





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

          "Assinatura Digital",

        ),


      ),





      body:

      Padding(


        padding:

        const EdgeInsets.all(16),





        child:

        Column(


          children: [




            Container(



              width:

              double.infinity,



              padding:

              const EdgeInsets.all(14),





              decoration:

              BoxDecoration(



                color:

                Colors.white,



                borderRadius:

                BorderRadius.circular(16),



              ),




              child:

              const Row(


                children: [



                  Icon(

                    Icons.draw,

                    size:35,

                  ),




                  SizedBox(

                    width:10,

                  ),





                  Expanded(



                    child:

                    Text(



                      "Assine no campo abaixo",



                      style:

                      TextStyle(



                        fontSize:16,



                        fontWeight:

                        FontWeight.bold,



                      ),



                    ),



                  ),



                ],



              ),



            ),






            const SizedBox(

              height:12,

            ),




            Expanded(



              child:

              Container(



                decoration:

                BoxDecoration(



                  color:

                  Colors.white,



                  borderRadius:

                  BorderRadius.circular(16),




                  border:

                  Border.all(

                    color:

                    Colors.black12,

                  ),



                ),





                child:

                Signature(



                  controller:

                  controller,



                  backgroundColor:

                  Colors.white,



                ),



              ),



            ),


            const SizedBox(

              height:12,

            ),








            Row(


              children: [





                Expanded(


                  child:

                  OutlinedButton.icon(



                    icon:

                    const Icon(

                      Icons.delete,

                    ),




                    label:

                    const Text(

                      "Limpar",

                    ),





                    onPressed:



                    salvando

                        ? null

                        :

                        (){


                      controller.clear();



                    },



                  ),



                ),






                const SizedBox(

                  width:10,

                ),







                Expanded(



                  child:

                  ElevatedButton.icon(



                    icon:

                    salvando


                        ?


                    const SizedBox(


                      width:18,


                      height:18,



                      child:

                      CircularProgressIndicator(



                        strokeWidth:2,



                        color:

                        Colors.white,



                      ),



                    )



                        :



                    const Icon(

                      Icons.check,

                    ),







                    label:

                    Text(



                      salvando



                          ?



                      "Salvando..."



                          :



                      "Assinar",



                    ),







                    style:

                    ElevatedButton.styleFrom(



                      backgroundColor:

                      Colors.blue,



                      foregroundColor:

                      Colors.white,



                      minimumSize:

                      const Size(

                        double.infinity,

                        52,

                      ),




                      shape:

                      RoundedRectangleBorder(



                        borderRadius:

                        BorderRadius.circular(12),



                      ),



                    ),








                    onPressed:



                    salvando



                        ?



                    null



                        :



                    salvarAssinatura,





                  ),



                ),




              ],



            ),





          ],



        ),



      ),



    );



  }



}