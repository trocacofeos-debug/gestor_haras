// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/divida_model.dart';
import '../../models/cliente_model.dart';
import '../../services/divida_service.dart';



class NovaContaPage extends StatefulWidget {

  const NovaContaPage({
    super.key,
  });


  @override
  State<NovaContaPage> createState() =>
      _NovaContaPageState();

}





class _NovaContaPageState
    extends State<NovaContaPage> {


  final formKey =
      GlobalKey<FormState>();


  final DividaService service =
      DividaService();



  final descricao =
      TextEditingController();


  final categoria =
      TextEditingController();


  final valor =
      TextEditingController();


  final parcelas =
      TextEditingController(
        text: "1",
      );



  String? clienteId;

  String? clienteNome;



  DateTime vencimento =
      DateTime.now()
          .add(
            const Duration(
              days:30,
            ),
          );


  bool salvando = false;



  final Color primaria =
      const Color(0xff1565C0);





  @override
  void dispose(){


    descricao.dispose();

    categoria.dispose();

    valor.dispose();

    parcelas.dispose();


    super.dispose();

  }







  Future escolherData() async {


    final data =
    await showDatePicker(

      context: context,

      initialDate:
      vencimento,

      firstDate:
      DateTime(2020),

      lastDate:
      DateTime(2100),

    );



    if(data != null){

      setState((){

        vencimento = data;

      });

    }


  }







  double valorNumero(){


    return double.tryParse(

      valor.text

          .replaceAll(".", "")

          .replaceAll(",", "."),

    ) ?? 0;


  }









  Future salvar() async {



    if(!formKey.currentState!.validate()){

      return;

    }



    if(clienteId == null){


      ScaffoldMessenger.of(context)
          .showSnackBar(

        const SnackBar(

          content:
          Text(
            "Selecione um cliente",
          ),

        ),

      );


      return;

    }






    setState((){

      salvando = true;

    });





    try{


      final total =
      valorNumero();



      final qtd =
          int.tryParse(
            parcelas.text,
          ) ?? 1;




      final valorParcela =
          total / qtd;




      List<Map<String,dynamic>> lista = [];





      for(int i = 0; i < qtd; i++){



        lista.add({

          "valor":
          valorParcela,


          "vencimento":

          Timestamp.fromDate(

            DateTime(

              vencimento.year,

              vencimento.month + i,

              vencimento.day,

            ),

          ),



          "status":
          "pendente",



          "criadoEm":
          Timestamp.now(),

        });


      }







      final divida =
      DividaModel(

        id:"",


        clienteId:
        clienteId!,


        clienteNome:
        clienteNome ?? "",


        descricao:
        descricao.text.trim(),


        categoria:
        categoria.text.trim(),


        valorTotal:
        total,


        parcelas:
        qtd,


        status:
        "aberta",


        dataCriacao:
        Timestamp.now(),

      );







      await service.criarDivida(

        divida,

        lista,

      );





      if(mounted){

        Navigator.pop(context);

      }





    }catch(e){


      ScaffoldMessenger.of(context)
          .showSnackBar(

        SnackBar(

          content:
          Text(
            "Erro: $e",
          ),

        ),

      );


    }




    if(mounted){

      setState((){

        salvando=false;

      });

    }


  }








  Widget campo(

      String label,

      IconData icon,

      TextEditingController controller,

      ){


    return Padding(

      padding:
      const EdgeInsets.only(
        bottom:15,
      ),


      child:

      TextFormField(

        controller:
        controller,


        validator:(v){


          if(v == null ||
              v.trim().isEmpty){

            return "Obrigatório";

          }


          return null;

        },


        decoration:

        InputDecoration(

          prefixIcon:

          Icon(icon),


          labelText:
          label,


          filled:true,


          fillColor:
          Colors.white,


          border:

          OutlineInputBorder(

            borderRadius:
            BorderRadius.circular(18),


            borderSide:
            BorderSide.none,

          ),


        ),

      ),

    );


  }

    // =====================================================
  // PESQUISA DE CLIENTE
  // =====================================================

  Widget campoCliente(){


    return StreamBuilder<QuerySnapshot>(


      stream:

      FirebaseFirestore.instance

          .collection("clientes")

          .orderBy("nome")

          .snapshots(),



      builder:(context,snapshot){



        if(!snapshot.hasData){


          return const Center(

            child:
            CircularProgressIndicator(),

          );


        }




        final clientes = snapshot.data!.docs

            .map(

              (doc){

            return ClienteModel.fromMap(

              doc.data()
              as Map<String,dynamic>,

              doc.id,

            );

          },

        )

            .toList();







        return Autocomplete<ClienteModel>(




          displayStringForOption:

              (cliente) =>
          cliente.nomeExibicao,





          optionsBuilder:

              (TextEditingValue texto){



            if(texto.text.trim().isEmpty){

              return const Iterable<
                  ClienteModel>.empty();

            }



            final busca =
            texto.text.toLowerCase();





            return clientes.where((c){


              final nome =
              c.nomeExibicao
                  .toLowerCase();



              final telefone =
              c.telefone
                  .toLowerCase();



              return nome.contains(busca) ||
                  telefone.contains(busca);


            });


          },







          onSelected:

              (cliente){


            setState((){


              clienteId =
                  cliente.id;



              clienteNome =
                  cliente.nomeExibicao;


            });


          },








          fieldViewBuilder:

              (

              context,

              controller,

              focusNode,

              onEditingComplete,

              ){


            return TextFormField(



              controller:
              controller,



              focusNode:
              focusNode,



              decoration:

              InputDecoration(


                labelText:

                // ignore: prefer_if_null_operators
                clienteNome == null

                    ?

                "Pesquisar cliente"

                    :

                clienteNome,



                prefixIcon:

                const Icon(
                  Icons.search,
                ),



                suffixIcon:

                clienteId != null

                    ?

                IconButton(

                  icon:

                  const Icon(
                    Icons.close,
                  ),


                  onPressed:(){


                    setState((){


                      clienteId=null;

                      clienteNome=null;


                      controller.clear();


                    });


                  },


                )


                    :

                null,





                filled:true,


                fillColor:
                Colors.white,



                border:

                OutlineInputBorder(

                  borderRadius:
                  BorderRadius.circular(18),


                  borderSide:
                  BorderSide.none,

                ),

              ),

            );


          },






          optionsViewBuilder:

              (

              context,

              onSelected,

              options,

              ){



            return Align(


              alignment:
              Alignment.topLeft,



              child:

              Material(


                elevation:
                8,


                borderRadius:
                BorderRadius.circular(18),



                child:

                Container(


                  margin:
                  const EdgeInsets.only(
                    top:8,
                  ),



                  height:
                  260,



                  decoration:

                  BoxDecoration(

                    color:
                    Colors.white,


                    borderRadius:
                    BorderRadius.circular(18),

                  ),




                  child:

                  ListView.builder(



                    padding:
                    EdgeInsets.zero,


                    itemCount:
                    options.length,



                    itemBuilder:
                        (context,index){



                      final cliente =
                      options.elementAt(
                          index
                      );




                      return ListTile(



                        leading:

                        CircleAvatar(


                          backgroundColor:
                          primaria,



                          child:

                          Text(

                            cliente
                                .nomeExibicao
                                .substring(0,1)
                                .toUpperCase(),


                            style:
                            const TextStyle(

                              color:
                              Colors.white,

                              fontWeight:
                              FontWeight.bold,

                            ),

                          ),

                        ),




                        title:

                        Text(

                          cliente.nomeExibicao,

                          style:
                          const TextStyle(

                            fontWeight:
                            FontWeight.bold,

                          ),

                        ),




                        subtitle:

                        Text(

                          cliente.telefone.isEmpty

                              ?

                          "Sem telefone"

                              :

                          cliente.telefone,

                        ),




                        onTap:(){

                          onSelected(
                            cliente,
                          );

                        },


                      );


                    },


                  ),


                ),


              ),


            );

          },


        );


      },

    );


  }







  @override
  Widget build(BuildContext context){



    return Scaffold(



      backgroundColor:
      const Color(0xffF4F6FA),




      appBar:

      AppBar(


        backgroundColor:
        primaria,


        foregroundColor:
        Colors.white,


        title:

        const Text(

          "Nova Dívida",

          style:
          TextStyle(
            fontWeight:
            FontWeight.bold,
          ),

        ),


        centerTitle:true,


      ),






      body:

      Form(


        key:
        formKey,



        child:

        ListView(


          padding:
          const EdgeInsets.all(18),



          children:[





            Container(


              padding:
              const EdgeInsets.all(22),



              decoration:

              BoxDecoration(

                gradient:

                const LinearGradient(

                  colors:[

                    Color(0xff1565C0),

                    Color(0xff42A5F5),

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

                    "Registrar nova dívida",

                    style:
                    TextStyle(

                      color:
                      Colors.white,

                      fontSize:
                      22,

                      fontWeight:
                      FontWeight.bold,

                    ),

                  ),



                  SizedBox(height:8),



                  Text(

                    "Cadastre valores e parcelamentos do cliente",

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
              height:20,
            ),





            campoCliente(),





            const SizedBox(
              height:20,
            ),




            campo(
              "Descrição",
              Icons.description,
              descricao,
            ),




            campo(
              "Categoria",
              Icons.category,
              categoria,
            ),




            campo(
              "Valor total",
              Icons.attach_money,
              valor,
            ),




            campo(
              "Quantidade de parcelas",
              Icons.calendar_month,
              parcelas,
            ),






            InkWell(


              onTap:
              escolherData,



              child:

              Container(


                padding:
                const EdgeInsets.all(18),



                decoration:

                BoxDecoration(

                  color:
                  Colors.white,


                  borderRadius:
                  BorderRadius.circular(18),

                ),




                child:

                Row(


                  children:[



                    const Icon(
                      Icons.event,
                    ),



                    const SizedBox(
                      width:12,
                    ),



                    Text(

                      "Primeiro vencimento: "
                          "${vencimento.day}/${vencimento.month}/${vencimento.year}",

                    ),


                  ],


                ),


              ),


            ),






            const SizedBox(
              height:30,
            ),






            SizedBox(


              height:
              58,



              child:

              ElevatedButton(


                style:

                ElevatedButton.styleFrom(


                  backgroundColor:
                  primaria,


                  foregroundColor:
                  Colors.white,



                  shape:

                  RoundedRectangleBorder(

                    borderRadius:
                    BorderRadius.circular(18),

                  ),


                ),




                onPressed:

                salvando

                    ?

                null

                    :

                salvar,





                child:


                salvando

                    ?

                const CircularProgressIndicator(

                  color:
                  Colors.white,

                )

                    :

                const Text(

                  "CRIAR DÍVIDA",

                  style:
                  TextStyle(

                    fontSize:
                    16,

                    fontWeight:
                    FontWeight.bold,

                  ),

                ),


              ),


            ),





          ],


        ),


      ),


    );


  }


}