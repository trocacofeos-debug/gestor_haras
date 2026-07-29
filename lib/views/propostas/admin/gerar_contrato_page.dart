// ignore_for_file: deprecated_member_use

import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';



class GerarContratoPage extends StatefulWidget {


  final String propostaId;



  const GerarContratoPage({

    super.key,

    required this.propostaId,

  });



  @override
  State<GerarContratoPage> createState() =>
      _GerarContratoPageState();


}




class _GerarContratoPageState
    extends State<GerarContratoPage> {



  bool carregando = true;

  bool gerandoPdf = false;



  Map<String,dynamic>? proposta;



  Uint8List? pdfBytes;





  @override
  void initState(){

    super.initState();

    carregarProposta();

  }







  // =====================================================
  // CARREGAR PROPOSTA FIRESTORE
  // =====================================================


  Future<void> carregarProposta() async {


    try{


      final doc = await FirebaseFirestore
          .instance
          .collection("propostas")
          .doc(widget.propostaId)
          .get();




      if(!mounted) return;




      if(!doc.exists){


        setState((){

          carregando = false;

        });


        return;

      }




      setState((){


        proposta = doc.data();

        carregando = false;


      });



    }catch(e){



      if(!mounted) return;




      setState((){

        carregando = false;

      });





      ScaffoldMessenger.of(context)
          .showSnackBar(


        SnackBar(

          backgroundColor:
          Colors.red,


          content:

          Text(

            "Erro ao carregar proposta: $e",

          ),


        ),


      );



    }


  }









  // =====================================================
  // FORMATAR TEXTO
  // =====================================================


  String texto(dynamic valor){


    if(valor == null ||
        valor.toString().trim().isEmpty){


      return "-";


    }



    return valor.toString();


  }









  // =====================================================
  // FORMATAR VALOR
  // =====================================================


  String moeda(dynamic valor){


    double numero = 0;



    if(valor is num){


      numero = valor.toDouble();


    }else{



      numero = double.tryParse(

        valor
            .toString()
            .replaceAll(",", "."),

      ) ?? 0;



    }




    return numero

        .toStringAsFixed(2)

        .replaceAll(".", ",");



  }









  // =====================================================
  // PEGAR VALOR DA PROPOSTA
  // =====================================================


  dynamic get valorProposta {


    return proposta?["valor"] ?? 0;


  }






  int get quantidadeParcelas {


    return proposta?["parcelas"] ?? 1;


  }









  // =====================================================
  // CRIAR PDF
  // =====================================================


  Future<Uint8List> criarPdf() async {



    final pdf = pw.Document();




    final cliente =

    texto(

      proposta?["clienteNome"],

    );





    final valor =

    moeda(

      valorProposta,

    );





    final parcelas =

    quantidadeParcelas.toString();






    pdf.addPage(



      pw.MultiPage(



        pageFormat:

        PdfPageFormat.a4,



        margin:

        const pw.EdgeInsets.all(40),




        build:(context){



          return [



            pw.Center(



              child:

              pw.Text(



                "CONTRATO DIGITAL",



                style:

                pw.TextStyle(



                  fontSize:

                  24,



                  fontWeight:

                  pw.FontWeight.bold,



                ),



              ),



            ),







            pw.SizedBox(

              height:

              30,

            ),








            pw.Text(



              "CLIENTE: $cliente",



              style:

              pw.TextStyle(



                fontSize:

                16,



                fontWeight:

                pw.FontWeight.bold,



              ),



            ),








            pw.SizedBox(

              height:

              20,

            ),








            pw.Text(



"""

Pelo presente instrumento particular,

as partes abaixo identificadas firmam

o presente contrato digital.



CLIENTE:

$cliente



VALOR TOTAL CONTRATADO:

R\$ $valor



FORMA DE PAGAMENTO:

$parcelas parcelas



O cliente declara que todas as informações

fornecidas são verdadeiras.



Este contrato foi gerado eletronicamente

pelo sistema Gestor Haras.



""",



              style:

              const pw.TextStyle(



                fontSize:

                12,



              ),



            ),







            pw.SizedBox(

              height:

              60,

            ),







            pw.Divider(),








            pw.SizedBox(

              height:

              40,

            ),







            pw.Text(

              "Assinatura do Cliente:",

            ),







            pw.SizedBox(

              height:

              60,

            ),






            pw.Container(



              width:

              250,



              height:

              1,



              color:

              PdfColors.black,



            ),








            pw.SizedBox(

              height:

              10,

            ),







            pw.Text(cliente),





          ];



        },



      ),



    );





    return await pdf.save();



  }

  




  // =====================================================
  // GERAR E VISUALIZAR PDF
  // =====================================================


  Future<void> gerarContrato() async {


    try{


      if(proposta == null){

        return;

      }




      setState((){

        gerandoPdf = true;

      });






      pdfBytes ??= await criarPdf();





      await Printing.layoutPdf(


        onLayout:(format) async {


          return pdfBytes!;


        },


      );






      if(!mounted) return;



      setState((){


        gerandoPdf = false;


      });




    }catch(e){



      if(!mounted) return;



      setState((){


        gerandoPdf = false;


      });






      ScaffoldMessenger.of(context)
          .showSnackBar(



        SnackBar(

          backgroundColor:
          Colors.red,


          content:

          Text(

            "Erro ao gerar contrato: $e",

          ),


        ),



      );



    }


  }









  // =====================================================
  // LIBERAR CONTRATO
  // =====================================================


  Future<void> liberarContrato() async {


    try{



      if(proposta == null){

        return;

      }





      setState((){


        gerandoPdf = true;


      });






      // cria PDF caso ainda não exista

      pdfBytes ??= await criarPdf();






      /*
      
      FUTURO UPLOAD CLOUDFLARE R2

      Aqui será colocado:

      final contratoUrl =
          await R2Service.uploadContratoPdf(
              pdfBytes!,
              widget.propostaId,
          );


      Por enquanto mantém null
      porque não existe upload ainda.

      */



      String? contratoUrl;






      await FirebaseFirestore.instance

          .collection("propostas")

          .doc(widget.propostaId)

          .update({





        "status":

        "aguardando_assinatura",





        "contratoLiberado":

        true,





        "contratoGerado":

        true,





        "contratoPdfUrl":

        contratoUrl,





        "dataContrato":

        Timestamp.now(),





      });








      if(!mounted) return;






      setState((){


        gerandoPdf = false;


      });








      ScaffoldMessenger.of(context)

          .showSnackBar(




        const SnackBar(



          backgroundColor:

          Colors.green,



          content:

          Text(



            "Contrato liberado para assinatura.",



          ),



        ),





      );







      Navigator.pop(context);






    }catch(e){



      if(!mounted) return;





      setState((){


        gerandoPdf = false;


      });






      ScaffoldMessenger.of(context)

          .showSnackBar(



        SnackBar(



          backgroundColor:

          Colors.red,



          content:

          Text(



            "Erro ao liberar contrato: $e",



          ),



        ),



      );




    }


  }












  // =====================================================
  // CARD INFORMAÇÃO
  // =====================================================


  Widget infoCard(

      String titulo,

      String valor,

      ){



    return Container(



      margin:

      const EdgeInsets.only(

        bottom:

        12,

      ),





      padding:

      const EdgeInsets.all(18),






      decoration:

      BoxDecoration(



        color:

        Colors.white,





        borderRadius:

        BorderRadius.circular(18),





        boxShadow:[



          BoxShadow(



            color:

            Colors.black12,



            blurRadius:

            8,



          ),



        ],



      ),






      child:

      Row(



        children:[




          Expanded(



            child:

            Text(



              titulo,



              style:

              const TextStyle(



                fontWeight:

                FontWeight.w600,



                fontSize:

                15,



              ),



            ),



          ),







          Text(



            valor,



            style:

            const TextStyle(



              fontWeight:

              FontWeight.bold,



            ),



          ),





        ],



      ),



    );



  }

  




  // =====================================================
  // BUILD
  // =====================================================


  @override
  Widget build(BuildContext context) {


    return Scaffold(



      backgroundColor:

      const Color(0xffF4F6FA),





      appBar:

      AppBar(



        title:

        const Text(

          "Gerar Contrato",

        ),



        centerTitle:

        true,



      ),






      body:



      carregando



          ?



      const Center(



        child:

        CircularProgressIndicator(),



      )





          : proposta == null





          ?





      const Center(



        child:

        Text(

          "Proposta não encontrada",

        ),



      )







          :





      ListView(



        padding:

        const EdgeInsets.all(16),





        children:[







          Container(



            padding:

            const EdgeInsets.all(22),





            decoration:

            BoxDecoration(



              gradient:

              const LinearGradient(



                colors:[



                  Color(0xff5D4037),



                  Color(0xff8D6E63),



                ],



              ),





              borderRadius:

              BorderRadius.circular(24),



            ),







            child:

            const Column(



              crossAxisAlignment:

              CrossAxisAlignment.start,



              children:[





                Text(



                  "Contrato Digital",



                  style:

                  TextStyle(



                    color:

                    Colors.white,



                    fontSize:

                    24,



                    fontWeight:

                    FontWeight.bold,



                  ),



                ),





                SizedBox(

                  height:8,

                ),






                Text(



                  "Gere o contrato e libere para assinatura do cliente.",



                  style:

                  TextStyle(



                    color:

                    Colors.white70,



                  ),



                ),





              ],



            ),



          ),







          const SizedBox(

            height:22,

          ),







          infoCard(



            "Cliente",



            texto(

              proposta!["clienteNome"],

            ),



          ),








          infoCard(



            "Valor",



            "R\$ ${moeda(

              proposta!["valor"],

            )}",



          ),







          infoCard(



            "Parcelas",



            texto(

              proposta!["parcelas"] ?? 1,

            ),



          ),







          infoCard(



            "Status",



            texto(

              proposta!["status"],

            ),



          ),








          const SizedBox(

            height:20,

          ),







          SizedBox(



            height:

            55,





            width:

            double.infinity,







            child:

            ElevatedButton.icon(



              icon:

              gerandoPdf



                  ?



              const SizedBox(



                height:

                20,



                width:

                20,



                child:

                CircularProgressIndicator(



                  color:

                  Colors.white,



                  strokeWidth:

                  2,



                ),



              )





                  :



              const Icon(



                Icons.picture_as_pdf,



                color:

                Colors.white,



              ),







              label:

              Text(



                gerandoPdf



                    ?



                "GERANDO..."





                    :



                "VISUALIZAR CONTRATO",



                style:

                const TextStyle(



                  color:

                  Colors.white,



                  fontWeight:

                  FontWeight.bold,



                ),



              ),







              style:

              ElevatedButton.styleFrom(



                backgroundColor:

                Colors.indigo,





                shape:

                RoundedRectangleBorder(



                  borderRadius:

                  BorderRadius.circular(14),



                ),



              ),







              onPressed:



              gerandoPdf

                  ? null

                  :

              gerarContrato,





            ),



          ),







          const SizedBox(

            height:15,

          ),







          SizedBox(



            height:

            55,





            width:

            double.infinity,







            child:

            ElevatedButton.icon(



              icon:

              const Icon(



                Icons.lock_open,



                color:

                Colors.white,



              ),





              label:

              const Text(



                "LIBERAR PARA ASSINATURA",



                style:

                TextStyle(



                  color:

                  Colors.white,



                  fontWeight:

                  FontWeight.bold,



                ),



              ),





              style:

              ElevatedButton.styleFrom(



                backgroundColor:

                Colors.green,





                shape:

                RoundedRectangleBorder(



                  borderRadius:

                  BorderRadius.circular(14),



                ),



              ),






              onPressed:

              liberarContrato,





            ),



          ),







          const SizedBox(

            height:20,

          ),







          Container(



            padding:

            const EdgeInsets.all(16),





            decoration:

            BoxDecoration(



              color:

              Colors.orange.shade50,





              borderRadius:

              BorderRadius.circular(16),



            ),







            child:

            const Row(



              children:[





                Icon(



                  Icons.info_outline,



                  color:

                  Colors.orange,



                ),





                SizedBox(

                  width:10,

                ),






                Expanded(



                  child:

                  Text(



                    "O cliente receberá o contrato após a liberação para assinatura digital.",



                    style:

                    TextStyle(



                      fontSize:

                      13,



                    ),



                  ),



                ),





              ],



            ),



          ),





        ],



      ),



    );

  }



}