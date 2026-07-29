// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../services/proposta_service.dart';

import 'nova_proposta_page.dart';
import 'detalhes_proposta_page.dart';
import 'aprovar_proposta_page.dart';


class PropostasAdminPage extends StatefulWidget {

  const PropostasAdminPage({
    super.key,
  });


  @override
  State<PropostasAdminPage> createState() =>
      _PropostasAdminPageState();

}



class _PropostasAdminPageState
    extends State<PropostasAdminPage> {


  final FirebaseFirestore db =
      FirebaseFirestore.instance;


  final PropostaService service =
      PropostaService();


  bool gerandoContrato = false;




  Stream<QuerySnapshot<Map<String,dynamic>>>
  propostas(){


    return db
        .collection("propostas")
        .orderBy(
          "dataCriacao",
          descending: true,
        )
        .snapshots();

  }







  Future<void> gerarContrato(
      String id,
      ) async {


    try {


      setState(() {

        gerandoContrato = true;

      });



      final url =
          await service.gerarContrato(
            id,
          );



      if(!mounted) return;



      ScaffoldMessenger.of(context)
          .showSnackBar(

        const SnackBar(

          backgroundColor:
          Colors.green,

          content:

          Text(
            "Contrato gerado e salvo no R2",
          ),

        ),

      );



      await abrirDocumento(url);



    }catch(e){



      if(!mounted) return;



      ScaffoldMessenger.of(context)
          .showSnackBar(

        SnackBar(

          backgroundColor:
          Colors.red,

          content:

          Text(
            "Erro: $e",
          ),

        ),

      );


    }finally{


      if(mounted){

        setState(() {

          gerandoContrato = false;

        });

      }


    }


  }








  Future<void> abrirDocumento(
      String url,
      ) async {


    try{


      final uri =
      Uri.parse(url);



      if(await canLaunchUrl(uri)){


        await launchUrl(

          uri,

          mode:
          LaunchMode.externalApplication,

        );


      }else{


        throw Exception(
          "Não foi possível abrir arquivo",
        );


      }


    }catch(e){


      if(!mounted) return;


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


    }


  }










  Color statusColor(
      String status,
      ){


    switch(status){


      case "aguardando_documentos":
        return Colors.grey;


      case "documentos_enviados":
        return Colors.blue;


      case "em_analise":
        return Colors.orange;


      case "aprovada":
        return Colors.green;


      case "aguardando_assinatura":
        return Colors.deepPurple;


      case "contrato_assinado":
        return Colors.teal;


      case "reprovada":
        return Colors.red;



      default:

        return Colors.grey;


    }


  }








  String statusTexto(
      String status,
      ){


    switch(status){


      case "aguardando_documentos":

        return "Aguardando documentos";



      case "documentos_enviados":

        return "Documentos enviados";



      case "em_analise":

        return "Em análise";



      case "aprovada":

        return "Aprovada";



      case "aguardando_assinatura":

        return "Aguardando assinatura";



      case "contrato_assinado":

        return "Contrato assinado";



      case "reprovada":

        return "Reprovada";



      default:

        return status;


    }


  }








  String formatarData(
      Timestamp? timestamp,
      ){


    if(timestamp == null){

      return "-";

    }



    final data =
    timestamp.toDate();



    return

      "${data.day.toString().padLeft(2,'0')}/"
          "${data.month.toString().padLeft(2,'0')}/"
          "${data.year}";


  }









  @override
  Widget build(BuildContext context) {


    return Scaffold(


      backgroundColor:
      const Color(0xffF4F6FA),



      appBar:
      AppBar(

        centerTitle:true,

        title:
        const Text(
          "Propostas",
        ),

      ),




      floatingActionButton:

      FloatingActionButton.extended(

        backgroundColor:
        const Color(0xff1565C0),


        icon:

        const Icon(

          Icons.add,

          color:
          Colors.white,

        ),



        label:

        const Text(

          "Nova Proposta",

          style:

          TextStyle(

            color:
            Colors.white,

            fontWeight:
            FontWeight.bold,

          ),

        ),




        onPressed:(){


          Navigator.push(

            context,

            MaterialPageRoute(

              builder:(_)=>

              const NovaPropostaPage(),

            ),

          );


        },


      ),







      body:

      StreamBuilder<

          QuerySnapshot<Map<String,dynamic>>

      >(


        stream:

        propostas(),



        builder:

            (context,snapshot){


          if(snapshot.connectionState ==
              ConnectionState.waiting){


            return const Center(

              child:

              CircularProgressIndicator(),

            );


          }



          if(snapshot.hasError){


            return Center(

              child:

              Text(
                snapshot.error.toString(),
              ),

            );


          }




          final docs =
              snapshot.data?.docs ?? [];




          if(docs.isEmpty){


            return const Center(

              child:

              Text(
                "Nenhuma proposta encontrada",
              ),

            );


          }





          return ListView.builder(

            padding:

            const EdgeInsets.all(16),


            itemCount:

            docs.length,


            itemBuilder:

                (context,index){


              final doc =
              docs[index];


              final data =
              doc.data();


              final nome =

              data["clienteNome"] ??
                  "Cliente";



              final status =

              data["status"] ??
                  "aguardando_documentos";



              final valor =

              double.tryParse(

                (data["valor"] ??
                    data["valorTotal"] ??
                    0)
                    .toString(),

              ) ?? 0;



              final parcelas =

              data["parcelas"] ?? 1;



              final criado =

              data["dataCriacao"]
              as Timestamp?;



              final contratoUrl =

              data["contratoPdfUrl"];



              final rgUrl =

              data["rgUrl"];



              final comprovanteUrl =

              data["comprovanteUrl"];



              final selfieUrl =

              data["selfieDocumentoUrl"];





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

                  BorderRadius.circular(22),


                  boxShadow:[

                    const BoxShadow(

                      color:
                      Colors.black12,

                      blurRadius:
                      8,

                      offset:
                      Offset(0,4),

                    ),

                  ],


                ),


                child:

                Padding(

                  padding:
                  const EdgeInsets.all(18),

                  child:

                  Column(

                    crossAxisAlignment:

                    CrossAxisAlignment.start,


                    children:[


                      Row(

                        children:[


                          CircleAvatar(

                            backgroundColor:

                            Colors.blue.shade100,


                            child:

                            const Icon(

                              Icons.person,

                              color:
                              Colors.blue,

                            ),

                          ),


                          const SizedBox(
                            width:12,
                          ),


                          Expanded(

                            child:

                            Text(

                              nome.toString(),

                              style:

                              const TextStyle(

                                fontSize:18,

                                fontWeight:
                                FontWeight.bold,

                              ),

                            ),

                          ),


                        ],

                      ),


                      const SizedBox(
                        height:18,
                      ),                      Container(

                        padding:
                        const EdgeInsets.symmetric(
                          horizontal:12,
                          vertical:8,
                        ),


                        decoration:

                        BoxDecoration(

                          color:

                          statusColor(
                            status.toString(),
                          )
                              .withOpacity(.15),


                          borderRadius:

                          BorderRadius.circular(30),

                        ),



                        child:

                        Text(

                          statusTexto(
                            status.toString(),
                          ),

                          style:

                          TextStyle(

                            color:

                            statusColor(
                              status.toString(),
                            ),


                            fontWeight:
                            FontWeight.bold,

                          ),

                        ),


                      ),






                      const SizedBox(
                        height:18,
                      ),






                      Text(

                        "Valor da proposta",

                        style:

                        TextStyle(

                          color:
                          Colors.grey.shade600,

                        ),

                      ),




                      const SizedBox(
                        height:5,
                      ),





                      Text(

                        "R\$ ${valor.toStringAsFixed(2)}",

                        style:

                        const TextStyle(

                          fontSize:24,

                          color:
                          Colors.green,

                          fontWeight:
                          FontWeight.bold,

                        ),

                      ),






                      const SizedBox(
                        height:8,
                      ),





                      Text(

                        "$parcelas parcela(s)",

                        style:

                        const TextStyle(

                          fontWeight:
                          FontWeight.w500,

                        ),

                      ),





                      const SizedBox(
                        height:5,
                      ),





                      Text(

                        "Criada em ${formatarData(criado)}",

                        style:

                        TextStyle(

                          color:
                          Colors.grey.shade600,

                        ),

                      ),






                      const SizedBox(
                        height:20,
                      ),






                      SizedBox(

                        width:
                        double.infinity,


                        child:

                        OutlinedButton.icon(

                          icon:

                          const Icon(
                            Icons.visibility,
                          ),


                          label:

                          const Text(
                            "Detalhes",
                          ),



                          onPressed:(){


                            Navigator.push(

                              context,

                              MaterialPageRoute(

                                builder:(_)=>

                                DetalhesPropostaPage(

                                  propostaId:
                                  doc.id,

                                ),

                              ),

                            );


                          },


                        ),

                      ),








                      const SizedBox(
                        height:10,
                      ),







// =================================================
// DOCUMENTOS CLIENTE
// =================================================


                      if(rgUrl != null &&
                          rgUrl.toString().isNotEmpty)

                        documentoButton(

                          titulo:
                          "Visualizar RG",

                          url:
                          rgUrl.toString(),

                          icon:
                          Icons.badge,

                        ),






                      if(comprovanteUrl != null &&
                          comprovanteUrl.toString().isNotEmpty)

                        documentoButton(

                          titulo:
                          "Visualizar Comprovante",

                          url:
                          comprovanteUrl.toString(),

                          icon:
                          Icons.home,

                        ),






                      if(selfieUrl != null &&
                          selfieUrl.toString().isNotEmpty)

                        documentoButton(

                          titulo:
                          "Visualizar Selfie com Documento",

                          url:
                          selfieUrl.toString(),

                          icon:
                          Icons.face,

                        ),







// =================================================
// CONTRATO PDF R2
// FICA ABAIXO DA SELFIE
// =================================================


                      if(
                      contratoUrl != null &&
                      contratoUrl.toString().isNotEmpty
                      )

                        documentoButton(

                          titulo:
                          "Visualizar Contrato PDF",

                          url:
                          contratoUrl.toString(),

                          icon:
                          Icons.picture_as_pdf,

                          cor:
                          Colors.deepPurple,

                        ),








// =================================================
// ANALISAR PROPOSTA
// =================================================


                      if(
                      status == "documentos_enviados" ||
                      status == "em_analise"
                      )

                        Padding(

                          padding:
                          const EdgeInsets.only(
                            top:10,
                          ),


                          child:

                          SizedBox(

                            width:
                            double.infinity,


                            child:

                            ElevatedButton.icon(


                              style:

                              ElevatedButton.styleFrom(

                                backgroundColor:
                                Colors.orange,

                                foregroundColor:
                                Colors.white,

                              ),



                              icon:

                              const Icon(
                                Icons.fact_check,
                              ),



                              label:

                              const Text(

                                "ANALISAR PROPOSTA",

                                style:

                                TextStyle(

                                  fontWeight:
                                  FontWeight.bold,

                                ),

                              ),



                              onPressed:(){



                                Navigator.push(

                                  context,

                                  MaterialPageRoute(

                                    builder:(_)=>

                                    AprovarPropostaPage(

                                      propostaId:
                                      doc.id,

                                    ),

                                  ),

                                );


                              },


                            ),

                          ),

                        ),








// =================================================
// GERAR CONTRATO
// =================================================


                      if(status == "aprovada")

                        Padding(

                          padding:

                          const EdgeInsets.only(
                            top:10,
                          ),


                          child:

                          SizedBox(

                            width:
                            double.infinity,


                            child:

                            ElevatedButton.icon(



                              style:

                              ElevatedButton.styleFrom(

                                backgroundColor:
                                Colors.deepPurple,

                                foregroundColor:
                                Colors.white,

                              ),



                              icon:

                              const Icon(
                                Icons.description,
                              ),



                              label:

                              Text(

                                gerandoContrato

                                    ?

                                "Gerando contrato..."

                                    :

                                "GERAR CONTRATO",

                              ),



                              onPressed:

                              gerandoContrato

                                  ?

                              null

                                  :

                                  (){

                                gerarContrato(
                                  doc.id,
                                );


                              },


                            ),

                          ),

                        ),



                    ],


                  ),

                ),

              );


            },


          );


        },


      ),


    );


  }







// =================================================
// BOTÃO DOCUMENTOS / PDF
// =================================================


  Widget documentoButton({


    required String titulo,


    required String url,


    required IconData icon,


    Color cor = Colors.blue,


  }){


    return Padding(

      padding:

      const EdgeInsets.only(
        top:8,
      ),



      child:

      SizedBox(

        width:

        double.infinity,



        child:

        OutlinedButton.icon(



          icon:

          Icon(

            icon,

            color:
            cor,

          ),



          label:

          Text(

            titulo,

            style:

            TextStyle(

              color:
              cor,

              fontWeight:
              FontWeight.bold,

            ),

          ),



          onPressed:(){


            abrirDocumento(
              url,
            );


          },


        ),

      ),

    );


  }



}