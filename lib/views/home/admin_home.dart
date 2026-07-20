import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


import '../../services/dashboard_service.dart';


import '../auth/login_page.dart';


import '../financeiro/financeiro_page.dart';
import '../financeiro/nova_conta_page.dart';


import '../clientes/clientes_page.dart';


import '../propostas/admin/propostas_admin_page.dart';


// CAVALOS
import '../admin/admin_cavalos_page.dart';





class AdminHome extends StatefulWidget {


  const AdminHome({
    super.key,
  });



  @override
  State<AdminHome> createState() =>
      _AdminHomeState();


}







class _AdminHomeState extends State<AdminHome> {


  final DashboardService service =
      DashboardService();



  double clientes = 0;

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




    setState(() {



      clientes =

      (data["clientes"] ?? 0)
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



        builder:(_)=>

        const LoginPage(),



      ),



          (route)=>false,



    );



  }







  void abrirTela(Widget pagina){



    Navigator.push(



      context,



      MaterialPageRoute(



        builder:(_)=>pagina,



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



    return Scaffold(



      backgroundColor:

      const Color(
        0xffF4F6FA,
      ),





      appBar:

      AppBar(



        elevation:

        0,



        title:

        const Text(

          "Dashboard Admin",

        ),




        backgroundColor:

        Colors.white,




        actions:[



          IconButton(



            icon:

            const Icon(

              Icons.logout,

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

        ListView(



          physics:

          const AlwaysScrollableScrollPhysics(),



          padding:

          const EdgeInsets.all(16),



          children:[



            Row(


              children:[


                _cardResumo(

                  "Clientes",

                  clientes.toInt().toString(),

                  Icons.people,

                  Colors.blue,

                ),



                _cardResumo(

                  "Recebido",

                  "R\$ ${recebido.toStringAsFixed(2)}",

                  Icons.check_circle,

                  Colors.green,

                ),



              ],



            ),




            Row(



              children:[



                _cardResumo(

                  "Pendente",

                  "R\$ ${pendente.toStringAsFixed(2)}",

                  Icons.warning,

                  Colors.orange,

                ),





                _cardResumo(

                  "Total",

                  "R\$ ${total.toStringAsFixed(2)}",

                  Icons.attach_money,

                  Colors.purple,

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

                fontSize:18,

                fontWeight:
                FontWeight.bold,

              ),

            ),




            const SizedBox(
              height:12,
            ),


            Wrap(

              spacing:10,

              runSpacing:10,


              children:[




                _menu(

                  "Financeiro",

                  Icons.account_balance_wallet,

                  Colors.green,


                      ()=>abrirTela(

                    const FinanceiroPage(),

                  ),


                ),






                _menu(

                  "Nova Conta",

                  Icons.add_circle,

                  Colors.orange,


                      ()=>abrirTela(

                    const NovaContaPage(),

                  ),


                ),






                _menu(

                  "Clientes",

                  Icons.people,

                  Colors.blue,


                      ()=>abrirTela(

                    ClientesPage(),

                  ),


                ),







                // =========================
                // NOVO MENU - CAVALOS
                // =========================


                _menu(

                  "Cavalos",

                  Icons.pets,

                  Colors.brown,


                      ()=>abrirTela(

                    const AdminCavalosPage(),

                  ),


                ),







                _menu(

                  "Propostas",

                  Icons.description,

                  Colors.purple,


                      ()=>abrirTela(

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


                fontSize:18,


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



    );



  }









  Widget _cardResumo(


      String titulo,


      String valor,


      IconData icon,


      Color cor,


      ){





    return Expanded(



      child:

      Container(



        margin:

        const EdgeInsets.all(6),





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

              Colors.black.withValues(alpha:.05),



              blurRadius:

              10,



            ),



          ],



        ),






        child:

        Column(



          children:[





            Icon(

              icon,

              color:cor,

            ),






            const SizedBox(

              height:8,

            ),






            Text(



              valor,



              style:



              const TextStyle(



                fontSize:18,



                fontWeight:

                FontWeight.bold,



              ),



            ),








            Text(



              titulo,



              style:



              TextStyle(



                color:

                Colors.grey.shade600,



              ),



            ),





          ],




        ),





      ),



    );



  }








  Widget _menu(



      String titulo,



      IconData icon,



      Color cor,



      VoidCallback onTap,



      ){



    return SizedBox(



      width:120,





      child:

      InkWell(



        borderRadius:

        BorderRadius.circular(18),





        onTap:

        onTap,






        child:

        Container(



          padding:

          const EdgeInsets.all(14),






          decoration:

          BoxDecoration(



            color:

            Colors.white,



            borderRadius:

            BorderRadius.circular(18),



          ),






          child:

          Column(



            children:[





              CircleAvatar(



                backgroundColor:

                cor.withValues(alpha:.15),





                child:

                Icon(



                  icon,



                  color:cor,



                ),



              ),







              const SizedBox(

                height:8,

              ),







              Text(



                titulo,



                textAlign:

                TextAlign.center,



              ),






            ],




          ),




        ),




      ),




    );



  }








  Widget _listaClientes(){



    return StreamBuilder<

        QuerySnapshot<Map<String,dynamic>>

    >(



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







        if(snapshot.hasError){



          return Text(



            snapshot.error.toString(),



          );



        }








        final docs =

            snapshot.data?.docs ?? [];








        if(docs.isEmpty){



          return const Card(



            child:

            Padding(



              padding:

              EdgeInsets.all(20),




              child:

              Text(



                "Nenhum cliente cadastrado",



              ),



            ),



          );



        }







        return Column(



          children:

          docs.map((doc){






            final data =

            doc.data();









            return Card(



              elevation:

              1,





              child:

              ListTile(






                leading:

                const CircleAvatar(



                  child:

                  Icon(



                    Icons.person,



                  ),



                ),







                title:

                Text(



                  data["nome"] ??

                      "Cliente",



                ),







                subtitle:

                Text(



                  data["email"] ??

                      "Sem email",



                ),







              ),



            );







          }).toList(),





        );





      },



    );



  }





}