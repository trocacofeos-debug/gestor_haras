// ignore_for_file: deprecated_member_use

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'enviar_documentos_page.dart';
import 'visualizar_contrato_page.dart';
import 'assinatura_page.dart';


class PropostasClientePage extends StatelessWidget {

  const PropostasClientePage({
    super.key,
  });



  String get uid =>
      FirebaseAuth.instance.currentUser?.uid ?? '';




  Stream<QuerySnapshot<Map<String, dynamic>>>
      minhasPropostas() {


    return FirebaseFirestore.instance
        .collection('propostas')
        .where(
          'clienteId',
          isEqualTo: uid,
        )
        .snapshots();


  }






  Color statusColor(String status) {


    switch(status) {


      case 'aguardando_documentos':
        return Colors.grey;



      case 'documentos_enviados':
        return Colors.orange;



      case 'em_analise':
        return Colors.blue;



      case 'aprovada':
        return Colors.green;



      case 'aguardando_assinatura':
        return Colors.deepPurple;



      case 'assinado':
        return Colors.teal;



      case 'reprovada':
        return Colors.red;



      default:
        return Colors.grey;


    }


  }







  String statusTexto(String status) {


    switch(status) {


      case 'aguardando_documentos':
        return 'Enviar documentos';



      case 'documentos_enviados':
        return 'Documentos enviados';



      case 'em_analise':
        return 'Em análise';



      case 'aprovada':
        return 'Aprovada';



      case 'aguardando_assinatura':
        return 'Aguardando assinatura';



      case 'assinado':
        return 'Contrato assinado';



      case 'reprovada':
        return 'Reprovada';



      default:
        return status;


    }


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
              'Minhas Propostas',
            ),

      ),





      body:

          StreamBuilder<

              QuerySnapshot<Map<String,dynamic>>>(

        stream:
            minhasPropostas(),



        builder:

            (context, snapshot) {



          if(snapshot.connectionState ==
              ConnectionState.waiting) {


            return const Center(

              child:
                  CircularProgressIndicator(),

            );


          }





          if(snapshot.hasError) {


            return Center(

              child:

                  Padding(

                padding:
                    const EdgeInsets.all(20),

                child:

                    Text(

                  "Erro ao carregar propostas:\n\n${snapshot.error}",

                  textAlign:
                      TextAlign.center,

                ),

              ),

            );


          }






          final docs =
              snapshot.data?.docs ?? [];






          // Ordenação local
          docs.sort((a,b){


            final dataA =
                a.data()['dataCriacao'];


            final dataB =
                b.data()['dataCriacao'];



            if(dataA is Timestamp &&
               dataB is Timestamp) {


              return dataB.compareTo(
                dataA,
              );


            }


            return 0;


          });







          if(docs.isEmpty) {


            return Center(

              child:

                  Column(

                mainAxisAlignment:
                    MainAxisAlignment.center,


                children:[


                  Icon(

                    Icons.description_outlined,

                    size:
                        90,

                    color:
                        Colors.grey.shade400,

                  ),



                  const SizedBox(
                    height:16,
                  ),




                  const Text(

                    'Nenhuma proposta encontrada',

                    style:

                        TextStyle(

                      fontSize:
                          18,


                      fontWeight:
                          FontWeight.bold,

                    ),

                  ),


                ],


              ),


            );


          }







          return ListView.builder(


            padding:
                const EdgeInsets.all(16),



            itemCount:
                docs.length,



            itemBuilder:
                (context,index) {



              final doc =
                  docs[index];



              final proposta =
                  doc.data();





              final status =
                  proposta['status']
                      ??
                      'aguardando_documentos';





              final valor =

                  proposta['valorTotal'] == null

                      ? 0.0

                      :

                  (proposta['valorTotal']
                      as num)
                      .toDouble();






              final parcelas =

                  proposta['parcelas']
                      ??
                      1;








              return Container(


                margin:

                    const EdgeInsets.only(
                      bottom:16,
                    ),



                padding:
                    const EdgeInsets.all(18),



                decoration:

                    BoxDecoration(

                  color:
                      Colors.white,


                  borderRadius:
                      BorderRadius.circular(20),



                  boxShadow:[


                    const BoxShadow(

                      color:
                          Colors.black12,

                      blurRadius:
                          8,

                    ),


                  ],


                ),







                child:

                    Column(

                  crossAxisAlignment:
                      CrossAxisAlignment.start,



                  children:[






                    Text(

                      proposta['titulo']
                          ??
                          'Proposta',

                      style:

                          const TextStyle(

                        fontSize:
                            18,

                        fontWeight:
                            FontWeight.bold,

                      ),

                    ),





                    const SizedBox(
                      height:15,
                    ),






                    Container(

                      padding:

                          const EdgeInsets.symmetric(

                        horizontal:
                            14,

                        vertical:
                            8,

                      ),



                      decoration:

                          BoxDecoration(

                        color:

                            statusColor(status)
                                .withOpacity(.15),


                        borderRadius:

                            BorderRadius.circular(30),

                      ),



                      child:

                          Text(

                        statusTexto(status),

                        style:

                            TextStyle(

                          color:

                              statusColor(status),


                          fontWeight:
                              FontWeight.bold,

                        ),

                      ),


                    ),






                    const SizedBox(
                      height:15,
                    ),







                    Text(

                      'Valor: R\$ ${valor.toStringAsFixed(2)}',

                      style:

                          const TextStyle(

                        color:
                            Colors.green,


                        fontSize:
                            18,


                        fontWeight:
                            FontWeight.bold,

                      ),

                    ),





                    Text(

                      '$parcelas parcela(s)',

                    ),





                    const SizedBox(
                      height:20,
                    ),






                    if(status ==
                        'aguardando_documentos')

                      ElevatedButton.icon(

                        icon:
                            const Icon(
                              Icons.upload,
                            ),


                        label:
                            const Text(
                              'ENVIAR DOCUMENTOS',
                            ),



                        onPressed:(){


                          Navigator.push(

                            context,

                            MaterialPageRoute(

                              builder:(_)=>

                                  EnviarDocumentosPage(

                                    propostaId:
                                        doc.id,

                                  ),

                            ),

                          );


                        },

                      ),







                    if(status ==
                          'aguardando_assinatura' ||

                       status ==
                          'aprovada')

                      ElevatedButton.icon(

                        icon:
                            const Icon(
                              Icons.description,
                            ),


                        label:
                            const Text(
                              'VISUALIZAR CONTRATO',
                            ),



                        onPressed:(){


                          Navigator.push(

                            context,

                            MaterialPageRoute(

                              builder:(_)=>

                                  VisualizarContratoPage(

                                    propostaId:
                                        doc.id,

                                  ),

                            ),

                          );


                        },

                      ),








                    if(status ==
                        'aguardando_assinatura')

                      ElevatedButton.icon(

                        icon:
                            const Icon(
                              Icons.draw,
                            ),


                        label:
                            const Text(
                              'ASSINAR CONTRATO',
                            ),



                        onPressed:(){


                          Navigator.push(

                            context,

                            MaterialPageRoute(

                              builder:(_)=>

                                  AssinaturaPage(

                                    propostaId:
                                        doc.id,

                                  ),

                            ),

                          );


                        },

                      ),





                  ],

                ),


              );


            },


          );


        },


      ),


    );


  }


}