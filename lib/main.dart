import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'firebase_options.dart';


// AUTH
import 'views/auth/login_page.dart';
import 'views/auth/auth_check_page.dart';


// HOME
import 'views/home/admin_home.dart';
import 'views/home/cliente_home.dart';


// PROPOSTAS
import 'views/propostas/admin/propostas_admin_page.dart';
import 'views/propostas/admin/nova_proposta_page.dart';

import 'views/propostas/cliente/minhas_propostas_page.dart';
import 'views/propostas/cliente/assinatura_page.dart';





Future<void> main() async {


  WidgetsFlutterBinding.ensureInitialized();


  await Firebase.initializeApp(

    options:

    DefaultFirebaseOptions.currentPlatform,

  );



  runApp(

    const GestorHarasApp(),

  );


}









class GestorHarasApp extends StatelessWidget {


  const GestorHarasApp({

    super.key,

  });





  @override
  Widget build(BuildContext context) {


    return MaterialApp(


      title:

      "Gestor Haras",



      debugShowCheckedModeBanner:

      false,




      theme:


      ThemeData(


        useMaterial3:

        true,



        colorScheme:

        ColorScheme.fromSeed(


          seedColor:

          const Color(

            0xFF1565C0,

          ),


        ),






        scaffoldBackgroundColor:

        const Color(

          0xffF4F6FA,

        ),







        appBarTheme:


        const AppBarTheme(



          centerTitle:

          true,



          elevation:

          0,



          backgroundColor:

          Colors.white,



          foregroundColor:

          Colors.black,


        ),









        inputDecorationTheme:



        InputDecorationTheme(



          filled:

          true,



          fillColor:

          Colors.white,





          border:


          OutlineInputBorder(



            borderRadius:

            BorderRadius.circular(

              14,

            ),



            borderSide:

            BorderSide.none,



          ),



        ),



      ),







      initialRoute:


      "/auth-check",





      routes:{



        // ==============================
        // AUTH
        // ==============================


        "/auth-check":


        (context) =>


        const AuthCheckPage(),






        "/login":


        (context) =>


        const LoginPage(),







        // ==============================
        // HOME
        // ==============================


        "/admin":


        (context) =>


        const AdminHome(),






        "/cliente":


        (context) =>


        const ClienteHome(),











        // ==============================
        // PROPOSTAS ADMIN
        // ==============================


        "/propostas-admin":


        (context) =>


        const PropostasAdminPage(),







        "/nova-proposta":


        (context) =>


        const NovaPropostaPage(),










        // ==============================
        // PROPOSTAS CLIENTE
        // ==============================


        "/propostas-cliente":


        (context) =>


        const PropostasClientePage(),





        // ==============================
        // ASSINATURA CONTRATO
        // ==============================


        "/assinatura-contrato":


        (context) {



          final args =


          ModalRoute.of(context)

              ?.settings

              .arguments;





          if(args == null || args is! String){



            return const Scaffold(



              body:



              Center(



                child:



                Text(

                  "Proposta inválida",

                ),



              ),



            );


          }






          return FutureBuilder<

              DocumentSnapshot<Map<String,dynamic>>

          >(



            future:



            FirebaseFirestore.instance



                .collection("propostas")



                .doc(args)



                .get(),





            builder:



            (context, snapshot){






              if(snapshot.connectionState ==

                  ConnectionState.waiting){



                return const Scaffold(



                  body:



                  Center(



                    child:



                    CircularProgressIndicator(),



                  ),



                );


              }








              if(!snapshot.hasData ||

                  !snapshot.data!.exists){



                return const Scaffold(



                  body:



                  Center(



                    child:



                    Text(

                      "Proposta não encontrada",

                    ),



                  ),



                );


              }








              final dados =



              snapshot.data!.data();







              final contratoUrl =



              dados?["contratoUrl"] ?? "";








              return AssinaturaPage(




                propostaId:



                args,





                contratoUrl:



                contratoUrl.toString(),





              );



            },



          );



        },









        // ==============================
        // NOVO CAVALO
        // ==============================
        //
        // Removida: NovoCavaloPage não existe no
        // projeto. O cadastro de cavalo agora é feito
        // via CadastroCavaloPage (menu "Cadastro" do admin).


      },








      onUnknownRoute:




      (settings){





        return MaterialPageRoute(




          builder:




          (_) =>






          const Scaffold(





            body:





            Center(





              child:





              Text(





                "Página não encontrada",





              ),





            ),





          ),





        );





      },




    );



  }



}