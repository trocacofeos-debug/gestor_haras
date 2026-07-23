import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class PerfilClientePage extends StatefulWidget {

  const PerfilClientePage({
    super.key,
  });

  @override
  State<PerfilClientePage> createState() =>
      _PerfilClientePageState();

}



class _PerfilClientePageState
    extends State<PerfilClientePage> {


  final FirebaseAuth auth =
      FirebaseAuth.instance;


  final FirebaseFirestore firestore =
      FirebaseFirestore.instance;



  final Color primaria =
      const Color(0xFF1565C0);



  String get uid =>
      auth.currentUser?.uid ?? '';






  Future<DocumentSnapshot<Map<String,dynamic>>>
  carregarCliente() async {

    return await firestore
        .collection('clientes')
        .doc(uid)
        .get();

  }







  Future<void> logout() async {

    await auth.signOut();


    if(!mounted) return;


    Navigator.popUntil(
      context,
      (route) => route.isFirst,
    );

  }







  String inicial(String nome){

    if(nome.trim().isEmpty){
      return "?";
    }


    return nome
        .trim()
        .substring(0,1)
        .toUpperCase();

  }







  Widget infoCard(
      IconData icon,
      String titulo,
      String valor,
      ){


    return Card(

      elevation:2,

      margin:
      const EdgeInsets.only(
        bottom:12,
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
          // ignore: deprecated_member_use
          primaria.withOpacity(0.12),


          child:

          Icon(

            icon,

            color:
            primaria,

          ),

        ),


        title:

        Text(

          titulo,

          style:
          const TextStyle(

            fontWeight:
            FontWeight.bold,

          ),

        ),



        subtitle:

        Text(

          valor.isEmpty
              ? "-"
              : valor,

        ),

      ),

    );

  }







  @override
  Widget build(BuildContext context) {


    return Scaffold(

      backgroundColor:
      const Color(0xFFF4F7FB),



      appBar:

      AppBar(

        backgroundColor:
        primaria,


        foregroundColor:
        Colors.white,


        elevation:0,


        centerTitle:true,


        title:

        const Text(
          "Meu Perfil",
          style:
          TextStyle(
            fontWeight:
            FontWeight.bold,
          ),
        ),


        actions:[

          IconButton(

            onPressed:
            logout,

            icon:
            const Icon(
              Icons.logout,
            ),

          ),

        ],

      ),





      body:

      FutureBuilder<DocumentSnapshot<Map<String,dynamic>>>(


        future:
        carregarCliente(),



        builder:
        (context,snapshot){



          if(snapshot.connectionState ==
              ConnectionState.waiting){

            return Center(

              child:
              CircularProgressIndicator(
                color:
                primaria,
              ),

            );

          }





          if(!snapshot.hasData ||
              !snapshot.data!.exists){

            return const Center(

              child:

              Text(
                "Dados do cliente não encontrados",
              ),

            );

          }





          final data =
              snapshot.data!.data()!;



          final nome =
              data['nome']?.toString() ?? '';



          final sobrenome =
              data['sobrenome']?.toString() ?? '';



          final nomeCompleto =
          "$nome $sobrenome".trim();



          final tipo =
              data['tipoCliente']?.toString() ?? '';



          final telefone =
              data['telefone']?.toString() ?? '';



          final email =
              data['email']?.toString() ?? '';



          final cpfCnpj =
              data['cpfCnpj']?.toString() ?? '';



          final cep =
              data['cep']?.toString() ?? '';



          final endereco =
              data['endereco']?.toString() ?? '';



          final numero =
              data['numero']?.toString() ?? '';



          final bairro =
              data['bairro']?.toString() ?? '';



          final cidade =
              data['cidade']?.toString() ?? '';



          final estado =
              data['estado']?.toString() ?? '';



          final nomeHaras =
              data['nomeHaras']?.toString() ?? '';







          return SingleChildScrollView(

            padding:
            const EdgeInsets.all(16),


            child:

            Column(

              children:[



                CircleAvatar(

                  radius:50,

                  backgroundColor:
                  primaria,


                  child:

                  Text(

                    inicial(nomeCompleto),

                    style:

                    const TextStyle(

                      color:
                      Colors.white,

                      fontSize:
                      34,

                      fontWeight:
                      FontWeight.bold,

                    ),

                  ),

                ),




                const SizedBox(
                  height:15,
                ),





                Text(

                  nomeCompleto.isEmpty
                      ? "Cliente"
                      : nomeCompleto,


                  style:

                  const TextStyle(

                    fontSize:
                    23,

                    fontWeight:
                    FontWeight.bold,

                  ),

                ),





                const SizedBox(
                  height:25,
                ),




                infoCard(
                  Icons.person,
                  "Tipo Cliente",
                  tipo,
                ),



                infoCard(
                  Icons.badge,
                  "CPF / CNPJ",
                  cpfCnpj,
                ),



                infoCard(
                  Icons.email,
                  "E-mail",
                  email,
                ),



                infoCard(
                  Icons.phone,
                  "Telefone",
                  telefone,
                ),



                infoCard(
                  Icons.home,
                  "Endereço",
                  "$endereco, $numero",
                ),



                infoCard(
                  Icons.location_on,
                  "Bairro",
                  bairro,
                ),



                infoCard(
                  Icons.location_city,
                  "Cidade / Estado",
                  "$cidade - $estado",
                ),



                infoCard(
                  Icons.markunread_mailbox,
                  "CEP",
                  cep,
                ),





                if(nomeHaras.isNotEmpty)

                  Column(

                    children:[


                      const SizedBox(
                        height:20,
                      ),



                      Align(

                        alignment:
                        Alignment.centerLeft,


                        child:

                        Text(

                          "Dados do Haras",

                          style:

                          TextStyle(

                            color:
                            primaria,

                            fontSize:
                            18,

                            fontWeight:
                            FontWeight.bold,

                          ),

                        ),

                      ),



                      const SizedBox(
                        height:10,
                      ),



                      infoCard(
                        Icons.pets,
                        "Nome do Haras",
                        nomeHaras,
                      ),

                    ],

                  ),


              ],

            ),

          );

        },


      ),

    );

  }

}