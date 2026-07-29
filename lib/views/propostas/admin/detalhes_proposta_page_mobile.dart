import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../models/proposta_model.dart';
import 'aprovar_proposta_page.dart';
import 'gerar_contrato_page.dart';


class DetalhesPropostaPageMobile extends StatelessWidget {

  final String propostaId;


  const DetalhesPropostaPageMobile({

    super.key,

    required this.propostaId,

  });



  final Color primaria =
      const Color(0xFF1565C0);


  final Color fundo =
      const Color(0xffF4F7FB);





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
      case 'contrato_assinado':
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
      case 'contrato_assinado':
        return 'Contrato assinado';


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
            "Arquivo não encontrado"
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
            "Não foi possível abrir o arquivo"
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







  // =====================================================
  // HEADER PADRÃO DO APP
  // =====================================================


  Widget _header(BuildContext context){


    return Container(

      padding:

      const EdgeInsets.fromLTRB(
          20,
          45,
          20,
          20,
      ),

      decoration:

      BoxDecoration(

        color:
        Colors.white,

        boxShadow: [

          BoxShadow(

            color:
            Colors.black.withOpacity(.05),

            blurRadius:
            10,

          ),

        ],

      ),

      child: Row(

        children: [

          InkWell(

            onTap: (){

              Navigator.pop(context);

            },

            child: Container(

              padding:
              const EdgeInsets.all(10),

              decoration: BoxDecoration(

                color:
                primaria.withOpacity(.10),

                borderRadius:
                BorderRadius.circular(14),

              ),

              child: Icon(

                Icons.arrow_back_rounded,

                color:
                primaria,

              ),

            ),

          ),

          const SizedBox(width: 15),

          Container(

            padding:
            const EdgeInsets.all(12),

            decoration: BoxDecoration(

              color:
              primaria.withOpacity(.12),

              borderRadius:
              BorderRadius.circular(14),

            ),

            child: Icon(

              Icons.description_rounded,

              color:
              primaria,

              size: 30,

            ),

          ),

          const SizedBox(width: 15),

          const Expanded(

            child: Column(

              crossAxisAlignment:
              CrossAxisAlignment.start,

              children: [

                Text(

                  "Detalhes da Proposta",

                  style: TextStyle(

                    fontSize: 22,
                    fontWeight: FontWeight.bold,

                  ),

                ),

                SizedBox(height: 4),

                Text(

                  "Documentos, status e contrato",

                  style: TextStyle(

                    color: Colors.grey,

                  ),

                ),

              ],

            ),

          ),

        ],

      ),

    );

  }







  // =====================================================
  // TÍTULO DE SEÇÃO (mesmo padrão do resto do app)
  // =====================================================


  Widget _titulo(String texto, IconData icon){

    return Padding(

      padding: const EdgeInsets.only(bottom: 12),

      child: Row(

        children: [

          Container(

            padding: const EdgeInsets.all(8),

            decoration: BoxDecoration(

              color: primaria.withOpacity(.12),

              borderRadius: BorderRadius.circular(10),

            ),

            child: Icon(icon, size: 20, color: primaria),

          ),

          const SizedBox(width: 10),

          Text(

            texto,

            style: const TextStyle(

              fontSize: 18,
              fontWeight: FontWeight.bold,

            ),

          ),

        ],

      ),

    );

  }







  // =====================================================
  // CARD DE DOCUMENTO (visual dos "_campo" do app)
  // =====================================================


  Widget _documentoCard({


    required BuildContext context,


    required String titulo,


    required String? url,


    required IconData icon,


  }) {


    final enviado =

        url != null &&

        url.trim().isNotEmpty;



    final corIcone =

        titulo.contains("Assinado")
            ? Colors.green
            : titulo.contains("Contrato")
                ? Colors.deepPurple
                : primaria;






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

        BorderRadius.circular(18),



        boxShadow:[


          BoxShadow(

            color:

            Colors.black.withOpacity(.03),

            blurRadius:

            8,

          ),


        ],


      ),







      child: Row(



        children:[




          Container(

            padding: const EdgeInsets.all(10),

            decoration: BoxDecoration(

              color: corIcone.withOpacity(.10),

              borderRadius: BorderRadius.circular(12),

            ),

            child: Icon(

              icon,

              color: corIcone,

              size: 22,

            ),

          ),






          const SizedBox(

            width:

            12,

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

                    FontWeight.w600,

                    fontSize:

                    15,

                  ),

                ),






                const SizedBox(

                  height:

                  4,

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

                    Colors.grey,



                    fontSize:

                    12,

                  ),


                ),



              ],


            ),


          ),







          if(enviado)


            IconButton(


              icon:

              Icon(

                Icons.visibility,

                color:

                primaria,

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



            Icon(

              Icons.cancel_outlined,

              color:

              Colors.grey.shade400,

            ),




        ],


      ),


    );


  }







  // =====================================================
  // LINHA DE INFORMAÇÃO (mesmo padrão do "_campo" do app)
  // =====================================================


  Widget _campo(String titulo, String valor, IconData icon){

    return Container(

      margin: const EdgeInsets.only(bottom: 12),

      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(

        color: Colors.white,

        borderRadius: BorderRadius.circular(18),

        boxShadow: [

          BoxShadow(

            color: Colors.black.withOpacity(.03),

            blurRadius: 8,

          ),

        ],

      ),

      child: Row(

        children: [

          Container(

            padding: const EdgeInsets.all(10),

            decoration: BoxDecoration(

              color: primaria.withOpacity(.10),

              borderRadius: BorderRadius.circular(12),

            ),

            child: Icon(icon, color: primaria, size: 22),

          ),

          const SizedBox(width: 12),

          Expanded(

            child: Column(

              crossAxisAlignment: CrossAxisAlignment.start,

              children: [

                Text(

                  titulo,

                  style: const TextStyle(

                    color: Colors.grey,
                    fontSize: 12,

                  ),

                ),

                const SizedBox(height: 4),

                Text(

                  valor.trim().isEmpty ? "-" : valor,

                  style: const TextStyle(

                    fontSize: 15,
                    fontWeight: FontWeight.w600,

                  ),

                ),

              ],

            ),

          ),

        ],

      ),

    );

  }



  // CONTINUAÇÃO


  @override
  Widget build(BuildContext context) {


    return Scaffold(


      backgroundColor:

      fundo,




      body:

      Column(

        children: [

          _header(context),

          Expanded(

            child:


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







          // NOVOS CAMPOS

          final contratoAssinadoUrl =


              dados["contratoAssinadoUrl"] ??

                  dados["contratoAssinadoPdf"] ??

                  "";









          return ListView(



            padding:

            const EdgeInsets.all(20),



            physics:

            const BouncingScrollPhysics(),



            children:[







              // ==========================
              // CLIENTE
              // ==========================


              Container(


                width: double.infinity,



                padding:

                const EdgeInsets.all(24),





                decoration:

                BoxDecoration(


                  gradient:

                  LinearGradient(



                    colors:[



                      primaria,


                      const Color(0xFF42A5F5),



                    ],



                    begin: Alignment.topLeft,

                    end: Alignment.bottomRight,


                  ),





                  borderRadius:

                  BorderRadius.circular(24),



                  boxShadow: [

                    BoxShadow(

                      color: primaria.withOpacity(.25),

                      blurRadius: 18,

                      offset: const Offset(0, 8),

                    ),

                  ],



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

                      height:

                      8,

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

                      height:

                      20,

                    ),






                    Container(


                      padding:

                      const EdgeInsets.symmetric(


                        horizontal:

                        16,


                        vertical:

                        8,


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

                height:

                25,

              ),







              _titulo(

                "Documentos enviados",

                Icons.folder_copy_rounded,

              ),






              const SizedBox(

                height:

                5,

              ),









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







              // ==========================
              // CONTRATO ASSINADO PDF
              // ==========================


              _documentoCard(


                context:

                context,


                titulo:

                "Contrato Assinado PDF",


                url:

                contratoAssinadoUrl.toString(),


                icon:

                Icons.verified,


              ),







              const SizedBox(

                height:

                15,

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



                      elevation: 0,



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

                height:

                12,

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



                      elevation: 0,



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

                height:

                15,

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

                        width:

                        12,

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

                height:

                25,

              ),







              // ==========================
              // INFORMAÇÕES
              // ==========================


              _titulo(

                "Informações",

                Icons.info_outline_rounded,

              ),



              const SizedBox(height: 5),



              _campo(

                "Data de envio",

                proposta.dataEnvio != null
                    ? proposta.dataEnvio!.toDate().toString().split(' ')[0]
                    : '-',

                Icons.upload_file_rounded,

              ),



              _campo(

                "Contrato liberado",

                proposta.contratoLiberado ? "Sim" : "Não",

                Icons.lock_open_rounded,

              ),



              _campo(

                "Data de assinatura",

                proposta.dataAssinatura != null
                    ? proposta.dataAssinatura!.toDate().toString().split(' ')[0]
                    : '-',

                Icons.draw_rounded,

              ),



              _campo(

                "Valor da proposta",

                "R\$ ${proposta.valorTotal.toStringAsFixed(2)}",

                Icons.attach_money_rounded,

              ),



              _campo(

                "Parcelas",

                "${proposta.parcelas}x",

                Icons.calendar_view_month_rounded,

              ),



              if(proposta.observacoes.isNotEmpty)

                _campo(

                  "Observações",

                  proposta.observacoes,

                  Icons.notes_rounded,

                ),







              const SizedBox(

                height:

                30,

              ),







            ],



          );



        },



      ),

          ),

        ],

      ),



    );


  }


}