// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:flutter/material.dart';
import '../../widgets/app_dialogs.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/divida_model.dart';
import '../../models/cliente_model.dart';
import '../../services/divida_service.dart';
import '../home/admin_top_bar.dart';



class NovaContaPageDesktop extends StatefulWidget {

  final String? clienteIdInicial;

  final String? clienteNomeInicial;


  const NovaContaPageDesktop({
    super.key,

    this.clienteIdInicial,

    this.clienteNomeInicial,
  });


  @override
  State<NovaContaPageDesktop> createState() =>
      _NovaContaPageDesktopState();

}





class _NovaContaPageDesktopState
    extends State<NovaContaPageDesktop> {


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
      const Color(0xFF1565C0);


  final Color fundo =
      const Color(0xffF4F7FB);





  @override
  void initState(){

    super.initState();

    clienteId =
        widget.clienteIdInicial;

    clienteNome =
        widget.clienteNomeInicial;

  }





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
    await showAppDatePicker(

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







  // =====================================================
  // HEADER PADRÃO DO APP
  // =====================================================


  Widget _header(){

    return Container(

      padding:

      const EdgeInsets.fromLTRB(
          20,
          45,
          20,
          20,
      ),

      decoration:

      BoxDecoration(

        color:
        Colors.white,

        boxShadow: [

          BoxShadow(

            color:
            Colors.black.withOpacity(.05),

            blurRadius:
            10,

          ),

        ],

      ),

      child: Row(

        children: [

          InkWell(

            onTap: (){

              Navigator.pop(context);

            },

            child: Container(

              padding:
              const EdgeInsets.all(10),

              decoration: BoxDecoration(

                color:
                primaria.withOpacity(.10),

                borderRadius:
                BorderRadius.circular(14),

              ),

              child: Icon(

                Icons.arrow_back_rounded,

                color:
                primaria,

              ),

            ),

          ),

          const SizedBox(width: 15),

          Container(

            padding:
            const EdgeInsets.all(12),

            decoration: BoxDecoration(

              color:
              primaria.withOpacity(.12),

              borderRadius:
              BorderRadius.circular(14),

            ),

            child: Icon(

              Icons.account_balance_wallet_rounded,

              color:
              primaria,

              size: 30,

            ),

          ),

          const SizedBox(width: 15),

          const Expanded(

            child: Column(

              crossAxisAlignment:
              CrossAxisAlignment.start,

              children: [

                Text(

                  "Nova Dívida",

                  style: TextStyle(

                    fontSize: 22,
                    fontWeight: FontWeight.bold,

                  ),

                ),

                SizedBox(height: 4),

                Text(

                  "Valores e parcelamento do cliente",

                  style: TextStyle(

                    color: Colors.grey,

                  ),

                ),

              ],

            ),

          ),

        ],

      ),

    );

  }







  // =====================================================
  // TÍTULO DE SEÇÃO (mesmo padrão do resto do app)
  // =====================================================


  Widget _titulo(String texto, IconData icon){

    return Padding(

      padding: const EdgeInsets.only(bottom: 12),

      child: Row(

        children: [

          Container(

            padding: const EdgeInsets.all(8),

            decoration: BoxDecoration(

              color: primaria.withOpacity(.12),

              borderRadius: BorderRadius.circular(10),

            ),

            child: Icon(icon, size: 20, color: primaria),

          ),

          const SizedBox(width: 10),

          Text(

            texto,

            style: const TextStyle(

              fontSize: 18,
              fontWeight: FontWeight.bold,

            ),

          ),

        ],

      ),

    );

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

          Icon(icon, color: primaria),


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


    // Se a página já foi aberta com um cliente definido
    // (ex: a partir da tela do próprio cliente), não precisa
    // pesquisar de novo — mostramos um card fixo com o cliente,
    // no mesmo padrão visual usado no restante do app.
    if(widget.clienteIdInicial != null){


      return Container(

        padding: const EdgeInsets.all(16),

        decoration: BoxDecoration(

          color: Colors.white,

          borderRadius: BorderRadius.circular(18),

          boxShadow: [

            BoxShadow(

              color: Colors.black.withOpacity(.03),

              blurRadius: 8,

            ),

          ],

        ),

        child: Row(

          children: [

            Container(

              padding: const EdgeInsets.all(10),

              decoration: BoxDecoration(

                color: primaria.withOpacity(.10),

                borderRadius: BorderRadius.circular(12),

              ),

              child: CircleAvatar(

                radius: 16,

                backgroundColor: primaria,

                child: Text(

                  (clienteNome ?? "?").isEmpty
                      ? "?"
                      : clienteNome!.substring(0, 1).toUpperCase(),

                  style: const TextStyle(

                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,

                  ),

                ),

              ),

            ),

            const SizedBox(width: 12),

            Expanded(

              child: Column(

                crossAxisAlignment: CrossAxisAlignment.start,

                children: [

                  const Text(

                    "Cliente",

                    style: TextStyle(

                      color: Colors.grey,
                      fontSize: 12,

                    ),

                  ),

                  const SizedBox(height: 4),

                  Text(

                    clienteNome ?? "-",

                    style: const TextStyle(

                      fontWeight: FontWeight.w600,
                      fontSize: 15,

                    ),

                  ),

                ],

              ),

            ),

          ],

        ),

      );

    }



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

                clienteNome ?? "Pesquisar cliente",



                prefixIcon:

                Icon(
                  Icons.search,
                  color: primaria,
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


  // =====================================================
  // CAMPO DE DATA (padrão "_campo" do restante do app)
  // =====================================================


  Widget _campoData(){

    return InkWell(

      onTap: escolherData,

      borderRadius: BorderRadius.circular(18),

      child: Container(

        padding: const EdgeInsets.all(16),

        decoration: BoxDecoration(

          color: Colors.white,

          borderRadius: BorderRadius.circular(18),

          boxShadow: [

            BoxShadow(

              color: Colors.black.withOpacity(.03),

              blurRadius: 8,

            ),

          ],

        ),

        child: Row(

          children: [

            Container(

              padding: const EdgeInsets.all(10),

              decoration: BoxDecoration(

                color: primaria.withOpacity(.10),

                borderRadius: BorderRadius.circular(12),

              ),

              child: Icon(Icons.event_rounded, color: primaria, size: 22),

            ),

            const SizedBox(width: 12),

            Expanded(

              child: Column(

                crossAxisAlignment: CrossAxisAlignment.start,

                children: [

                  const Text(

                    "Primeiro vencimento",

                    style: TextStyle(

                      color: Colors.grey,
                      fontSize: 12,

                    ),

                  ),

                  const SizedBox(height: 4),

                  Text(

                    "${vencimento.day.toString().padLeft(2, '0')}/"
                    "${vencimento.month.toString().padLeft(2, '0')}/"
                    "${vencimento.year}",

                    style: const TextStyle(

                      fontSize: 15,
                      fontWeight: FontWeight.w600,

                    ),

                  ),

                ],

              ),

            ),

            Icon(Icons.chevron_right_rounded, color: Colors.grey.shade400),

          ],

        ),

      ),

    );

  }







  @override
  Widget build(BuildContext context){

    return Scaffold(

      backgroundColor: fundo,

      body: Column(

        children: [

          const AdminTopBar(),

          _header(),

          Expanded(

            child: Form(

              key: formKey,

              child: SingleChildScrollView(

                padding: const EdgeInsets.all(24),

                physics: const BouncingScrollPhysics(),

                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1440),
                    child: Row(

                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [

                    // Coluna esquerda: contexto (card + cliente)
                    SizedBox(

                      width: 360,

                      child: Column(

                        children: [

                          Container(

                            width: double.infinity,

                            padding: const EdgeInsets.all(24),

                            decoration: BoxDecoration(

                              gradient: LinearGradient(

                                colors: [
                                  primaria,
                                  const Color(0xFF42A5F5),
                                ],

                                begin: Alignment.topLeft,

                                end: Alignment.bottomRight,

                              ),

                              borderRadius: BorderRadius.circular(24),

                              boxShadow: [

                                BoxShadow(

                                  color: primaria.withOpacity(.25),

                                  blurRadius: 18,

                                  offset: const Offset(0, 8),

                                ),

                              ],

                            ),

                            child: const Column(

                              crossAxisAlignment: CrossAxisAlignment.start,

                              children: [

                                Text(

                                  "Registrar nova dívida",

                                  style: TextStyle(

                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,

                                  ),

                                ),

                                SizedBox(height: 8),

                                Text(

                                  "Cadastre valores e parcelamentos do cliente",

                                  style: TextStyle(color: Colors.white70),

                                ),

                              ],

                            ),

                          ),

                          const SizedBox(height: 25),

                          _titulo("Cliente", Icons.person_outline_rounded),

                          const SizedBox(height: 5),

                          campoCliente(),

                        ],

                      ),

                    ),

                    const SizedBox(width: 24),

                    // Coluna direita: detalhes da dívida
                    Expanded(

                      child: Column(

                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [

                          _titulo(
                            "Detalhes da dívida",
                            Icons.receipt_long_rounded,
                          ),

                          const SizedBox(height: 5),

                          campo(
                            "Descrição",
                            Icons.description_outlined,
                            descricao,
                          ),

                          campo(
                            "Categoria",
                            Icons.category_outlined,
                            categoria,
                          ),

                          campo(
                            "Valor total",
                            Icons.attach_money_rounded,
                            valor,
                          ),

                          campo(
                            "Quantidade de parcelas",
                            Icons.calendar_month_outlined,
                            parcelas,
                          ),

                          _campoData(),

                          const SizedBox(height: 30),

                          SizedBox(

                            height: 58,

                            child: ElevatedButton(

                              style: ElevatedButton.styleFrom(

                                backgroundColor: primaria,

                                foregroundColor: Colors.white,

                                elevation: 0,

                                shape: RoundedRectangleBorder(

                                  borderRadius: BorderRadius.circular(18),

                                ),

                              ),

                              onPressed: salvando ? null : salvar,

                              child: salvando
                                  ? const CircularProgressIndicator(
                                      color: Colors.white,
                                    )
                                  : const Text(

                                      "CRIAR DÍVIDA",

                                      style: TextStyle(

                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,

                                      ),

                                    ),

                            ),

                          ),

                        ],

                      ),

                    ),

                  ],

                ),
                  ),
                ),

              ),

            ),

          ),

        ],

      ),

    );

  }



}
