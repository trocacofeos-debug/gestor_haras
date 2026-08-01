
// ignore_for_file: unused_field, deprecated_member_use

import 'package:flutter/material.dart';

import '../../models/cliente_model.dart';
import '../../services/cliente_service.dart';

import '../home/admin_home.dart';
import 'cliente_detalhes_page.dart';



class ClientesPageMobile extends StatefulWidget {


  const ClientesPageMobile({

    super.key,

  });



  @override
  State<ClientesPageMobile> createState() =>
      _ClientesPageMobileState();


}








class _ClientesPageMobileState
    extends State<ClientesPageMobile> {



  final ClienteService service =
      ClienteService();




  final TextEditingController buscaController =
      TextEditingController();




  final ValueNotifier<String> buscaNotifier =
      ValueNotifier("");






  // ==============================
  // CORES DASHBOARD CORPORATIVO
  // ==============================


  static const Color corSidebar =
      Color(0xFF111827);



  static const Color corPrimaria =
      Color(0xFF4F46E5);



  static const Color corFundo =
      Color(0xFFF3F4F6);



  static const Color corTexto =
      Color(0xFF111827);



  static const Color corSecundario =
      Color(0xFF6B7280);



  static const Color corBorda =
      Color(0xFFE5E7EB);









  @override
  void dispose(){


    buscaController.dispose();


    buscaNotifier.dispose();


    super.dispose();


  }









  // ==============================
  // VOLTAR DASHBOARD
  // ==============================


  void voltarDashboard(){



    Navigator.pushReplacement(



      context,



      MaterialPageRoute(



        builder: (_) =>

        const AdminHome(),



      ),



    );



  }









  void abrirDetalhes(

      ClienteModel cliente,

      ){



    Navigator.push(



      context,



      MaterialPageRoute(



        builder: (_) =>

        ClienteDetalhesPage(



          cliente: cliente,



        ),



      ),



    );



  }












  String limparTexto(

      String valor,

      ){



    return valor

        .toLowerCase()

        .replaceAll(

        RegExp(

            r'[^a-z0-9]'

        ),

        ''

    );



  }









  String inicialCliente(

      ClienteModel cliente,

      ){



    final nome =

    cliente.nomeExibicao.trim();



    if(nome.isEmpty){


      return "?";


    }



    return nome

        .substring(0,1)

        .toUpperCase();



  }









  String tipoTexto(

      TipoCliente tipo,

      ){



    switch(tipo){



      case TipoCliente.fisica:

        return "Pessoa Física";



      case TipoCliente.juridica:

        return "Pessoa Jurídica";



      case TipoCliente.rural:

        return "Haras / Rural";


    }


  }

    Color statusColor(
      bool ativo,
      ){


    return ativo

        ? Colors.green

        : Colors.red;


  }









  @override
  Widget build(BuildContext context){



    return Scaffold(



      backgroundColor:

      corFundo,





      body:

      SafeArea(



        child:

        Column(



          children: [





            _header(),





            Expanded(



              child:

              _conteudo(),



            ),





          ],



        ),



      ),



    );



  }













  // ==============================
  // HEADER CORPORATIVO
  // ==============================


  Widget _header(){



    return Container(



      height:

      90,



      padding:

      const EdgeInsets.symmetric(

        horizontal:

        20,

      ),




      decoration:

      const BoxDecoration(



        color:

        Colors.white,



        border:



        Border(



          bottom:

          BorderSide(

            color:

            corBorda,

          ),



        ),



      ),







      child:

      Row(



        children: [





          IconButton(



            tooltip:

            "Voltar Dashboard",



            onPressed:

            voltarDashboard,



            icon:

            const Icon(



              Icons.arrow_back_rounded,



              color:

              corPrimaria,



              size:

              28,



            ),



          ),







          Container(



            padding:

            const EdgeInsets.all(12),



            decoration:

            BoxDecoration(



              color:

              corPrimaria.withOpacity(.10),



              borderRadius:

              BorderRadius.circular(12),



            ),




            child:

            const Icon(



              Icons.people_alt_outlined,



              color:

              corPrimaria,



              size:

              30,



            ),



          ),








          const SizedBox(

            width:

            15,

          ),








          const Expanded(



            child:

            Column(



              mainAxisAlignment:

              MainAxisAlignment.center,



              crossAxisAlignment:

              CrossAxisAlignment.start,



              children: [





                Text(



                  "Clientes",



                  style:

                  TextStyle(



                    fontSize:

                    22,



                    fontWeight:

                    FontWeight.w700,



                    color:

                    corTexto,



                  ),



                ),






                SizedBox(

                  height:

                  4,

                ),







                Text(



                  "Gestão de clientes do haras",



                  style:

                  TextStyle(



                    color:

                    corSecundario,



                    fontSize:

                    13,



                  ),



                ),



              ],



            ),



          ),







          IconButton(



            tooltip:

            "Atualizar",



            onPressed:

                (){


              setState((){});


            },



            icon:

            const Icon(



              Icons.refresh_rounded,



              color:

              corPrimaria,



            ),



          ),





        ],



      ),



    );



  }












  // ==============================
  // CONTEÚDO
  // ==============================


  Widget _conteudo(){



    return StreamBuilder<List<ClienteModel>>(



      stream:

      service.streamClientes(),





      builder:

          (context,snapshot){





        if(snapshot.connectionState ==

            ConnectionState.waiting){



          return const Center(



            child:

            CircularProgressIndicator(



              color:

              corPrimaria,



            ),



          );



        }







        if(snapshot.hasError){



          return Center(



            child:

            Text(



              "Erro ao carregar clientes\n${snapshot.error}",



              textAlign:

              TextAlign.center,



            ),



          );



        }







        final todos =

        snapshot.data ?? [];








        return ValueListenableBuilder<String>(



          valueListenable:

          buscaNotifier,





          builder:

              (context,busca,_){





            final clientes =

            todos.where((cliente){





              final filtro =

              limparTexto(busca);







              if(filtro.isEmpty){



                return true;



              }







              return

                  limparTexto(

                      cliente.nomeExibicao

                  )

                      .contains(filtro)





                      ||





                      limparTexto(

                          cliente.cpfCnpj

                      )

                          .contains(filtro)







                      ||





                      limparTexto(

                          cliente.telefone

                      )

                          .contains(filtro)







                      ||





                      limparTexto(

                          cliente.email

                      )

                          .contains(filtro);





            }).toList();









            return SingleChildScrollView(



              physics:

              const BouncingScrollPhysics(),





              child:

              Column(



                children: [






                  _cardsResumo(clientes),






                  _campoBusca(),






                  const SizedBox(

                    height:

                    10,

                  ),







                  _listaClientes(clientes),





                  const SizedBox(

                    height:

                    30,

                  ),





                ],



              ),



            );





          },



        );



      },



    );



  }

    Widget _cardsResumo(
      List<ClienteModel> clientes,
      ){


    final ativos = clientes
        .where((c)=>c.ativo)
        .length;


    final inativos =
        clientes.length - ativos;




    return Padding(


      padding:

      const EdgeInsets.all(20),



      child:

      Row(



        children: [



          Expanded(

            child: _cardResumo(

              "Clientes",

              clientes.length.toString(),

              Icons.people_alt_outlined,

              Colors.blue,

            ),

          ),




          const SizedBox(width:10),




          Expanded(

            child: _cardResumo(

              "Ativos",

              ativos.toString(),

              Icons.check_circle_outline,

              Colors.green,

            ),

          ),




          const SizedBox(width:10),




          Expanded(

            child: _cardResumo(

              "Inativos",

              inativos.toString(),

              Icons.cancel_outlined,

              Colors.red,

            ),

          ),




        ],



      ),



    );

  }









  Widget _cardResumo(

      String titulo,

      String valor,

      IconData icon,

      Color cor,

      ){


    return Container(


      height:

      110,


      padding:

      const EdgeInsets.all(14),



      decoration:

      BoxDecoration(


        color:

        Colors.white,


        borderRadius:

        BorderRadius.circular(16),



        border:

        Border.all(

          color:

          corBorda,

        ),



      ),




      child:

      Column(



        crossAxisAlignment:

        CrossAxisAlignment.start,



        children: [



          Icon(

            icon,

            color:

            cor,

          ),




          const Spacer(),




          Text(

            valor,


            style:

            const TextStyle(


              fontSize:

              24,


              fontWeight:

              FontWeight.bold,


              color:

              corTexto,


            ),

          ),




          Text(

            titulo,


            style:

            const TextStyle(


              color:

              corSecundario,


              fontSize:

              12,


            ),

          ),




        ],


      ),


    );

  }









  Widget _campoBusca(){



    return Padding(


      padding:

      const EdgeInsets.symmetric(

        horizontal:

        20,

      ),



      child:

      TextField(



        controller:

        buscaController,




        onChanged:

            (valor){


          buscaNotifier.value = valor;


        },





        decoration:

        InputDecoration(



          hintText:

          "Buscar cliente...",



          prefixIcon:

          const Icon(

            Icons.search,

            color:

            corPrimaria,

          ),




          filled:

          true,



          fillColor:

          Colors.white,



          border:

          OutlineInputBorder(



            borderRadius:

            BorderRadius.circular(14),



            borderSide:

            BorderSide.none,



          ),



        ),



      ),



    );


  }












  Widget _listaClientes(
      List<ClienteModel> clientes,
      ){

    if(clientes.isEmpty){

      return const Padding(
        padding: EdgeInsets.all(50),
        child: Text(
          "Nenhum cliente encontrado",
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return _listaClientesCards(clientes);
  }

  Widget _listaClientesCards(List<ClienteModel> clientes) {

    return ListView.builder(



      shrinkWrap:

      true,



      physics:

      const NeverScrollableScrollPhysics(),



      padding:

      const EdgeInsets.symmetric(

        horizontal:

        20,

      ),



      itemCount:

      clientes.length,



      itemBuilder:

          (context,index){



        return _clienteCard(

          clientes[index],

        );



      },



    );



  }




  Widget _clienteCard(

      ClienteModel cliente,

      ){


    return InkWell(



      onTap:

          (){

        abrirDetalhes(cliente);

      },



      child:

      Container(



        margin:

        const EdgeInsets.only(

          bottom:

          12,

        ),




        padding:

        const EdgeInsets.all(16),




        decoration:

        BoxDecoration(



          color:

          Colors.white,



          borderRadius:

          BorderRadius.circular(16),




          border:

          Border.all(

            color:

            corBorda,

          ),



        ),




        child:

        Row(



          children: [



            CircleAvatar(



              radius:

              28,



              backgroundColor:

              corPrimaria.withOpacity(.10),



              child:

              Text(



                inicialCliente(cliente),



                style:

                const TextStyle(



                  color:

                  corPrimaria,



                  fontWeight:

                  FontWeight.bold,



                  fontSize:

                  22,



                ),



              ),



            ),






            const SizedBox(width:15),




            Expanded(



              child:

              Column(



                crossAxisAlignment:

                CrossAxisAlignment.start,



                children: [



                  Text(



                    cliente.nomeExibicao.isEmpty

                        ? "Cliente sem nome"

                        :

                    cliente.nomeExibicao,



                    style:

                    const TextStyle(



                      fontWeight:

                      FontWeight.bold,



                      fontSize:

                      16,



                    ),



                  ),





                  const SizedBox(height:6),




                  Text(



                    cliente.telefone.isEmpty

                        ? "Sem telefone"

                        :

                    cliente.telefone,



                    style:

                    const TextStyle(



                      color:

                      corSecundario,



                    ),



                  ),




                  Text(



                    tipoTexto(cliente.tipoCliente),



                    style:

                    const TextStyle(



                      color:

                      corPrimaria,



                      fontWeight:

                      FontWeight.w600,



                    ),



                  ),



                ],



              ),



            ),





            Icon(



              cliente.ativo

                  ? Icons.check_circle

                  :

              Icons.cancel,



              color:

              statusColor(cliente.ativo),



            )



          ],



        ),



      ),



    );



  }
}