import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../services/auth_service.dart';

import '../home/admin_home.dart';
import '../home/cliente_home.dart';
import 'login_page.dart';



class AuthCheckPage extends StatelessWidget {


  const AuthCheckPage({
    super.key,
  });




  @override
  Widget build(BuildContext context) {


    final AuthService auth =
        AuthService();




    return StreamBuilder<User?>(



      stream:

      FirebaseAuth.instance
          .authStateChanges(),




      builder:
          (context, snapshot) {



        // ============================
        // CARREGANDO FIREBASE
        // ============================

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







        // ============================
        // NÃO LOGADO
        // ============================

        if(!snapshot.hasData){


          return const LoginPage();


        }







        // ============================
        // BUSCAR ROLE
        // ============================


        return FutureBuilder<String>(



          future:


          auth.getTipoUsuario(

            snapshot.data!.uid,

          ),





          builder:

              (context, roleSnapshot){



            if(roleSnapshot.connectionState ==
                ConnectionState.waiting){



              return const Scaffold(



                body:



                Center(



                  child:



                  CircularProgressIndicator(),



                ),



              );


            }






            final tipo =

            roleSnapshot.data ?? "cliente";







            // ============================
            // ADMIN
            // ============================


            if(tipo == "admin" ||
                tipo == "superadmin"){



              return const AdminHome();



            }








            // ============================
            // CLIENTE
            // ============================


            return const ClienteHome();




          },


        );




      },


    );


  }



}