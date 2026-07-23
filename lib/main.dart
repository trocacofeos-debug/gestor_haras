import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';


// AUTH
import 'views/auth/login_page.dart';


// HOME
import 'views/home/admin_home.dart';
import 'views/home/cliente_home.dart';


// PROPOSTAS
import 'views/propostas/admin/propostas_admin_page.dart';
import 'views/propostas/admin/nova_proposta_page.dart';

import 'views/propostas/cliente/minhas_propostas_page.dart';
import 'views/propostas/cliente/assinatura_page.dart';


// CAVALOS
import 'views/cavalos/cavalos_page.dart';

import 'views/admin/admin_cavalos_page.dart';
import 'views/admin/novo_cavalo_page.dart';





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
            0xFF5D4037,
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
      "/login",





      routes:{



        // LOGIN

        "/login":

            (context) =>
        const LoginPage(),






        // HOME ADMIN

        "/admin":

            (context) =>
        const AdminHome(),






        // HOME CLIENTE

        "/cliente":

            (context) =>
        const ClienteHome(),








        // ==============================
        // PROPOSTAS
        // ==============================


        "/propostas-admin":

            (context) =>
        const PropostasAdminPage(),






        "/propostas-cliente":

            (context) =>
        const PropostasClientePage(),







        "/nova-proposta":

            (context) =>
        const NovaPropostaPage(),







        // ==============================
        // ASSINATURA CONTRATO
        // ==============================


        "/assinatura-contrato":


            (context) {


          final args =

          ModalRoute.of(context)
              ?.settings
              .arguments;



          if(args == null ||
              args is! String){


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




          return AssinaturaPage(


            propostaId:

            args,


          );


        },








        // ==============================
        // CAVALOS CLIENTE
        // ==============================


        "/cavalos":


            (context) =>

        const CavalosPage(),










        // ==============================
        // CAVALOS ADMIN
        // ==============================


        "/admin-cavalos":


            (context) =>

        const AdminCavalosPage(),










        // ==============================
        // NOVO CAVALO
        // ==============================


        "/novo-cavalo":


            (context) =>

        const NovoCavaloPage(),





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