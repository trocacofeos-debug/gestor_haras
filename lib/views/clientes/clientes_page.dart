import 'package:flutter/material.dart';

import '../../models/cliente_model.dart';
import '../../services/cliente_service.dart';
import 'cadastro_cliente_page.dart';


class ClientesPage extends StatefulWidget {

  const ClientesPage({
    super.key,
  });


  @override
  State<ClientesPage> createState() =>
      _ClientesPageState();

}



class _ClientesPageState
    extends State<ClientesPage> {


  final ClienteService service =
      ClienteService();


  final TextEditingController buscaController =
      TextEditingController();


  String busca = '';



  // 🔵 Tema Azul
  final Color primaria =
      const Color(0xFF1565C0);



  final Color fundo =
      const Color(0xFFF4F7FB);




  Color statusColor(bool ativo) {

    return ativo
        ? Colors.green
        : Colors.red;

  }




  String tipoTexto(TipoCliente tipo) {

    switch(tipo){

      case TipoCliente.fisica:
        return "Pessoa Física";

      case TipoCliente.juridica:
        return "Pessoa Jurídica";

      case TipoCliente.rural:
        return "Haras / Rural";

    }

  }





  String inicialCliente(ClienteModel c){

    final nome =
        c.nomeExibicao.trim();


    if(nome.isEmpty){
      return "?";
    }


    return nome[0].toUpperCase();

  }





  Future<void> abrirCadastro() async {


    await Navigator.push(

      context,

      MaterialPageRoute(

        builder: (_) =>
        const CadastroClientePage(),

      ),

    );


    setState(() {});

  }








  void abrirDetalhes(
      ClienteModel cliente,
      ) {


    showDialog(

      context: context,

      builder: (_) {


        return AlertDialog(

          shape:

          RoundedRectangleBorder(

            borderRadius:
            BorderRadius.circular(22),

          ),




          title:


          Row(

            children: [


              CircleAvatar(

                radius:25,


                backgroundColor:
                primaria,


                child:

                Text(

                  inicialCliente(cliente),


                  style:

                  const TextStyle(

                    color:
                    Colors.white,

                    fontWeight:
                    FontWeight.bold,

                    fontSize:20,

                  ),

                ),

              ),



              const SizedBox(
                width:12,
              ),




              Expanded(

                child:

                Text(

                  cliente.nomeExibicao,

                  overflow:
                  TextOverflow.ellipsis,

                ),

              ),

            ],

          ),





          content:


          Column(

            mainAxisSize:
            MainAxisSize.min,


            children: [


              _itemDetalhe(
                Icons.phone,
                "Telefone",
                cliente.telefone,
              ),



              _itemDetalhe(
                Icons.email,
                "Email",
                cliente.email,
              ),



              _itemDetalhe(
                Icons.location_city,
                "Cidade",
                cliente.cidade,
              ),



              _itemDetalhe(
                Icons.home,
                "Endereço",
                "${cliente.endereco}, ${cliente.numero}",
              ),



              _itemDetalhe(
                Icons.badge,
                "Tipo",
                tipoTexto(
                    cliente.tipoCliente
                ),
              ),



            ],

          ),





          actions: [


            TextButton(

              onPressed:
                  () => Navigator.pop(context),


              child:

              Text(

                "Fechar",

                style:

                TextStyle(
                  color:
                  primaria,
                ),

              ),

            ),


          ],


        );


      },

    );


  }








  Widget _itemDetalhe(
      IconData icon,
      String titulo,
      String valor,
      ){


    return Padding(

      padding:
      const EdgeInsets.only(
        bottom:12,
      ),


      child:


      Row(

        children: [



          Icon(

            icon,

            size:21,

            color:
            primaria,

          ),




          const SizedBox(
            width:10,
          ),




          Expanded(

            child:

            Text(

              "$titulo: ${valor.isEmpty ? '-' : valor}",

            ),

          ),


        ],

      ),


    );

  }








  @override
  void dispose(){

    buscaController.dispose();

    super.dispose();

  }








  @override
  Widget build(BuildContext context) {


    return Scaffold(


      backgroundColor:
      fundo,





      appBar:

      AppBar(


        elevation:0,


        backgroundColor:
        primaria,


        foregroundColor:
        Colors.white,



        centerTitle:true,



        title:

        const Text(

          "Clientes",

          style:

          TextStyle(

            fontWeight:
            FontWeight.bold,

          ),

        ),


      ),







      floatingActionButton:


      FloatingActionButton.extended(


        backgroundColor:
        primaria,


        foregroundColor:
        Colors.white,


        icon:

        const Icon(
          Icons.person_add_alt_1,
        ),



        label:

        const Text(
          "Novo Cliente",
        ),



        onPressed:
        abrirCadastro,


      ),







      body:


      StreamBuilder<List<ClienteModel>>(


        stream:

        service.streamClientes(),



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





          if(snapshot.hasError){


            return Center(

              child:

              Text(

                "Erro:\n${snapshot.error}",

                textAlign:
                TextAlign.center,

              ),

            );

          }






          final todos =
              snapshot.data ?? [];




          final clientes =

          todos.where((cliente){


            final texto =

            "${cliente.nomeExibicao} ${cliente.telefone}"
                .toLowerCase();



            return texto.contains(
              busca.toLowerCase(),
            );


          }).toList();








          return Column(


            children: [





              Padding(

                padding:
                const EdgeInsets.all(16),


                child:

                TextField(



                  controller:
                  buscaController,



                  onChanged:(valor){


                    setState(() {

                      busca =
                          valor;

                    });


                  },



                  decoration:


                  InputDecoration(



                    hintText:

                    "Buscar cliente...",



                    prefixIcon:

                    Icon(

                      Icons.search,

                      color:
                      primaria,

                    ),




                    filled:true,



                    fillColor:
                    Colors.white,




                    border:

                    OutlineInputBorder(


                      borderRadius:

                      BorderRadius.circular(
                        16,
                      ),



                      borderSide:
                      BorderSide.none,


                    ),



                  ),



                ),

              ),







              Container(

                margin:

                const EdgeInsets.symmetric(
                  horizontal:16,
                ),


                padding:

                const EdgeInsets.all(14),



                decoration:

                BoxDecoration(

                  color:
                  Colors.white,


                  borderRadius:

                  BorderRadius.circular(
                    16,
                  ),


                ),



                child:

                Row(

                  children: [


                    Icon(

                      Icons.people,

                      color:
                      primaria,

                    ),



                    const SizedBox(
                      width:10,
                    ),



                    Text(

                      "${clientes.length} clientes cadastrados",

                      style:

                      const TextStyle(

                        fontWeight:
                        FontWeight.bold,

                      ),

                    ),


                  ],

                ),


              ),







              const SizedBox(
                height:12,
              ),







              Expanded(


                child:


                ListView.builder(



                  padding:

                  const EdgeInsets.all(16),



                  itemCount:

                  clientes.length,




                  itemBuilder:

                      (context,index){



                    final cliente =
                    clientes[index];





                    return Card(



                      elevation:

                      2,



                      margin:

                      const EdgeInsets.only(
                        bottom:12,
                      ),




                      shape:

                      RoundedRectangleBorder(



                        borderRadius:

                        BorderRadius.circular(
                          18,
                        ),



                      ),





                      child:


                      ListTile(





                        onTap:

                            () => abrirDetalhes(
                              cliente,
                            ),





                        leading:


                        CircleAvatar(



                          radius:

                          28,



                          backgroundColor:

                          primaria.withValues(
                            alpha:0.15,
                          ),




                          child:


                          Text(

                            inicialCliente(cliente),


                            style:


                            TextStyle(


                              color:
                              primaria,


                              fontSize:
                              22,


                              fontWeight:
                              FontWeight.bold,


                            ),

                          ),


                        ),







                        title:


                        Text(



                          cliente.nomeExibicao
                              .isEmpty

                              ? "Cliente sem nome"

                              : cliente.nomeExibicao,



                          style:

                          const TextStyle(

                            fontWeight:
                            FontWeight.bold,

                          ),


                        ),







                        subtitle:


                        Text(


                          cliente.telefone.isEmpty

                              ? tipoTexto(
                              cliente.tipoCliente)

                              : "${cliente.telefone}\n${tipoTexto(cliente.tipoCliente)}",



                        ),







                        trailing:


                        Icon(

                          cliente.ativo

                              ? Icons.check_circle

                              : Icons.cancel,



                          color:

                          statusColor(
                            cliente.ativo,
                          ),


                        ),



                      ),



                    );


                  },



                ),


              ),



            ],


          );


        },


      ),


    );


  }

}