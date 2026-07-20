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
        text:"1",
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



  bool salvando=false;









  @override
  void dispose(){


    descricao.dispose();

    categoria.dispose();

    valor.dispose();

    parcelas.dispose();


    super.dispose();


  }









  Future escolherData() async{


    final data =
    await showDatePicker(

      context:
      context,

      initialDate:
      vencimento,

      firstDate:
      DateTime(2020),

      lastDate:
      DateTime(2100),

    );



    if(data!=null){

      setState((){

        vencimento=data;

      });


    }


  }









  double valorNumero(){


    return double.tryParse(

      valor.text

          .replaceAll(".","")

          .replaceAll(",", "."),

    ) ?? 0;


  }









  Future salvar() async{


    if(!formKey.currentState!.validate()){

      return;

    }





    if(clienteId==null){


      ScaffoldMessenger.of(context)
          .showSnackBar(

        const SnackBar(

          content:
          Text(
            "Escolha o cliente",
          ),

        ),

      );


      return;


    }







    setState((){

      salvando=true;

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




      List<Map<String,dynamic>> lista=[];





      for(int i=0;i<qtd;i++){



        lista.add({


          "valor":
          valorParcela,


          "vencimento":
          Timestamp.fromDate(

            DateTime(

              vencimento.year,

              vencimento.month+i,

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

          if(v==null || v.isEmpty){

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









  @override
  Widget build(BuildContext context){


    return Scaffold(



      backgroundColor:
      const Color(0xffF4F6FA),






      appBar:
      AppBar(


        title:
        const Text(

          "Nova Dívida",

          style:
          TextStyle(
            fontWeight:
            FontWeight.bold,
          ),

        ),


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



                  SizedBox(
                    height:8,
                  ),



                  Text(

                    "Cadastre valores e parcelamentos do cliente",

                    style:
                    TextStyle(

                      color:
                      Colors.white70,

                    ),

                  )


                ],


              ),


            ),





            const SizedBox(
              height:20,
            ),






            StreamBuilder<QuerySnapshot>(



              stream:

              FirebaseFirestore.instance

                  .collection("clientes")

                  .orderBy("nome")

                  .snapshots(),




              builder:(context,snapshot){



                if(!snapshot.hasData){

                  return const CircularProgressIndicator();


                }



                final clientes =
                snapshot.data!.docs;






                return Container(


                  padding:
                  const EdgeInsets.symmetric(
                    horizontal:12,
                  ),



                  decoration:
                  BoxDecoration(


                    color:
                    Colors.white,


                    borderRadius:
                    BorderRadius.circular(18),


                  ),



                  child:
                  DropdownButtonFormField<String>(


                    initialValue:
                    clienteId,



                    decoration:
                    const InputDecoration(

                      border:
                      InputBorder.none,

                      prefixIcon:
                      Icon(
                        Icons.person,
                      ),

                      labelText:
                      "Cliente",

                    ),





                    items:

                    clientes.map((doc){



                      final c =
                      ClienteModel.fromMap(

                        doc.data()
                        as Map<String,dynamic>,

                        doc.id,

                      );



                      return DropdownMenuItem(

                        value:
                        c.id,


                        child:
                        Text(
                          c.nomeExibicao,
                        ),

                      );


                    }).toList(),




                    onChanged:(v){


                      final doc =
                      clientes.firstWhere(
                            (e)=>e.id==v,
                      );



                      final c =
                      ClienteModel.fromMap(

                        doc.data()
                        as Map<String,dynamic>,

                        doc.id,

                      );



                      setState((){


                        clienteId=c.id;

                        clienteNome=
                            c.nomeExibicao;


                      });


                    },


                  ),


                );


              },


            ),






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


                    )


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
                  const Color(0xff1565C0),


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

                    color:
                    Colors.white,

                    fontSize:
                    16,

                    fontWeight:
                    FontWeight.bold,

                  ),

                ),


              ),


            )





          ],


        ),


      ),


    );


  }



}