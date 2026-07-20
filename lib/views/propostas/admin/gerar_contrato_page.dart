// ignore_for_file: deprecated_member_use

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

  Map<String, dynamic>? proposta;

  @override
  void initState() {
    super.initState();
    carregarProposta();
  }


  // =====================================================
  // BUSCAR PROPOSTA
  // =====================================================

  Future<void> carregarProposta() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection("propostas")
          .doc(widget.propostaId)
          .get();

      if (!doc.exists) {
        setState(() {
          carregando = false;
        });
        return;
      }


      if (!mounted) return;

      setState(() {
        proposta = doc.data();
        carregando = false;
      });


    } catch (e) {

      if (!mounted) return;

      setState(() {
        carregando = false;
      });


      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            "Erro ao carregar proposta: $e",
          ),
        ),
      );
    }
  }



  // =====================================================
  // FORMATADORES
  // =====================================================

  String texto(dynamic valor) {

    if (valor == null ||
        valor.toString().isEmpty) {
      return "-";
    }

    return valor.toString();
  }



  String moeda(dynamic valor) {

    double numero = 0;

    if (valor is num) {
      numero = valor.toDouble();
    }

    else {
      numero =
          double.tryParse(
            valor.toString()
                .replaceAll(",", "."),
          ) ??
          0;
    }


    return numero
        .toStringAsFixed(2)
        .replaceAll(".", ",");
  }




  // =====================================================
  // GERAR PDF
  // =====================================================

  Future<void> gerarContrato() async {

    if (proposta == null) return;


    setState(() {
      gerandoPdf = true;
    });



    final pdf = pw.Document();


    final cliente =
        texto(proposta!["clienteNome"]);


    final valor =
        moeda(proposta!["valorTotal"]);



    final parcelas =
        texto(
          proposta!["parcelas"] ?? 1,
        );



    final contratoTexto = """

Pelo presente instrumento particular, as partes abaixo identificadas firmam o presente contrato digital.

CONTRATANTE:
$cliente


OBJETO DO CONTRATO:

Este documento tem como finalidade formalizar a proposta comercial aprovada pelo cliente dentro do sistema.


VALOR TOTAL CONTRATADO:

R\$ $valor


FORMA DE PAGAMENTO:

Quantidade de parcelas: $parcelas


DECLARAÇÕES:

O cliente declara que todas as informações fornecidas são verdadeiras.

A aprovação eletrônica deste contrato representa concordância com os termos apresentados.


ASSINATURA DIGITAL:

Este contrato foi gerado eletronicamente pelo sistema e poderá receber assinatura digital das partes.



""";



    pdf.addPage(

      pw.MultiPage(

        pageFormat:
            PdfPageFormat.a4,


        margin:
            const pw.EdgeInsets.all(40),


        build: (context) {


          return [

            pw.Center(

              child: pw.Text(

                "CONTRATO DIGITAL",

                style:
                    pw.TextStyle(

                  fontSize: 24,

                  fontWeight:
                      pw.FontWeight.bold,

                ),
              ),
            ),


            pw.SizedBox(
              height: 30,
            ),



            pw.Text(

              "CLIENTE: $cliente",

              style:
                  pw.TextStyle(

                fontSize: 14,

                fontWeight:
                    pw.FontWeight.bold,

              ),
            ),



            pw.SizedBox(
              height: 20,
            ),



            pw.Text(

              contratoTexto,

              style:
                  const pw.TextStyle(

                fontSize: 12,

              ),
            ),



            pw.SizedBox(
              height: 60,
            ),



            pw.Divider(),



            pw.SizedBox(
              height: 40,
            ),



            pw.Text(
              "Assinatura do Cliente:",
            ),



            pw.SizedBox(
              height: 60,
            ),



            pw.Container(

              width: 250,

              height: 1,

              color:
                  PdfColors.black,

            ),



            pw.SizedBox(
              height: 10,
            ),



            pw.Text(cliente),


          ];
        },

      ),

    );



    await Printing.layoutPdf(

      onLayout:
          (format) async {

        return pdf.save();

      },

    );



    if (!mounted) return;


    setState(() {
      gerandoPdf = false;
    });

  }

    // =====================================================
  // LIBERAR CONTRATO PARA ASSINATURA
  // =====================================================

  Future<void> liberarContrato() async {

    try {

      await FirebaseFirestore.instance
          .collection("propostas")
          .doc(widget.propostaId)
          .update({

        "status":
            "aguardando_assinatura",

        "contratoLiberado":
            true,

        "dataContrato":
            Timestamp.now(),

      });



      if (!mounted) return;


      ScaffoldMessenger.of(context)
          .showSnackBar(

        const SnackBar(

          content: Text(
            "Contrato liberado para assinatura.",
          ),

        ),

      );



      Navigator.pop(context);



    } catch (e) {


      if (!mounted) return;


      ScaffoldMessenger.of(context)
          .showSnackBar(

        SnackBar(

          content:
              Text(
                "Erro ao liberar contrato: $e",
              ),

        ),

      );

    }

  }




  // =====================================================
  // CARD DE INFORMAÇÃO
  // =====================================================

  Widget infoCard(
    String titulo,
    String valor,
  ) {


    return Container(

      margin:
          const EdgeInsets.only(
            bottom: 12,
          ),


      padding:
          const EdgeInsets.all(18),


      decoration:
          BoxDecoration(

        color:
            Colors.white,


        borderRadius:
            BorderRadius.circular(18),


        boxShadow: [

          BoxShadow(

            color:
                Colors.black
                    .withOpacity(0.05),


            blurRadius: 10,


            offset:
                const Offset(0, 4),

          ),

        ],

      ),



      child: Row(

        children: [


          Expanded(

            child: Text(

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



          : ListView(

              padding:
                  const EdgeInsets.all(16),


              children: [



                // HEADER

                Container(

                  padding:
                      const EdgeInsets.all(22),


                  decoration:
                      BoxDecoration(

                    gradient:
                        const LinearGradient(

                      colors: [

                        Color(0xff1565C0),

                        Color(0xff42A5F5),

                      ],

                    ),


                    borderRadius:
                        BorderRadius.circular(22),

                  ),



                  child:
                      const Column(

                    crossAxisAlignment:
                        CrossAxisAlignment.start,


                    children: [


                      Text(

                        "Contrato Digital",

                        style:
                            TextStyle(

                          color:
                              Colors.white,


                          fontSize:
                              23,


                          fontWeight:
                              FontWeight.bold,

                        ),

                      ),



                      SizedBox(
                        height: 8,
                      ),



                      Text(

                        "Revise os dados antes de liberar para assinatura.",


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
                  height: 22,
                ),





                infoCard(

                  "Cliente",

                  texto(
                    proposta!["clienteNome"],
                  ),

                ),




                infoCard(

                  "Status",

                  texto(
                    proposta!["status"],
                  ),

                ),




                infoCard(

                  "Valor Total",

                  "R\$ ${moeda(
                    proposta!["valorTotal"],
                  )}",

                ),




                infoCard(

                  "Parcelas",

                  texto(
                    proposta!["parcelas"] ?? 1,
                  ),

                ),




                const SizedBox(
                  height: 20,
                ),




                SizedBox(

                  height: 55,


                  child:
                      ElevatedButton.icon(

                    icon:

                        gerandoPdf

                            ?

                        const SizedBox(

                          height:20,

                          width:20,

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

                          "GERANDO PDF..."

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

                        ElevatedButton
                            .styleFrom(

                      backgroundColor:
                          Colors.blue,


                      shape:
                          RoundedRectangleBorder(

                        borderRadius:
                            BorderRadius.circular(14),

                      ),

                    ),



                    onPressed:

                        gerandoPdf

                            ?

                        null

                            :

                        gerarContrato,

                  ),

                ),




                const SizedBox(
                  height: 15,
                ),

                                SizedBox(

                  height: 55,


                  child:
                      ElevatedButton.icon(

                    icon:
                        const Icon(

                      Icons.check_circle,

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
                  height: 20,
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

                    children: [


                      Icon(

                        Icons.info_outline,

                        color:
                            Colors.orange,

                      ),



                      SizedBox(
                        width: 10,
                      ),



                      Expanded(

                        child: Text(

                          "Após liberar, o cliente poderá acessar o contrato para realizar a assinatura digital.",


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

      