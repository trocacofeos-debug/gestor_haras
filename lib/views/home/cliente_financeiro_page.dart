import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'cliente_dividas_page.dart';
import '../auth/login_page.dart';



class ClienteFinanceiroPage extends StatelessWidget {


  const ClienteFinanceiroPage({
    super.key,
  });



  String get uid =>
      FirebaseAuth.instance.currentUser?.uid ?? '';






  Stream<QuerySnapshot<Map<String,dynamic>>> dividas(){


    return FirebaseFirestore.instance

        .collection("dividas")

        .where(
          "clienteId",
          isEqualTo: uid,
        )

        .where(
          "status",
          isEqualTo: "aberta",
        )

        .snapshots();


  }









  Future<double> calcularTotalAberto(
      List<QueryDocumentSnapshot<Map<String,dynamic>>> docs
      ) async {


    double total = 0;



    for(final doc in docs){



      final parcelas =
          await FirebaseFirestore.instance

              .collection("dividas")

              .doc(doc.id)

              .collection("parcelas")

              .where(
                "status",
                isEqualTo:"pendente",
              )

              .get();





      for(final parcela in parcelas.docs){


        final valor =
        parcela.data()["valor"];


        if(valor is num){

          total += valor.toDouble();

        }


      }


    }



    return total;


  }








  Future<void> logout(BuildContext context) async {


    await FirebaseAuth.instance.signOut();



    if(!context.mounted) return;



    Navigator.pushAndRemoveUntil(

      context,

      MaterialPageRoute(

        builder:(_)=>
        const LoginPage(),

      ),

      (route)=>false,

    );


  }









  @override
  Widget build(BuildContext context){


    return Scaffold(



      backgroundColor:
      const Color(0xffF4F6FA),





      appBar:
      AppBar(



        title:
        const Text(
          "Meu Financeiro",
        ),



        actions:[



          IconButton(

            icon:
            const Icon(
              Icons.logout,
            ),


            onPressed:
            ()=>logout(context),


          )



        ],



      ),







      body:

      StreamBuilder<QuerySnapshot<Map<String,dynamic>>>(



        stream:
        dividas(),




        builder:(context,snapshot){





          if(!snapshot.hasData){


            return const Center(

              child:
              CircularProgressIndicator(),

            );


          }






          final docs =
              snapshot.data!.docs;






          return FutureBuilder<double>(



            future:
            calcularTotalAberto(docs),




            builder:(context,totalSnap){





              final total =
                  totalSnap.data ?? 0;






              return ListView(



                padding:
                const EdgeInsets.all(16),





                children:[








                  Container(



                    padding:
                    const EdgeInsets.all(22),




                    decoration:
                    BoxDecoration(



                      color:
                      const Color(0xffE2E5E9),



                      borderRadius:
                      BorderRadius.circular(24),



                    ),





                    child:
                    Column(



                      crossAxisAlignment:
                      CrossAxisAlignment.start,




                      children:[





                        const Row(


                          children:[


                            Icon(
                              Icons.account_balance_wallet,
                            ),



                            SizedBox(
                              width:8,
                            ),



                            Text(

                              "Resumo Financeiro",

                              style:
                              TextStyle(

                                fontSize:18,

                                fontWeight:
                                FontWeight.bold,

                              ),

                            )



                          ],


                        ),







                        const SizedBox(
                          height:20,
                        ),







                        Text(

                          "Valor em aberto",

                          style:
                          TextStyle(

                            color:
                            Colors.grey,

                          ),

                        ),






                        const SizedBox(
                          height:8,
                        ),







                        Text(



                          "R\$ ${total.toStringAsFixed(2)}",




                          style:
                          const TextStyle(



                            fontSize:28,



                            fontWeight:
                            FontWeight.bold,



                            color:
                            Colors.red,



                          ),



                        ),






                        const SizedBox(
                          height:12,
                        ),






                        Text(

                          "${docs.length} dívida(s) aberta(s)",

                          style:
                          TextStyle(

                            color:
                            Colors.grey.shade700,

                          ),

                        )






                      ],


                    ),



                  ),









                  const SizedBox(
                    height:20,
                  ),








                  ElevatedButton.icon(




                    style:
                    ElevatedButton.styleFrom(



                      padding:
                      const EdgeInsets.all(16),



                      shape:
                      RoundedRectangleBorder(



                        borderRadius:
                        BorderRadius.circular(16),



                      ),



                    ),





                    icon:
                    const Icon(
                      Icons.receipt_long,
                    ),





                    label:
                    const Text(

                      "Ver minhas dívidas",

                      style:
                      TextStyle(

                        fontSize:16,

                      ),

                    ),





                    onPressed:(){



                      Navigator.push(



                        context,



                        MaterialPageRoute(



                          builder:(_)=>

                          const ClienteDividasPage(),



                        ),



                      );



                    },



                  ),








                ],



              );



            },



          );



        },



      ),



    );


  }


}