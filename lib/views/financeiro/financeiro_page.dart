import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import '../../services/divida_service.dart';



class FinanceiroPage extends StatefulWidget {


  const FinanceiroPage({
    super.key,
  });



  @override
  State<FinanceiroPage> createState() =>
      _FinanceiroPageState();


}








class _FinanceiroPageState
    extends State<FinanceiroPage> {



  final DividaService service =
      DividaService();



  String? aberto;





  final moeda =
      NumberFormat.currency(
        locale: "pt_BR",
        symbol: "R\$",
      );









  Future<void> quitar(
      String id
      ) async {



    await service.quitarDivida(id);



    if(!mounted)return;



    ScaffoldMessenger.of(context)
        .showSnackBar(


      SnackBar(

        backgroundColor:
        Colors.green,

        content:
        const Text(
          "Dívida quitada com sucesso",
        ),

      ),


    );


  }









  Future<void> pagarParcela(
      String dividaId,
      String parcelaId
      ) async {



    await FirebaseFirestore.instance

        .collection("dividas")

        .doc(dividaId)

        .collection("parcelas")

        .doc(parcelaId)

        .update({


      "status":
      "pago",


      "dataPagamento":
      Timestamp.now(),


    });



  }









  double totalAberto(
      List<QueryDocumentSnapshot<Map<String,dynamic>>> docs){


    double total = 0;


    for(final d in docs){


      total +=
          (d.data()["valorTotal"] ?? 0)
              .toDouble();


    }


    return total;


  }









  @override
  Widget build(BuildContext context){


    return Scaffold(


      backgroundColor:
      const Color(0xffF4F6FA),





      appBar:
      AppBar(


        elevation:
        0,


        title:
        const Text(

          "Financeiro",

          style:
          TextStyle(
            fontWeight:
            FontWeight.bold,
          ),

        ),


      ),







      body:

      StreamBuilder<QuerySnapshot<Map<String,dynamic>>>(


        stream:
        service.listarDividas(),




        builder:(context,snapshot){



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
              Column(


                mainAxisAlignment:
                MainAxisAlignment.center,


                children:[



                  Icon(

                    Icons.check_circle,

                    size:
                    80,

                    color:
                    Colors.green,

                  ),





                  SizedBox(
                    height:20,
                  ),





                  Text(

                    "Tudo pago",

                    style:
                    TextStyle(

                      fontSize:
                      22,

                      fontWeight:
                      FontWeight.bold,

                    ),

                  )



                ],


              ),



            );


          }





          return ListView(


            padding:
            const EdgeInsets.all(16),


            children:[





              Container(


                padding:
                const EdgeInsets.all(22),


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

                      "Total em dívidas",

                      style:
                      TextStyle(

                        color:
                        Colors.white70,

                        fontSize:
                        15,

                      ),

                    ),





                    const SizedBox(
                      height:10,
                    ),





                    Text(


                      moeda.format(
                        totalAberto(docs),
                      ),


                      style:
                      const TextStyle(

                        color:
                        Colors.white,

                        fontSize:
                        30,

                        fontWeight:
                        FontWeight.bold,

                      ),


                    ),




                    const SizedBox(
                      height:10,
                    ),





                    Text(

                      "${docs.length} clientes com pendência",

                      style:
                      const TextStyle(

                        color:
                        Colors.white,

                      ),

                    )



                  ],


                ),


              ),







              const SizedBox(
                height:20,
              ),








              ...docs.map((doc){



                final data =
                doc.data();


                final id =
                doc.id;



                final expandido =
                    aberto == id;






                return AnimatedContainer(


                  duration:
                  const Duration(
                    milliseconds:250,
                  ),



                  margin:
                  const EdgeInsets.only(
                    bottom:14,
                  ),





                  decoration:
                  BoxDecoration(


                    color:
                    Colors.white,


                    borderRadius:
                    BorderRadius.circular(22),



                    boxShadow:[

                      BoxShadow(

                        color:
                        Colors.black.withValues(alpha: .05),

                        blurRadius:
                        12,

                        offset:
                        const Offset(
                          0,
                          5,
                        ),

                      )

                    ],


                  ),





                  child:
                  Column(


                    children:[





                      InkWell(


                        borderRadius:
                        BorderRadius.circular(22),



                        onTap:(){


                          setState((){


                            aberto =
                            expandido
                                ?
                            null
                                :
                            id;


                          });


                        },



                        child:
                        Padding(


                          padding:
                          const EdgeInsets.all(18),



                          child:
                          Row(


                            children:[





                              CircleAvatar(


                                radius:
                                25,


                                backgroundColor:
                                Colors.blue.shade50,


                                child:
                                Icon(

                                  Icons.person,

                                  color:
                                  Colors.blue.shade700,

                                ),

                              ),






                              const SizedBox(
                                width:14,
                              ),







                              Expanded(


                                child:
                                Column(


                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,


                                  children:[



                                    Text(

                                      data["clienteNome"]
                                          ??
                                          "Cliente",


                                      style:
                                      const TextStyle(

                                        fontWeight:
                                        FontWeight.bold,

                                        fontSize:
                                        17,

                                      ),


                                    ),





                                    Text(

                                      data["descricao"]
                                          ??
                                          "Dívida",


                                      style:
                                      TextStyle(

                                        color:
                                        Colors.grey.shade600,

                                      ),

                                    )



                                  ],


                                ),



                              ),





                              Column(


                                children:[



                                  Text(

                                    moeda.format(
                                      data["valorTotal"] ?? 0,
                                    ),


                                    style:
                                    const TextStyle(

                                      color:
                                      Colors.red,

                                      fontWeight:
                                      FontWeight.bold,

                                    ),

                                  ),





                                  Icon(

                                    expandido

                                        ?
                                    Icons.expand_less

                                        :
                                    Icons.expand_more,


                                  )



                                ],


                              )




                            ],


                          ),


                        ),


                      ),






                      AnimatedCrossFade(


                        duration:
                        const Duration(
                          milliseconds:250,
                        ),


                        firstChild:
                        const SizedBox.shrink(),


                        secondChild:
                        _parcelas(id),



                        crossFadeState:

                        expandido

                            ?

                        CrossFadeState.showSecond

                            :

                        CrossFadeState.showFirst,


                      )




                    ],


                  ),


                );



              })


            ],


          );


        },


      ),


    );


  }









 Widget _parcelas(
     String dividaId
     ){


   return StreamBuilder<QuerySnapshot<Map<String,dynamic>>>(


     stream:
     service.parcelas(dividaId),



     builder:(context,snapshot){


       if(!snapshot.hasData){

         return const Padding(

           padding:
           EdgeInsets.all(20),

           child:
           CircularProgressIndicator(),

         );


       }





       final parcelas =
       snapshot.data!.docs;





       return Padding(


         padding:
         const EdgeInsets.all(16),



         child:
         Column(


           children:[



             ...parcelas.map((p){


               final item =
               p.data();


               final pago =
                   item["status"]=="pago";



               return Card(


                 elevation:
                 0,


                 child:
                 ListTile(



                   leading:
                   CircleAvatar(


                     backgroundColor:

                     pago

                         ?

                     Colors.green.shade100

                         :

                     Colors.orange.shade100,



                     child:
                     Icon(

                       pago

                           ?
                       Icons.check

                           :
                       Icons.schedule,


                     ),


                   ),





                   title:
                   Text(

                     moeda.format(
                       item["valor"] ?? 0,
                     ),

                   ),




                   subtitle:
                   Text(

                     "Vencimento: ${_formatar(item["vencimento"])}",

                   ),




                   trailing:

                   pago

                       ?

                   const Icon(
                     Icons.check_circle,
                     color:
                     Colors.green,
                   )

                       :

                   ElevatedButton(

                     onPressed:(){

                       pagarParcela(
                         dividaId,
                         p.id,
                       );

                     },


                     child:
                     const Text(
                       "Pagar",
                     ),

                   ),


                 ),


               );


             }),






             const SizedBox(
               height:10,
             ),





             SizedBox(


               width:
               double.infinity,



               child:
               ElevatedButton.icon(


                 style:
                 ElevatedButton.styleFrom(


                   backgroundColor:
                   Colors.green,

                   padding:
                   const EdgeInsets.all(16),

                 ),



                 icon:
                 const Icon(
                   Icons.done_all,
                 ),



                 label:
                 const Text(

                  
                   "QUITAR DÍVIDA",
                 ),



                 onPressed:(){

                   quitar(dividaId);

                 },



               ),


             )



           ],


         ),


       );


     },


   );


 }









 String _formatar(dynamic valor){


   if(valor is Timestamp){


     final d =
     valor.toDate();


     return
       "${d.day.toString().padLeft(2,'0')}/"
           "${d.month.toString().padLeft(2,'0')}/"
           "${d.year}";


   }


   return "-";


 }



}