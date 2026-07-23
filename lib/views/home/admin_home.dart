// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../services/dashboard_service.dart';

import '../auth/login_page.dart';

import '../financeiro/financeiro_page.dart';
import '../financeiro/nova_conta_page.dart';

import '../clientes/clientes_page.dart';

import '../propostas/admin/propostas_admin_page.dart';

import '../admin/admin_cavalos_page.dart';



class AdminHome extends StatefulWidget {

  const AdminHome({
    super.key,
  });


  @override
  State<AdminHome> createState() =>
      _AdminHomeState();

}






class _AdminHomeState
    extends State<AdminHome> {


  final DashboardService service =
      DashboardService();



  double clientes = 0;
  double cavalos = 0;
  double propostas = 0;

  double recebido = 0;
  double pendente = 0;
  double total = 0;





  @override
  void initState(){

    super.initState();

    carregar();

  }







  Future<void> carregar() async {


    final data =
        await service.getResumo();



    if(!mounted)return;



    setState((){


      clientes =
          (data["clientes"] ?? 0)
              .toDouble();



      cavalos =
          (data["cavalos"] ?? 0)
              .toDouble();



      propostas =
          (data["propostas"] ?? 0)
              .toDouble();




      recebido =
          (data["recebido"] ?? 0)
              .toDouble();




      pendente =
          (data["pendente"] ?? 0)
              .toDouble();




      total =
          (data["total"] ?? 0)
              .toDouble();



    });


  }









  Future<void> logout() async {


    await FirebaseAuth.instance.signOut();



    if(!mounted)return;



    Navigator.pushAndRemoveUntil(

      context,


      MaterialPageRoute(

        builder: (_) =>
            const LoginPage(),

      ),


      (route)=>false,


    );


  }









  void abrirTela(Widget pagina){


    Navigator.push(

      context,


      MaterialPageRoute(

        builder: (_) =>
            pagina,

      ),


    );


  }









  Stream<QuerySnapshot<Map<String,dynamic>>>
  ultimosClientes(){


    return FirebaseFirestore.instance

        .collection("clientes")

        .limit(5)

        .snapshots();


  }









  @override
  Widget build(BuildContext context){



    final largura =
        MediaQuery.of(context)
            .size
            .width;



    final mobile =
        largura < 600;



    final tablet =
        largura >= 600 &&
        largura < 1100;





    return Scaffold(


      backgroundColor:
      const Color(0xffF4F6FA),






      appBar: AppBar(


        elevation:0,


        backgroundColor:
        Colors.white,



        title:

        const Text(


          "Dashboard Admin",


          style:


          TextStyle(


            color:
            Color(0xff3E2723),


            fontWeight:
            FontWeight.bold,


          ),


        ),





        actions:[



          IconButton(


            icon:

            const Icon(


              Icons.logout,


              color:
              Colors.red,


            ),



            onPressed:
            logout,


          )


        ],



      ),









      body:

      RefreshIndicator(


        onRefresh:
        carregar,



        child:



        Center(


          child:

          ConstrainedBox(


            constraints:

            const BoxConstraints(

              maxWidth:1300,

            ),



            child:

            ListView(



              padding:

              EdgeInsets.all(

                mobile
                ? 12
                : 18,

              ),





              children:[





                _cabecalho(),





                const SizedBox(

                  height:20,

                ),





                const Text(

                  "Resumo Geral",


                  style:

                  TextStyle(

                    fontSize:20,

                    fontWeight:
                    FontWeight.bold,

                    color:
                    Color(0xff3E2723),

                  ),


                ),





                const SizedBox(

                  height:12,

                ),






                GridView.count(



                  shrinkWrap:true,


                  physics:

                  const NeverScrollableScrollPhysics(),





                  crossAxisCount:


                  mobile

                  ? 2


                  : tablet

                  ? 3


                  : 6,





                  crossAxisSpacing:12,


                  mainAxisSpacing:12,





                  childAspectRatio:


                  mobile

                  ? 1.15


                  : tablet

                  ? 1.45


                  : 1.80,





                  children:[



                    _cardResumo(

                      "Clientes",

                      clientes
                          .toInt()
                          .toString(),

                      Icons.people,

                      Colors.blue,

                    ),




                    _cardResumo(

                      "Cavalos",

                      cavalos
                          .toInt()
                          .toString(),

                      Icons.pets,

                      Colors.brown,

                    ),




                    _cardResumo(

                      "Propostas",

                      propostas
                          .toInt()
                          .toString(),

                      Icons.description,

                      Colors.purple,

                    ),





                    _cardResumo(

                      "Recebido",

                      "R\$ ${recebido.toStringAsFixed(2)}",

                      Icons.check_circle,

                      Colors.green,

                    ),





                    _cardResumo(

                      "Pendente",

                      "R\$ ${pendente.toStringAsFixed(2)}",

                      Icons.warning,

                      Colors.orange,

                    ),





                    _cardResumo(

                      "Financeiro",

                      "R\$ ${total.toStringAsFixed(2)}",

                      Icons.account_balance_wallet,

                      Colors.indigo,

                    ),



                  ],


                ),




                const SizedBox(

                  height:25,

                ),




                const Text(

                  "Acesso Rápido",


                  style:

                  TextStyle(

                    fontSize:20,

                    fontWeight:
                    FontWeight.bold,

                    color:
                    Color(0xff3E2723),

                  ),


                ),





                const SizedBox(

                  height:12,

                ),






                GridView.count(


                  shrinkWrap:true,


                  physics:

                  const NeverScrollableScrollPhysics(),




                  crossAxisCount:


                  mobile

                  ? 2


                  : tablet

                  ? 3


                  : 5,





                  crossAxisSpacing:12,


                  mainAxisSpacing:12,





                  childAspectRatio:


                  mobile

                  ? 1.10


                  : 1.40,





                  children:[



                    _menu(

                      "Financeiro",

                      Icons.account_balance_wallet,

                      Colors.green,

                      () => abrirTela(

                        const FinanceiroPage(),

                      ),

                    ),




                    _menu(

                      "Nova Conta",

                      Icons.add_circle,

                      Colors.orange,

                      () => abrirTela(

                        const NovaContaPage(),

                      ),

                    ),




                    _menu(

                      "Clientes",

                      Icons.people,

                      Colors.blue,

                      () => abrirTela(

                        ClientesPage(),

                      ),

                    ),




                    _menu(

                      "Cavalos",

                      Icons.pets,

                      Colors.brown,

                      () => abrirTela(

                        const AdminCavalosPage(),

                      ),

                    ),




                    _menu(

                      "Propostas",

                      Icons.description,

                      Colors.purple,

                      () => abrirTela(

                        const PropostasAdminPage(),

                      ),

                    ),


                  ],


                ),



                const SizedBox(

                  height:25,

                ),




                const Text(

                  "Últimos Clientes",


                  style:

                  TextStyle(

                    fontSize:20,

                    fontWeight:
                    FontWeight.bold,

                  ),


                ),




                const SizedBox(

                  height:12,

                ),




                _listaClientes(),



              ],


            ),


          ),


        ),


      ),


    );


  }

    Widget _cabecalho() {

    return Container(

      padding:
          const EdgeInsets.all(20),

      decoration:

      BoxDecoration(

        gradient:

        const LinearGradient(

          colors:[

            Color(0xff3E2723),

            Color(0xff795548),

          ],

        ),


        borderRadius:

        BorderRadius.circular(22),


        boxShadow:[


          BoxShadow(

            color:
            Colors.black.withOpacity(.12),

            blurRadius:12,

            offset:
            const Offset(0,6),

          ),

        ],

      ),


      child:

      Column(

        crossAxisAlignment:
        CrossAxisAlignment.start,


        children:[


          const Text(

            "Gestor Haras",

            maxLines:1,

            overflow:
            TextOverflow.ellipsis,


            style:

            TextStyle(

              color:
              Colors.white,

              fontSize:24,

              fontWeight:
              FontWeight.bold,

            ),

          ),



          const SizedBox(
            height:8,
          ),



          Text(

            "Controle administrativo do seu haras",

            maxLines:2,

            overflow:
            TextOverflow.ellipsis,


            style:

            TextStyle(

              color:
              Colors.white.withOpacity(.85),

              fontSize:14,

            ),

          ),


        ],


      ),


    );

  }







  Widget _listaClientes(){


    return StreamBuilder<

        QuerySnapshot<Map<String,dynamic>>>(


      stream:
      ultimosClientes(),


      builder:(context,snapshot){



        if(snapshot.connectionState ==
            ConnectionState.waiting){


          return const Center(

            child:
            CircularProgressIndicator(),

          );


        }




        if(!snapshot.hasData ||
            snapshot.data!.docs.isEmpty){



          return Card(


            child:

            Padding(

              padding:
              const EdgeInsets.all(20),


              child:

              Column(

                children:[


                  const Icon(

                    Icons.people_outline,

                    size:45,

                    color:
                    Colors.grey,

                  ),


                  const SizedBox(
                    height:10,
                  ),



                  const Text(
                    "Nenhum cliente cadastrado",
                  ),


                ],


              ),


            ),


          );


        }




        return Column(

          children:

          snapshot.data!.docs.map((doc){


            final data =
            doc.data();



            final nome =
                data["nome"] ??
                "Cliente";



            final email =
                data["email"] ??
                "";



            final telefone =
                data["telefone"] ??
                "";




            return Card(

              elevation:2,


              margin:

              const EdgeInsets.only(
                bottom:10,
              ),



              shape:

              RoundedRectangleBorder(

                borderRadius:
                BorderRadius.circular(16),

              ),



              child:

              ListTile(



                leading:

                CircleAvatar(


                  backgroundColor:

                  const Color(
                    0xff5D4037,
                  ),


                  child:

                  Text(

                    nome
                    .toString()
                    .substring(0,1)
                    .toUpperCase(),


                    style:

                    const TextStyle(

                      color:
                      Colors.white,

                      fontWeight:
                      FontWeight.bold,

                    ),

                  ),


                ),





                title:

                Text(

                  nome,

                  maxLines:1,

                  overflow:
                  TextOverflow.ellipsis,


                  style:

                  const TextStyle(

                    fontWeight:
                    FontWeight.bold,

                  ),

                ),





                subtitle:

                Column(

                  crossAxisAlignment:
                  CrossAxisAlignment.start,


                  children:[


                    if(email
                        .toString()
                        .isNotEmpty)

                      Text(

                        email,

                        maxLines:1,

                        overflow:
                        TextOverflow.ellipsis,

                      ),




                    if(telefone
                        .toString()
                        .isNotEmpty)

                      Text(

                        telefone,

                      ),


                  ],


                ),





                trailing:

                const Icon(

                  Icons.arrow_forward_ios,

                  size:15,

                ),





                onTap:(){


                  abrirTela(
                    ClientesPage(),
                  );


                },


              ),


            );


          }).toList(),


        );


      },


    );


  }








  Widget _cardResumo(

      String titulo,

      String valor,

      IconData icon,

      Color cor,

      ){



    return Container(


      padding:

      const EdgeInsets.all(10),



      decoration:

      BoxDecoration(

        color:
        Colors.white,


        borderRadius:

        BorderRadius.circular(18),



        boxShadow:[


          BoxShadow(

            color:
            Colors.black.withOpacity(.07),

            blurRadius:8,

            offset:
            const Offset(0,3),

          ),

        ],


      ),




      child:

      Column(


        mainAxisAlignment:
        MainAxisAlignment.center,


        crossAxisAlignment:
        CrossAxisAlignment.start,



        children:[



          Container(

            padding:
            const EdgeInsets.all(8),


            decoration:

            BoxDecoration(

              color:
              cor.withOpacity(.15),

              borderRadius:
              BorderRadius.circular(10),

            ),



            child:

            Icon(

              icon,

              color:
              cor,

              size:22,

            ),


          ),





          const SizedBox(
            height:8,
          ),





          Flexible(

            child:

            Text(

              valor,


              maxLines:1,


              overflow:
              TextOverflow.ellipsis,


              style:

              const TextStyle(

                fontSize:16,

                fontWeight:
                FontWeight.bold,

              ),


            ),

          ),






          const SizedBox(
            height:3,
          ),






          Text(

            titulo,


            maxLines:1,


            overflow:
            TextOverflow.ellipsis,


            style:

            const TextStyle(

              fontSize:11,

              color:
              Colors.grey,

            ),


          ),



        ],


      ),


    );


  }









  Widget _menu(

      String titulo,

      IconData icon,

      Color cor,

      VoidCallback onTap,

      ){



    return InkWell(


      borderRadius:

      BorderRadius.circular(18),



      onTap:
      onTap,



      child:

      Container(



        padding:

        const EdgeInsets.all(10),



        decoration:

        BoxDecoration(

          color:
          Colors.white,


          borderRadius:

          BorderRadius.circular(18),



          boxShadow:[


            BoxShadow(

              color:
              Colors.black.withOpacity(.07),

              blurRadius:8,

              offset:
              const Offset(0,3),

            ),


          ],


        ),





        child:

        Column(



          mainAxisAlignment:

          MainAxisAlignment.center,



          children:[




            Container(


              padding:

              const EdgeInsets.all(9),



              decoration:

              BoxDecoration(

                color:
                cor.withOpacity(.15),


                shape:
                BoxShape.circle,

              ),




              child:

              Icon(

                icon,

                color:
                cor,

                size:22,

              ),



            ),





            const SizedBox(
              height:8,
            ),





            Flexible(

              child:

              Text(

                titulo,


                maxLines:2,


                overflow:
                TextOverflow.ellipsis,


                textAlign:
                TextAlign.center,


                style:

                const TextStyle(

                  fontSize:11,

                  fontWeight:
                  FontWeight.w600,

                ),


              ),

            ),




          ],


        ),



      ),



    );


  }


}