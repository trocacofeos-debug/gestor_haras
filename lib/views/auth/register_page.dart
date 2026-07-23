// ignore_for_file: deprecated_member_use

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;


class RegisterPage extends StatefulWidget {

  const RegisterPage({
    super.key,
  });


  @override
  State<RegisterPage> createState() =>
      _RegisterPageState();

}



class _RegisterPageState extends State<RegisterPage>
    with SingleTickerProviderStateMixin {



  final _formKey =
      GlobalKey<FormState>();


  final FirebaseAuth _auth =
      FirebaseAuth.instance;


  final FirebaseFirestore _db =
      FirebaseFirestore.instance;



  late TabController _tabController;



  bool loading = false;



  // ===============================
  // CONTROLLERS
  // ===============================


  final nomeController =
      TextEditingController();


  final sobrenomeController =
      TextEditingController();


  final razaoSocialController =
      TextEditingController();


  final nomeFantasiaController =
      TextEditingController();



  final cpfCnpjController =
      TextEditingController();


  final telefoneController =
      TextEditingController();


  final emailController =
      TextEditingController();


  final senhaController =
      TextEditingController();




  final cepController =
      TextEditingController();


  final enderecoController =
      TextEditingController();


  final numeroController =
      TextEditingController();


  final bairroController =
      TextEditingController();


  final cidadeController =
      TextEditingController();


  final estadoController =
      TextEditingController();



  final nomeHarasController =
      TextEditingController();


  final idRuralController =
      TextEditingController();





  @override
  void initState(){

    super.initState();


    _tabController =
        TabController(
          length:3,
          vsync:this,
        );

  }





  // ===============================
  // BUSCAR CEP
  // ===============================


  Future<void> buscarCep(
      String cep
      ) async {


    cep =
    cep.replaceAll(
        RegExp(r'[^0-9]'),
        ''
    );


    if(cep.length != 8)
      // ignore: curly_braces_in_flow_control_structures
      return;



    try{


      final res =
      await http.get(

        Uri.parse(
          'https://viacep.com.br/ws/$cep/json/'
        ),

      );



      if(res.statusCode == 200){


        final data =
        jsonDecode(
            res.body
        );



        if(data['erro'] == true)
          // ignore: curly_braces_in_flow_control_structures
          return;



        setState((){


          enderecoController.text =
              data['logradouro'] ?? '';

          bairroController.text =
              data['bairro'] ?? '';

          cidadeController.text =
              data['localidade'] ?? '';

          estadoController.text =
              data['uf'] ?? '';


        });



      }



    }catch(_){}



  }





  // ===============================
  // CADASTRO
  // ===============================


  Future<void> register() async {


    if(!_formKey.currentState!.validate())
      // ignore: curly_braces_in_flow_control_structures
      return;



    setState(() =>
    loading = true
    );



    try{


      final tipo =
          _tabController.index;



      final userCred =
      await _auth
          .createUserWithEmailAndPassword(

        email:
        emailController.text.trim(),

        password:
        senhaController.text.trim(),

      );



      final uid =
          userCred.user!.uid;



      await _db
          .collection('users')
          .doc(uid)
          .set({


        'uid':uid,

        'email':
        emailController.text.trim(),

        'role':
        'cliente',

        'tipoCliente':
        tipo,


        'createdAt':
        FieldValue.serverTimestamp(),


      });





      await _db
          .collection('clientes')
          .doc(uid)
          .set({


        'id':uid,


        'tipoCliente':
        tipo,



        'nome':
        nomeController.text.trim(),


        'sobrenome':
        sobrenomeController.text.trim(),


        'razaoSocial':
        razaoSocialController.text.trim(),


        'nomeFantasia':
        nomeFantasiaController.text.trim(),



        'cpfCnpj':
        cpfCnpjController.text.trim(),


        'telefone':
        telefoneController.text.trim(),


        'email':
        emailController.text.trim(),



        'cep':
        cepController.text.trim(),


        'endereco':
        enderecoController.text.trim(),


        'numero':
        numeroController.text.trim(),


        'bairro':
        bairroController.text.trim(),


        'cidade':
        cidadeController.text.trim(),


        'estado':
        estadoController.text.trim(),



        'nomeHaras':
        nomeHarasController.text.trim(),


        'idRural':
        idRuralController.text.trim(),



        'createdAt':
        FieldValue.serverTimestamp(),


      });



      if(!mounted)
        // ignore: curly_braces_in_flow_control_structures
        return;



      ScaffoldMessenger.of(context)
          .showSnackBar(

        const SnackBar(

          content:
          Text(
              "Cadastro realizado com sucesso!"
          ),

        ),

      );



      Navigator.pop(context);



    }catch(e){


      ScaffoldMessenger.of(context)
          .showSnackBar(

        SnackBar(

          backgroundColor:
          Colors.red.shade900,


          content:
          Text(
              "Erro: $e"
          ),

        ),

      );


    }



    setState(() =>
    loading = false
    );


  }
    // ===============================
  // CAMPO PREMIUM
  // ===============================


  Widget field(
      String label,
      TextEditingController controller, {

        bool required = false,

      }) {


    return Padding(

      padding:
      const EdgeInsets.only(
          bottom:15
      ),


      child:

      TextFormField(

        controller:
        controller,


        style:
        const TextStyle(
          color: Colors.white,
        ),



        validator:
        required

            ?

            (v){

          if(v == null ||
              v.trim().isEmpty){

            return "Campo obrigatório";

          }

          return null;

        }

            :

            null,



        decoration:

        InputDecoration(


          labelText:
          label,



          labelStyle:

          const TextStyle(

            color:
            Colors.white70,

          ),




          filled:true,


          fillColor:

          Colors.white
              .withOpacity(.08),





          enabledBorder:

          OutlineInputBorder(

            borderRadius:

            BorderRadius.circular(
                18
            ),


            borderSide:

            BorderSide(

              color:

              Colors.white
                  .withOpacity(.15),

            ),

          ),




          focusedBorder:

          OutlineInputBorder(

            borderRadius:

            BorderRadius.circular(
                18
            ),



            borderSide:

            const BorderSide(

              color:
              Color(0xFFD4AF37),

              width:2,

            ),


          ),



        ),


      ),


    );


  }






  Widget cepField(){


    return Padding(

      padding:
      const EdgeInsets.only(
          bottom:15
      ),



      child:

      TextFormField(


        controller:
        cepController,


        keyboardType:
        TextInputType.number,


        style:
        const TextStyle(
          color:Colors.white,
        ),



        onChanged:
        buscarCep,



        decoration:

        InputDecoration(


          labelText:
          "CEP",



          labelStyle:

          const TextStyle(
            color:Colors.white70,
          ),



          filled:true,


          fillColor:

          Colors.white
              .withOpacity(.08),




          enabledBorder:

          OutlineInputBorder(

            borderRadius:

            BorderRadius.circular(
                18
            ),


            borderSide:

            BorderSide(

              color:

              Colors.white
                  .withOpacity(.15),

            ),


          ),




          focusedBorder:

          OutlineInputBorder(

            borderRadius:

            BorderRadius.circular(
                18
            ),



            borderSide:

            const BorderSide(

              color:
              Color(0xFFD4AF37),

              width:2,

            ),


          ),



        ),


      ),


    );


  }






  // ===============================
  // CARD GLASS
  // ===============================


  Widget card(
      List<Widget> children
      ){


    return SingleChildScrollView(


      padding:
      const EdgeInsets.all(20),



      child:

      Container(


        padding:
        const EdgeInsets.all(25),



        decoration:

        BoxDecoration(



          color:

          Colors.white
              .withOpacity(.06),




          borderRadius:

          BorderRadius.circular(
              35
          ),





          border:

          Border.all(

            color:

            const Color(
                0xFFD4AF37
            )
                .withOpacity(.25),


          ),



          boxShadow:[


            BoxShadow(

              color:

              Colors.black
                  .withOpacity(.5),


              blurRadius:
              35,


              offset:

              const Offset(
                  0,
                  15
              ),


            ),


          ],



        ),




        child:

        Column(

          children:
          children,

        ),



      ),



    );


  }






  // ===============================
  // PESSOA FÍSICA
  // ===============================


  Widget fisica(){


    return card([


      field(
          "Nome",
          nomeController,
          required:true
      ),


      field(
          "Sobrenome",
          sobrenomeController,
          required:true
      ),



      field(
          "CPF",
          cpfCnpjController,
          required:true
      ),



      field(
          "Telefone",
          telefoneController,
          required:true
      ),



      field(
          "Email",
          emailController,
          required:true
      ),



      field(
          "Senha",
          senhaController,
          required:true
      ),



      cepField(),



      field(
          "Endereço",
          enderecoController
      ),


      field(
          "Número",
          numeroController
      ),



      field(
          "Bairro",
          bairroController
      ),



      field(
          "Cidade",
          cidadeController
      ),



      field(
          "Estado",
          estadoController
      ),



    ]);

  }







  // ===============================
  // PESSOA JURÍDICA
  // ===============================


  Widget juridica(){


    return card([



      field(
          "Razão Social",
          razaoSocialController,
          required:true
      ),



      field(
          "Nome Fantasia",
          nomeFantasiaController
      ),



      field(
          "CNPJ",
          cpfCnpjController,
          required:true
      ),



      field(
          "Telefone",
          telefoneController
      ),



      field(
          "Email",
          emailController,
          required:true
      ),



      field(
          "Senha",
          senhaController,
          required:true
      ),



      cepField(),



      field(
          "Endereço",
          enderecoController
      ),



      field(
          "Número",
          numeroController
      ),



      field(
          "Bairro",
          bairroController
      ),



      field(
          "Cidade",
          cidadeController
      ),



      field(
          "Estado",
          estadoController
      ),



    ]);

  }






  // ===============================
  // RURAL / HARAS
  // ===============================


  Widget rural(){


    return card([



      field(
          "Nome",
          nomeController,
          required:true
      ),



      field(
          "Sobrenome",
          sobrenomeController,
          required:true
      ),



      field(
          "CPF",
          cpfCnpjController,
          required:true
      ),



      field(
          "Telefone",
          telefoneController
      ),



      field(
          "Email",
          emailController,
          required:true
      ),



      field(
          "Senha",
          senhaController,
          required:true
      ),



      cepField(),



      field(
          "Endereço",
          enderecoController
      ),



      field(
          "Número",
          numeroController
      ),



      field(
          "Bairro",
          bairroController
      ),



      field(
          "Cidade",
          cidadeController
      ),



      field(
          "Estado",
          estadoController
      ),



      const SizedBox(
          height:10
      ),



      field(
          "Nome do Haras",
          nomeHarasController,
          required:true
      ),



      field(
          "ID Rural",
          idRuralController,
          required:true
      ),



    ]);


  }
    // ===============================
  // BUILD
  // ===============================


  @override
  Widget build(BuildContext context) {


    return Scaffold(



      backgroundColor:
      const Color(0xFF050505),





      appBar:

      AppBar(


        backgroundColor:
        Colors.black,


        foregroundColor:
        const Color(0xFFD4AF37),



        elevation:
        0,



        title:

        const Text(

          "Criar Conta",

          style:

          TextStyle(

            fontFamily:
            "Cinzel",


            color:
            Color(0xFFD4AF37),


            fontSize:
            22,


            fontWeight:
            FontWeight.bold,


          ),


        ),




        centerTitle:
        true,





        bottom:


        PreferredSize(


          preferredSize:

          const Size.fromHeight(
              55
          ),



          child:


          TabBar(


            controller:
            _tabController,



            indicatorColor:
            const Color(0xFFD4AF37),



            indicatorWeight:
            3,



            labelColor:
            const Color(0xFFD4AF37),



            unselectedLabelColor:
            Colors.white54,




            tabs:


            const [


              Tab(

                text:
                "Física",

              ),




              Tab(

                text:
                "Jurídica",

              ),




              Tab(

                text:
                "Rural",

              ),



            ],



          ),


        ),



      ),







      body:

      Container(


        decoration:

        const BoxDecoration(


          gradient:


          LinearGradient(


            begin:
            Alignment.topCenter,


            end:
            Alignment.bottomCenter,



            colors:


            [


              Color(0xFF000000),


              Color(0xFF15100A),


              Color(0xFF050505),


            ],



          ),


        ),




        child:


        Form(


          key:
          _formKey,



          child:


          TabBarView(


            controller:
            _tabController,



            children:


            [


              fisica(),


              juridica(),


              rural(),



            ],


          ),



        ),



      ),








      floatingActionButton:



      Container(


        decoration:

        BoxDecoration(


          borderRadius:

          BorderRadius.circular(
              50
          ),



          boxShadow:


          [


            BoxShadow(


              color:

              const Color(
                  0xFFD4AF37
              )
                  .withOpacity(.35),



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


        FloatingActionButton.extended(


          backgroundColor:

          const Color(
              0xFFD4AF37
          ),



          foregroundColor:

          Colors.black,



          elevation:

          0,



          onPressed:


          loading
              ?

              null

              :

              register,





          icon:


          loading


              ?


          const SizedBox(


            height:
            20,


            width:
            20,



            child:


            CircularProgressIndicator(


              color:
              Colors.black,


              strokeWidth:
              2,


            ),


          )



              :


          const Icon(

            Icons.check_circle_outline,

          ),






          label:


          const Text(


            "CRIAR CONTA",



            style:


            TextStyle(


              fontWeight:
              FontWeight.bold,



              letterSpacing:
              1.5,



            ),



          ),



        ),


      ),



    );


  }



}