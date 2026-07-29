// ignore_for_file: unnecessary_underscores, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../services/auth_service.dart';

import '../home/admin_home.dart';
import '../home/cliente_home.dart';
import 'register_page.dart';



class LoginPage extends StatefulWidget {


  const LoginPage({
    super.key,
  });



  @override
  State<LoginPage> createState() =>
      _LoginPageState();

}







class _LoginPageState
    extends State<LoginPage> {



  final TextEditingController email =
      TextEditingController();



  final TextEditingController senha =
      TextEditingController();





  final AuthService auth =
      AuthService();





  bool loading = false;


  bool ocultarSenha = true;







  final Color primaria =
      const Color(0xFF37474F);




  final Color fundo =
      const Color(0xFFF1F3F5);






  @override
  void dispose() {


    email.dispose();

    senha.dispose();


    super.dispose();


  }








  Future<void> logar() async {



    if(email.text.trim().isEmpty ||
        senha.text.trim().isEmpty) {



      _mensagem(

          "Preencha email e senha",

          Colors.orange

      );


      return;

    }






    setState(() {


      loading = true;


    });






    try {



      final cred =

      await auth.login(

        email.text.trim(),

        senha.text.trim(),

      );





      final tipo =

      await auth.getTipoUsuario(

          cred.user!.uid

      );





      if(!mounted) return;







      if(tipo == "admin" ||
          tipo == "superadmin") {



        Navigator.pushReplacement(

          context,

          MaterialPageRoute(

            builder: (_) =>
            const AdminHome(),

          ),

        );



      } else {



        Navigator.pushReplacement(

          context,

          MaterialPageRoute(

            builder: (_) =>
            const ClienteHome(),

          ),

        );



      }







    }



    on FirebaseAuthException catch(e) {



      String texto =
      "Email ou senha incorretos";




      switch(e.code) {



        case "invalid-email":

          texto =
          "Email inválido";

          break;




        case "user-disabled":

          texto =
          "Usuário desativado";

          break;




        case "network-request-failed":

          texto =
          "Sem conexão com internet";

          break;




        case "too-many-requests":

          texto =
          "Muitas tentativas. Aguarde.";

          break;



      }






      if(mounted){


        _mensagem(

          texto,

          Colors.red,

        );


      }




    }



    catch(e) {



      if(mounted){


        _mensagem(

          "Erro ao acessar sistema",

          Colors.red,

        );


      }


    }






    if(mounted){


      setState(() {


        loading = false;


      });


    }




  }







  void _mensagem(

      String texto,

      Color cor,

      ) {


    ScaffoldMessenger.of(context)
        .showSnackBar(



      SnackBar(


        backgroundColor:
        cor,



        behavior:
        SnackBarBehavior.floating,



        shape:

        RoundedRectangleBorder(


          borderRadius:

          BorderRadius.circular(15),


        ),




        content:

        Text(


          texto,


          style:

          const TextStyle(


            fontWeight:

            FontWeight.bold,


          ),


        ),



      ),


    );

  }

    InputDecoration _campo(

      String titulo,

      IconData icone,

      ) {


    return InputDecoration(



      labelText:

      titulo,



      labelStyle:

      TextStyle(

        color:

        Colors.grey.shade700,

        fontWeight:

        FontWeight.w500,

      ),





      prefixIcon:

      Icon(

        icone,

        color:

        primaria,

      ),





      suffixIcon:

      titulo == "Senha"

          ?

      IconButton(

        icon:

        Icon(

          ocultarSenha

              ?

          Icons.visibility_off_outlined

              :

          Icons.visibility_outlined,



          color:

          primaria,

        ),



        onPressed: () {


          setState(() {


            ocultarSenha =

            !ocultarSenha;


          });


        },


      )

          :

      null,







      filled:

      true,





      fillColor:

      const Color(0xFFF5F5F5),







      enabledBorder:

      OutlineInputBorder(



        borderRadius:

        BorderRadius.circular(16),





        borderSide:

        BorderSide(

          color:

          Colors.grey.shade300,

        ),



      ),







      focusedBorder:

      OutlineInputBorder(



        borderRadius:

        BorderRadius.circular(16),




        borderSide:

        BorderSide(



          color:

          primaria,



          width:

          2,



        ),



      ),





      contentPadding:

      const EdgeInsets.symmetric(



        horizontal:

        16,



        vertical:

        18,



      ),



    );


  }









  Widget _logo(){


    return Container(



      width:

      90,



      height:

      90,



      padding:

      const EdgeInsets.all(15),



      decoration:

      BoxDecoration(



        color:

        primaria.withOpacity(.10),



        shape:

        BoxShape.circle,



      ),




      child:

      Image.asset(



        "assets/images/logo.png",



        fit:

        BoxFit.contain,



        errorBuilder:

            (_,__,___){


          return Icon(



            Icons.home_work_outlined,



            size:

            45,



            color:

            primaria,



          );


        },


      ),



    );



  }









  Widget _titulo(){



    return Column(



      children: [



        Text(



          "Gestor Haras",



          style:

          TextStyle(



            color:

            primaria,



            fontSize:

            28,



            fontWeight:

            FontWeight.bold,



          ),



        ),






        const SizedBox(

          height:

          5,

        ),







        Text(



          "Sistema de Gestão",



          style:

          TextStyle(



            color:

            Colors.grey.shade600,



            fontSize:

            15,



          ),



        ),



      ],



    );


  }









  Widget _botaoEntrar(){



    return SizedBox(



      width:

      double.infinity,



      height:

      55,



      child:

      ElevatedButton(



        style:

        ElevatedButton.styleFrom(



          backgroundColor:

          primaria,



          foregroundColor:

          Colors.white,



          elevation:

          2,



          shape:

          RoundedRectangleBorder(



            borderRadius:

            BorderRadius.circular(18),



          ),



        ),






        onPressed:

        loading

            ?

        null

            :

        logar,






        child:

        loading

            ?



        const SizedBox(



          height:

          24,



          width:

          24,



          child:

          CircularProgressIndicator(



            strokeWidth:

            2,



            color:

            Colors.white,



          ),



        )



            :



        const Text(



          "ENTRAR",



          style:

          TextStyle(



            fontWeight:

            FontWeight.bold,



            fontSize:

            16,



            letterSpacing:

            1.2,



          ),



        ),



      ),



    );


  }

    @override
  Widget build(BuildContext context) {


    return Scaffold(



      backgroundColor:

      fundo,





      body:

      SafeArea(



        child:

        Center(



          child:

          SingleChildScrollView(



            padding:

            const EdgeInsets.all(24),







            child:

            Container(



              constraints:

              const BoxConstraints(

                maxWidth:

                430,

              ),





              padding:

              const EdgeInsets.all(32),






              decoration:

              BoxDecoration(



                color:

                Colors.white,





                borderRadius:

                BorderRadius.circular(28),





                boxShadow:[



                  BoxShadow(



                    color:

                    Colors.black.withOpacity(.08),



                    blurRadius:

                    25,



                    offset:

                    const Offset(

                        0,

                        10

                    ),



                  ),



                ],



              ),







              child:

              Column(



                mainAxisSize:

                MainAxisSize.min,



                children: [





                  _logo(),





                  const SizedBox(

                    height:

                    20,

                  ),






                  _titulo(),





                  const SizedBox(

                    height:

                    35,

                  ),







                  TextField(



                    controller:

                    email,



                    keyboardType:

                    TextInputType.emailAddress,



                    decoration:

                    _campo(



                      "Email",



                      Icons.email_outlined,



                    ),



                  ),






                  const SizedBox(

                    height:

                    18,

                  ),







                  TextField(



                    controller:

                    senha,



                    obscureText:

                    ocultarSenha,



                    decoration:

                    _campo(



                      "Senha",



                      Icons.lock_outline,



                    ),



                  ),







                  const SizedBox(

                    height:

                    30,

                  ),







                  _botaoEntrar(),







                  const SizedBox(

                    height:

                    15,

                  ),








                  TextButton(



                    onPressed: () {



                      Navigator.push(



                        context,



                        MaterialPageRoute(



                          builder: (_) =>

                          const RegisterPage(),



                        ),



                      );



                    },






                    child:

                    Text(



                      "Não possui conta? Criar cadastro",



                      style:

                      TextStyle(



                        color:

                        primaria,



                        fontWeight:

                        FontWeight.w600,



                      ),



                    ),



                  ),






                ],



              ),




            ),



          ),



        ),



      ),



    );

  }


}