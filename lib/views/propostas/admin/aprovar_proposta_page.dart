import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../models/proposta_model.dart';
import '../../../services/proposta_service.dart';


class AprovarPropostaPage extends StatefulWidget {

  final String propostaId;

  const AprovarPropostaPage({
    super.key,
    required this.propostaId,
  });


  @override
  State<AprovarPropostaPage> createState() =>
      _AprovarPropostaPageState();

}





class _AprovarPropostaPageState
    extends State<AprovarPropostaPage> {


  final service = PropostaService();


  PropostaModel? proposta;


  bool carregando = true;



  @override
  void initState() {

    super.initState();

    carregar();

  }






  Future<void> carregar() async {


    try {


      final doc =
          await FirebaseFirestore.instance
              .collection("propostas")
              .doc(widget.propostaId)
              .get();



      if(!doc.exists){

        setState(() {
          carregando=false;
        });

        return;

      }



      proposta =
          PropostaModel.fromMap(
            doc.id,
            doc.data()!,
          );



      setState(() {

        carregando=false;

      });



    }catch(e){


      setState(() {

        carregando=false;

      });


      mensagem(
        "Erro ao carregar: $e",
      );


    }


  }








  Future<void> abrirDocumento(String url) async {


    try{


      final uri =
          Uri.parse(url);



      await launchUrl(

        uri,

        mode:
            LaunchMode.externalApplication,

      );


    }catch(e){

      mensagem(
        "Erro ao abrir documento: $e",
      );

    }


  }







  Future<void> aprovar() async {


    if(proposta==null)return;



    setState(() {

      carregando=true;

    });



    try{


      await service.aprovar(
        proposta!.id,
      );


      mensagem(
        "Proposta aprovada",
      );


      // ignore: use_build_context_synchronously
      Navigator.pop(context);



    }catch(e){

      mensagem(
        "Erro: $e",
      );

    }



  }








  Future<void> reprovar() async {


    if(proposta==null)return;



    try{


      await service.reprovar(
        proposta!.id,
      );


      mensagem(
        "Proposta reprovada",
      );


      // ignore: use_build_context_synchronously
      Navigator.pop(context);



    }catch(e){

      mensagem(
        "Erro: $e",
      );

    }


  }








  Future<void> liberarContrato() async {


    if(proposta==null)return;



    try{


      await service.liberarContrato(
        proposta!.id,
      );


      mensagem(
        "Contrato liberado",
      );


      // ignore: use_build_context_synchronously
      Navigator.pop(context);



    }catch(e){

      mensagem(
        "Erro: $e",
      );

    }


  }








  void mensagem(String texto){


    if(!mounted)return;


    ScaffoldMessenger.of(context)
        .showSnackBar(

      SnackBar(
        content:
            Text(texto),
      ),

    );


  }









  Widget documento(

      String titulo,

      String? url,

      IconData icon,

      ){



    final existe =
        url != null &&
        url.isNotEmpty;



    return Container(

      margin:
          const EdgeInsets.only(
            bottom:12,
          ),


      padding:
          const EdgeInsets.all(16),



      decoration:
          BoxDecoration(

        color:
            Colors.white,


        borderRadius:
            BorderRadius.circular(18),


      ),




      child: Row(

        children:[



          CircleAvatar(

            backgroundColor:
                Colors.blue.shade50,


            child:
                Icon(
                  icon,
                  color:
                      Colors.blue,
                ),

          ),



          const SizedBox(
            width:12,
          ),




          Expanded(

            child:

            Column(

              crossAxisAlignment:
                  CrossAxisAlignment.start,


              children:[


                Text(

                  titulo,

                  style:
                  const TextStyle(

                    fontWeight:
                    FontWeight.bold,

                  ),

                ),



                Text(

                  existe
                  ? "Documento disponível"
                  : "Não enviado",

                  style:

                  TextStyle(

                    color:
                    existe
                    ? Colors.green
                    : Colors.red,

                  ),

                ),


              ],


            ),

          ),





          if(existe)

            IconButton(

              tooltip:
                  "Visualizar documento",

              icon:
              const Icon(

                Icons.visibility,

                color:
                Colors.blue,

              ),


              onPressed:(){

                abrirDocumento(url);

              },

            ),





          Icon(

            existe

            ? Icons.check_circle

            : Icons.cancel,


            color:

            existe

            ? Colors.green

            : Colors.red,


          ),



        ],

      ),


    );


  }










  @override
  Widget build(BuildContext context) {


    if(carregando || proposta==null){


      return const Scaffold(

        body:
        Center(
          child:
          CircularProgressIndicator(),
        ),

      );


    }



    final p =
        proposta!;




    return Scaffold(

      backgroundColor:
          const Color(0xffF4F6FA),



      appBar:
          AppBar(

        title:
        const Text(
          "Analisar Proposta",
        ),

        centerTitle:true,

      ),






      body:

      SingleChildScrollView(

        padding:
            const EdgeInsets.all(20),



        child:

        Column(

          crossAxisAlignment:
          CrossAxisAlignment.start,


          children:[





            Card(

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
                  p.clienteNome,
                  style:
                  const TextStyle(
                    fontWeight:
                    FontWeight.bold,
                  ),
                ),

                subtitle:
                Text(
                  "Status: ${p.status}",
                ),

              ),

            ),






            const SizedBox(
              height:20,
            ),





            const Text(

              "Documentos enviados",

              style:
              TextStyle(

                fontSize:
                18,

                fontWeight:
                FontWeight.bold,

              ),

            ),





            const SizedBox(
              height:15,
            ),




            documento(

              "RG ou CNH",

              p.rgUrl,

              Icons.badge,

            ),




            documento(

              "Comprovante residência",

              p.comprovanteUrl,

              Icons.home,

            ),




            documento(

              "Selfie com documento",

              p.selfieDocumentoUrl,

              Icons.camera_alt,

            ),






            const SizedBox(
              height:30,
            ),






            SizedBox(

              width:
              double.infinity,

              height:
              55,


              child:

              ElevatedButton.icon(

                icon:
                const Icon(
                  Icons.check,
                  color:
                  Colors.white,
                ),


                label:
                const Text(
                  "APROVAR PROPOSTA",
                  style:
                  TextStyle(
                    color:
                    Colors.white,
                  ),
                ),


                style:
                ElevatedButton.styleFrom(

                  backgroundColor:
                  Colors.green,

                ),


                onPressed:
                aprovar,

              ),

            ),





            const SizedBox(
              height:12,
            ),





            SizedBox(

              width:
              double.infinity,

              height:
              55,


              child:

              ElevatedButton.icon(

                icon:
                const Icon(
                  Icons.description,
                  color:
                  Colors.white,
                ),


                label:
                const Text(
                  "LIBERAR CONTRATO",
                  style:
                  TextStyle(
                    color:
                    Colors.white,
                  ),
                ),


                style:
                ElevatedButton.styleFrom(

                  backgroundColor:
                  Colors.indigo,

                ),


                onPressed:
                liberarContrato,

              ),

            ),





            const SizedBox(
              height:12,
            ),




            SizedBox(

              width:
              double.infinity,

              height:
              55,


              child:

              ElevatedButton.icon(

                icon:
                const Icon(
                  Icons.close,
                  color:
                  Colors.white,
                ),


                label:
                const Text(
                  "REPROVAR",
                  style:
                  TextStyle(
                    color:
                    Colors.white,
                  ),
                ),


                style:
                ElevatedButton.styleFrom(

                  backgroundColor:
                  Colors.red,

                ),


                onPressed:
                reprovar,


              ),

            ),




          ],


        ),

      ),


    );


  }


}