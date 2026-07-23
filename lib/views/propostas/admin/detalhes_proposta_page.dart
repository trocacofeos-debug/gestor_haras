import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../models/proposta_model.dart';
import 'aprovar_proposta_page.dart';
import 'gerar_contrato_page.dart';



class DetalhesPropostaPage extends StatelessWidget {


  final String propostaId;



  const DetalhesPropostaPage({

    super.key,

    required this.propostaId,

  });







  Color _corStatus(String status) {


    switch(status){


      case 'aguardando_documentos':
        return Colors.orange;


      case 'documentos_enviados':
        return Colors.blue;


      case 'em_analise':
        return Colors.amber;


      case 'aprovada':
        return Colors.green;


      case 'contrato_liberado':
      case 'aguardando_assinatura':
        return Colors.indigo;


      case 'assinado':
        return Colors.teal;


      case 'reprovada':
        return Colors.red;


      default:
        return Colors.grey;

    }

  }







  String _tituloStatus(String status){


    switch(status){


      case 'aguardando_documentos':
        return 'Aguardando documentos';


      case 'documentos_enviados':
        return 'Documentos enviados';


      case 'em_analise':
        return 'Em análise';


      case 'aprovada':
        return 'Aprovada';


      case 'contrato_liberado':
        return 'Contrato liberado';


      case 'aguardando_assinatura':
        return 'Aguardando assinatura';


      case 'assinado':
        return 'Assinado';


      case 'reprovada':
        return 'Reprovada';


      default:
        return status;

    }

  }








  Future<void> _abrirDocumento(

      BuildContext context,

      String url,

      ) async {


    try{


      if(url.trim().isEmpty){

        throw Exception(
          "Arquivo não encontrado",
        );

      }




      final uri = Uri.parse(url);



      final aberto = await launchUrl(

        uri,

        mode:
        LaunchMode.externalApplication,

      );




      if(!aberto){

        throw Exception(
          "Não foi possível abrir o arquivo",
        );

      }




    }catch(e){


      if(!context.mounted) return;



      ScaffoldMessenger.of(context)
          .showSnackBar(


        SnackBar(

          backgroundColor:
          Colors.red,


          content:

          Text(
            "Erro ao abrir documento: $e",
          ),


        ),


      );


    }


  }









  Widget _documentoCard({


    required BuildContext context,


    required String titulo,


    required String? url,


    required IconData icon,


  }) {



    final enviado =

        url != null &&

        url.trim().isNotEmpty;







    return Container(


      margin:

      const EdgeInsets.only(

        bottom:12,

      ),





      padding:

      const EdgeInsets.all(16),






      decoration:

      BoxDecoration(


        color:

        Colors.white,



        borderRadius:

        BorderRadius.circular(16),



        boxShadow:[


          BoxShadow(

            color:
            Colors.black12,

            blurRadius:
            5,

          ),


        ],


      ),







      child: Row(



        children:[




          Icon(

            icon,

            size:
            34,


            color:

            titulo.contains("Contrato")

                ?

            Colors.deepPurple

                :

            Colors.blue,

          ),






          const SizedBox(

            width:12,

          ),







          Expanded(



            child: Column(



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






                const SizedBox(

                  height:5,

                ),






                Text(



                  enviado

                      ?

                  "Documento disponível para visualização"

                      :

                  "Documento não enviado",




                  style:

                  TextStyle(


                    color:

                    enviado

                        ?

                    Colors.green

                        :

                    Colors.red,


                    fontSize:

                    13,

                  ),


                ),



              ],


            ),


          ),







          if(enviado)


            IconButton(


              icon:

              const Icon(

                Icons.visibility,

                color:
                Colors.indigo,

              ),



              tooltip:

              "Visualizar documento",




              onPressed:(){



                _abrirDocumento(

                  context,

                  url,

                );



              },


            )



          else



            const Icon(

              Icons.cancel,

              color:

              Colors.red,

            ),




        ],


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
          "Detalhes da Proposta",
        ),



        centerTitle:
        true,


      ),








      body:


      StreamBuilder<DocumentSnapshot>(



        stream:

        FirebaseFirestore.instance

            .collection("propostas")

            .doc(propostaId)

            .snapshots(),





        builder:

            (context, snapshot){



          if(snapshot.connectionState ==

              ConnectionState.waiting){


            return const Center(


              child:

              CircularProgressIndicator(),


            );


          }







          if(!snapshot.hasData ||

              !snapshot.data!.exists){



            return const Center(


              child:

              Text(

                "Proposta não encontrada",

              ),


            );


          }








          final dados =

          snapshot.data!.data()

          as Map<String,dynamic>;








          final proposta =


          PropostaModel.fromMap(


            snapshot.data!.id,


            dados,


          );









          return ListView(



            padding:

            const EdgeInsets.all(16),



            children:[







              // ==========================
              // CLIENTE
              // ==========================


              Container(


                padding:

                const EdgeInsets.all(24),




                decoration:

                BoxDecoration(


                  gradient:

                  const LinearGradient(



                    colors:[


                      Color(0xff1565C0),

                      Color(0xff42A5F5),


                    ],


                  ),



                  borderRadius:

                  BorderRadius.circular(24),


                ),







                child:

                Column(



                  crossAxisAlignment:

                  CrossAxisAlignment.start,



                  children:[




                    const Text(


                      "Cliente",


                      style:

                      TextStyle(


                        color:

                        Colors.white70,


                      ),


                    ),






                    const SizedBox(

                      height:8,

                    ),






                    Text(


                      proposta.clienteNome,



                      style:

                      const TextStyle(



                        color:

                        Colors.white,



                        fontSize:

                        22,



                        fontWeight:

                        FontWeight.bold,


                      ),


                    ),






                    const SizedBox(

                      height:20,

                    ),






                    Container(


                      padding:

                      const EdgeInsets.symmetric(


                        horizontal:16,

                        vertical:8,


                      ),




                      decoration:

                      BoxDecoration(



                        color:

                        Colors.white,



                        borderRadius:

                        BorderRadius.circular(30),


                      ),




                      child:

                      Text(



                        _tituloStatus(

                          proposta.status,

                        ),




                        style:

                        TextStyle(



                          color:

                          _corStatus(

                            proposta.status,

                          ),



                          fontWeight:

                          FontWeight.bold,


                        ),


                      ),


                    ),




                  ],


                ),


              ),







              const SizedBox(

                height:25,

              ),







              const Text(



                "Documentos enviados",



                style:

                TextStyle(



                  fontSize:

                  18,



                  fontWeight:

                  FontWeight.bold,


                ),



              ),






              const SizedBox(

                height:15,

              ),







              // ==========================
              // RG OU CNH
              // ==========================


              _documentoCard(


                context:

                context,



                titulo:

                "RG ou CNH",



                url:

                proposta.rgUrl,



                icon:

                Icons.badge,


              ),








              // ==========================
              // COMPROVANTE
              // ==========================


              _documentoCard(



                context:

                context,



                titulo:

                "Comprovante de residência",



                url:

                proposta.comprovanteUrl,



                icon:

                Icons.home,


              ),









              // ==========================
              // SELFIE DOCUMENTO
              // ==========================


              _documentoCard(



                context:

                context,



                titulo:

                "Selfie com documento",



                url:

                proposta.selfieDocumentoUrl,



                icon:

                Icons.face,


              ),







              // ==========================
              // CONTRATO PDF
              // ABAIXO DA SELFIE
              // ==========================


              _documentoCard(



                context:

                context,



                titulo:

                "Contrato PDF",



                url:

                proposta.contratoVisualizacao,



                icon:

                Icons.picture_as_pdf,


              ),








              const SizedBox(

                height:25,

              ),






              // ==========================
              // ANALISAR DOCUMENTOS
              // ==========================


              if(

              proposta.status ==

                  "documentos_enviados"

                  ||

              proposta.status ==

                  "em_analise"

              )

                SizedBox(


                  width:

                  double.infinity,



                  height:

                  55,



                  child:

                  ElevatedButton.icon(


                    icon:

                    const Icon(

                      Icons.verified,

                      color:

                      Colors.white,

                    ),




                    label:

                    const Text(


                      "ANALISAR DOCUMENTOS",



                      style:

                      TextStyle(



                        color:

                        Colors.white,



                        fontWeight:

                        FontWeight.bold,


                      ),


                    ),





                    style:

                    ElevatedButton.styleFrom(



                      backgroundColor:

                      Colors.green,



                      shape:

                      RoundedRectangleBorder(



                        borderRadius:

                        BorderRadius.circular(14),


                      ),


                    ),






                    onPressed:(){



                      Navigator.push(



                        context,



                        MaterialPageRoute(



                          builder:(_)=>


                              AprovarPropostaPage(



                                propostaId:

                                proposta.id,



                              ),



                        ),



                      );



                    },



                  ),


                ),





              const SizedBox(

                height:12,

              ),

              // ==========================
              // GERAR CONTRATO
              // ==========================


              if(proposta.status == "aprovada")


                SizedBox(


                  width:

                  double.infinity,



                  height:

                  55,



                  child:

                  ElevatedButton.icon(



                    icon:

                    const Icon(

                      Icons.description,

                      color:

                      Colors.white,

                    ),





                    label:

                    const Text(



                      "GERAR CONTRATO",



                      style:

                      TextStyle(



                        color:

                        Colors.white,



                        fontWeight:

                        FontWeight.bold,


                      ),


                    ),





                    style:

                    ElevatedButton.styleFrom(



                      backgroundColor:

                      Colors.indigo,



                      shape:

                      RoundedRectangleBorder(



                        borderRadius:

                        BorderRadius.circular(14),


                      ),


                    ),






                    onPressed:(){



                      Navigator.push(



                        context,



                        MaterialPageRoute(



                          builder:(_)=>



                              GerarContratoPage(



                                propostaId:

                                proposta.id,


                              ),


                        ),



                      );



                    },



                  ),


                ),







              const SizedBox(

                height:25,

              ),







              // ==========================
              // CONTRATO LIBERADO
              // ==========================


              if(

              proposta.status ==

                  "contrato_liberado"

                  ||

              proposta.status ==

                  "aguardando_assinatura"

              )

                Container(



                  padding:

                  const EdgeInsets.all(16),





                  decoration:

                  BoxDecoration(



                    color:

                    Colors.indigo.shade50,



                    borderRadius:

                    BorderRadius.circular(16),



                  ),





                  child:

                  const Row(



                    children:[



                      Icon(

                        Icons.draw,

                        color:

                        Colors.indigo,

                      ),





                      SizedBox(

                        width:12,

                      ),







                      Expanded(



                        child:

                        Text(



                          "Contrato liberado. Aguardando assinatura digital do cliente.",



                          style:

                          TextStyle(



                            fontWeight:

                            FontWeight.w600,


                          ),


                        ),


                      ),



                    ],



                  ),



                ),








              const SizedBox(

                height:30,

              ),







              // ==========================
              // INFORMAÇÕES
              // ==========================


              Container(



                padding:

                const EdgeInsets.all(18),





                decoration:

                BoxDecoration(



                  color:

                  Colors.white,



                  borderRadius:

                  BorderRadius.circular(18),



                ),





                child:

                Column(



                  crossAxisAlignment:

                  CrossAxisAlignment.start,



                  children:[





                    const Text(



                      "Informações",



                      style:

                      TextStyle(



                        fontSize:

                        17,



                        fontWeight:

                        FontWeight.bold,


                      ),



                    ),








                    const SizedBox(

                      height:15,

                    ),







                    Text(



                      "Data de envio: "

                          "${proposta.dataEnvio != null ? proposta.dataEnvio.toString().split(' ')[0] : '-'}",



                    ),








                    const SizedBox(

                      height:10,

                    ),








                    Text(



                      "Contrato liberado: "

                          "${proposta.contratoLiberado ? "Sim" : "Não"}",



                    ),








                    const SizedBox(

                      height:10,

                    ),







                    Text(



                      "Data assinatura: "

                          "${proposta.dataAssinatura != null ? proposta.dataAssinatura.toString().split(' ')[0] : '-'}",



                    ),








                    const SizedBox(

                      height:10,

                    ),








                    Text(



                      "Valor proposta: "

                          "R\$ ${proposta.valorTotal}",



                    ),








                    const SizedBox(

                      height:10,

                    ),








                    Text(



                      "Parcelas: "

                          "${proposta.parcelas}",



                    ),






                  ],



                ),



              ),








              const SizedBox(

                height:30,

              ),





            ],


          );



        },



      ),



    );


  }



}