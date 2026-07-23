// ignore_for_file: deprecated_member_use

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



  final email =
      TextEditingController();


  final senha =
      TextEditingController();



  final AuthService auth =
      AuthService();



  bool loading = false;







  Future<void> logar() async {


    if(email.text.trim().isEmpty ||
       senha.text.trim().isEmpty){


      ScaffoldMessenger.of(context)
          .showSnackBar(

        const SnackBar(

          backgroundColor:
          Colors.orange,

          content:
          Text(
            "Preencha email e senha",
          ),

        ),

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
            cred.user!.uid,
          );






      if(!mounted) return;







      if(tipo == "admin"){



        Navigator.pushReplacement(

          context,

          MaterialPageRoute(

            builder: (_) =>
            const AdminHome(),

          ),

        );




      }else{



        Navigator.pushReplacement(

          context,

          MaterialPageRoute(

            builder: (_) =>
            const ClienteHome(),

          ),

        );


      }






    }

    on FirebaseAuthException catch(e){



      String mensagem =
          "Email ou senha incorretos";




      switch(e.code){



        case "invalid-email":

          mensagem =
          "Email inválido";

          break;




        case "user-disabled":

          mensagem =
          "Usuário desativado";

          break;




        case "too-many-requests":

          mensagem =
          "Muitas tentativas. Aguarde alguns minutos";

          break;




        case "network-request-failed":

          mensagem =
          "Sem conexão com a internet";

          break;




        case "wrong-password":

          mensagem =
          "Email ou senha incorretos";

          break;




        case "user-not-found":

          mensagem =
          "Email ou senha incorretos";

          break;




        case "invalid-credential":

          mensagem =
          "Email ou senha incorretos";

          break;


      }





      if(!mounted) return;




      ScaffoldMessenger.of(context)
          .showSnackBar(

        SnackBar(

          backgroundColor:
          Colors.red.shade900,


          content:
          Text(

            mensagem,

            style:
            const TextStyle(

              fontWeight:
              FontWeight.bold,

            ),

          ),

        ),

      );



    }

    catch(e){



      if(!mounted)return;



      ScaffoldMessenger.of(context)
          .showSnackBar(

        const SnackBar(

          backgroundColor:
          Colors.red,

          content:
          Text(
            "Erro ao realizar login",
          ),

        ),

      );


    }




    if(mounted){


      setState(() {

        loading = false;

      });


    }


  }







  InputDecoration campo(

      String texto,

      IconData icon,

      ){

    return InputDecoration(


      labelText:
      texto,



      labelStyle:
      const TextStyle(

        color:
        Colors.white70,

      ),




      prefixIcon:
      Icon(

        icon,

        color:
        Color(0xFFD4AF37),

      ),




      filled:
      true,



      fillColor:
      Colors.white.withOpacity(.08),




      enabledBorder:
      OutlineInputBorder(


        borderRadius:
        BorderRadius.circular(18),



        borderSide:
        BorderSide(

          color:
          Colors.white.withOpacity(.15),

        ),


      ),





      focusedBorder:
      OutlineInputBorder(


        borderRadius:
        BorderRadius.circular(18),



        borderSide:
        const BorderSide(

          color:
          Color(0xFFD4AF37),

          width:
          2,

        ),


      ),


    );


  }

    @override
  Widget build(BuildContext context) {


    return Scaffold(


      backgroundColor:
      const Color(0xFF050505),



      body:

      Stack(


        children:[




          Container(


            decoration:
            const BoxDecoration(


              gradient:
              LinearGradient(


                begin:
                Alignment.topCenter,


                end:
                Alignment.bottomCenter,



                colors:[


                  Color(0xFF000000),


                  Color(0xFF15100A),


                  Color(0xFF050505),



                ],


              ),


            ),


          ),







          Center(



            child:


            SingleChildScrollView(



              padding:
              const EdgeInsets.all(25),




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
                  Colors.white.withOpacity(.06),




                  borderRadius:
                  BorderRadius.circular(35),




                  border:
                  Border.all(



                    color:
                    const Color(0xFFD4AF37)
                        .withOpacity(.25),



                  ),




                  boxShadow:[



                    BoxShadow(



                      color:
                      Colors.black.withOpacity(.5),



                      blurRadius:
                      40,



                      offset:
                      const Offset(0,20),



                    ),


                  ],



                ),






                child:


                Column(



                  mainAxisSize:
                  MainAxisSize.min,



                  children:[






                    Image.asset(


                      "assets/images/logo-dour.png",


                      height:
                      110,



                    ),






                    const SizedBox(

                      height:
                      25,

                    ),






                    const Text(



                      "Gestor Haras",



                      style:
                      TextStyle(



                        fontFamily:
                        "Cinzel",



                        fontSize:
                        30,



                        fontWeight:
                        FontWeight.bold,



                        color:
                        Color(0xFFD4AF37),



                      ),



                    ),






                    const SizedBox(

                      height:
                      8,

                    ),






                    const Text(



                      "Acesso ao sistema",



                      style:
                      TextStyle(



                        color:
                        Colors.white70,



                        fontSize:
                        14,



                      ),



                    ),






                    const SizedBox(

                      height:
                      35,

                    ),







                    TextField(



                      controller:
                      email,



                      style:
                      const TextStyle(

                        color:
                        Colors.white,

                      ),




                      decoration:
                      campo(

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
                      true,



                      style:
                      const TextStyle(

                        color:
                        Colors.white,

                      ),





                      decoration:
                      campo(

                        "Senha",

                        Icons.lock_outline,

                      ),



                    ),







                    const SizedBox(

                      height:
                      30,

                    ),








                    SizedBox(



                      width:
                      double.infinity,



                      height:
                      55,






                      child:

                      ElevatedButton(





                        style:
                        ElevatedButton.styleFrom(




                          backgroundColor:
                          const Color(0xFFD4AF37),





                          foregroundColor:
                          Colors.black,






                          shape:

                          RoundedRectangleBorder(



                            borderRadius:
                            BorderRadius.circular(30),



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
                          22,



                          width:
                          22,



                          child:
                          CircularProgressIndicator(



                            strokeWidth:
                            2,



                            color:
                            Colors.black,



                          ),



                        )



                            :



                        const Text(



                          "ENTRAR",



                          style:

                          TextStyle(



                            fontWeight:
                            FontWeight.bold,



                            letterSpacing:
                            2,



                          ),



                        ),





                      ),



                    ),







                    const SizedBox(

                      height:
                      15,

                    ),







                    TextButton(



                      onPressed:



                      (){



                        Navigator.push(



                          context,



                          MaterialPageRoute(



                            builder:
                                (_)=>

                            const RegisterPage(),



                          ),



                        );



                      },






                      child:


                      const Text(



                        "Não possui conta? Criar cadastro",



                        style:
                        TextStyle(



                          color:
                          Color(0xFFD4AF37),



                        ),



                      ),



                    ),






                  ],



                ),




              ),



            ),



          ),





        ],



      ),



    );

  }


}