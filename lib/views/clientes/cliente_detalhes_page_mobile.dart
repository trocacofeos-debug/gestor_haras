// ignore_for_file: deprecated_member_use

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/cliente_model.dart';
import '../../models/divida_model.dart';
import '../../services/divida_service.dart';

import 'cliente_modulo_page.dart';
import 'cadastro_cliente_page.dart';



class ClienteDetalhesPageMobile extends StatelessWidget {


  final ClienteModel cliente;



  const ClienteDetalhesPageMobile({

    super.key,

    required this.cliente,

  });



  final Color primaria =
      const Color(0xFF1565C0);



  final Color fundo =
      const Color(0xffF4F7FB);





  String inicial(){


    final nome =
    cliente.nomeExibicao.trim();



    if(nome.isEmpty){

      return "?";

    }



    return nome
        .substring(0,1)
        .toUpperCase();


  }







  String tipoTexto(){


    switch(cliente.tipoCliente){


      case TipoCliente.fisica:

        return "Pessoa Física";


      case TipoCliente.juridica:

        return "Pessoa Jurídica";


      case TipoCliente.rural:

        return "Haras / Rural";


    }

  }







  void abrirModulo(

      BuildContext context,

      String modulo,

      ){


    Navigator.push(

      context,

      MaterialPageRoute(

        builder: (_)=>

            ClienteModuloPage(

              cliente: cliente,

              modulo: modulo,

            ),

      ),

    );


  }








  @override
  Widget build(BuildContext context){


    return Scaffold(


      backgroundColor:

      fundo,



      body:

      Column(

        children: [



          _header(context),



          Expanded(

            child:

            SingleChildScrollView(

              physics:

              const BouncingScrollPhysics(),


              padding:

              const EdgeInsets.all(20),



              child:

              Column(

                children: [



                  _perfil(),



                  const SizedBox(

                    height:20,

                  ),



                  _resumo(),



                  const SizedBox(

                    height:20,

                  ),



                  _ResumoDividaCliente(

                    clienteId: cliente.id,

                    primaria: primaria,

                  ),



                  const SizedBox(

                    height:20,

                  ),



                  _dados(),



                  const SizedBox(

                    height:20,

                  ),



                  _modulos(context),



                ],

              ),

            ),

          ),


        ],

      ),


    );


  }
  Widget _header(BuildContext context){


    return Container(


      padding:

      const EdgeInsets.fromLTRB(

          20,

          45,

          20,

          20

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



      child:

      Row(


        children: [



          InkWell(

            onTap: (){

              Navigator.pop(context);

            },


            child:

            Container(


              padding:

              const EdgeInsets.all(10),


              decoration:

              BoxDecoration(

                color:

                primaria.withOpacity(.10),

                borderRadius:

                BorderRadius.circular(14),

              ),


              child:

              Icon(

                Icons.arrow_back_rounded,

                color:

                primaria,

              ),

            ),

          ),





          const SizedBox(

            width:15,

          ),





          Container(


            padding:

            const EdgeInsets.all(12),


            decoration:

            BoxDecoration(

              color:

              primaria.withOpacity(.12),

              borderRadius:

              BorderRadius.circular(14),

            ),



            child:

            Icon(

              Icons.person_rounded,

              color:

              primaria,

              size:

              30,

            ),


          ),





          const SizedBox(

            width:15,

          ),





          const Expanded(


            child:

            Column(

              crossAxisAlignment:

              CrossAxisAlignment.start,


              children: [



                Text(

                  "Perfil do Cliente",

                  style:

                  TextStyle(

                    fontSize:

                    22,

                    fontWeight:

                    FontWeight.bold,

                  ),

                ),



                SizedBox(

                  height:4,

                ),



                Text(

                  "Informações e módulos",

                  style:

                  TextStyle(

                    color:

                    Colors.grey,

                  ),

                ),


              ],


            ),


          ),


          InkWell(

            onTap: (){

              Navigator.push(

                context,

                MaterialPageRoute(

                  builder: (_) => CadastroClientePage(

                    cliente: cliente,

                  ),

                ),

              );

            },

            child: Container(

              padding: const EdgeInsets.all(10),

              decoration: BoxDecoration(

                color: primaria.withOpacity(.10),

                borderRadius: BorderRadius.circular(14),

              ),

              child: Icon(

                Icons.edit_rounded,

                color: primaria,

              ),

            ),

          ),


        ],


      ),


    );


  }









  Widget _perfil(){


    return Container(


      width:

      double.infinity,



      padding:

      const EdgeInsets.all(25),



      decoration:

      BoxDecoration(



        gradient:

        LinearGradient(



          colors: [



            primaria,

            const Color(0xFF42A5F5),


          ],



          begin:

          Alignment.topLeft,



          end:

          Alignment.bottomRight,


        ),



        borderRadius:

        BorderRadius.circular(28),



        boxShadow: [



          BoxShadow(

            color:

            primaria.withOpacity(.25),

            blurRadius:

            18,

            offset:

            const Offset(0,8),

          ),


        ],



      ),



      child:

      Column(


        children: [



          CircleAvatar(


            radius:

            45,


            backgroundColor:

            Colors.white,


            child:

            CircleAvatar(


              radius:

              40,


              backgroundColor:

              primaria,


              child:

              Text(


                inicial(),


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


          ),





          const SizedBox(

            height:15,

          ),





          Text(


            cliente.nomeExibicao.isEmpty

                ? "Cliente"

                : cliente.nomeExibicao,


            textAlign:

            TextAlign.center,


            style:

            const TextStyle(


              color:

              Colors.white,


              fontSize:

              24,


              fontWeight:

              FontWeight.bold,


            ),


          ),




          const SizedBox(

            height:6,

          ),




          Text(


            tipoTexto(),


            style:

            const TextStyle(


              color:

              Colors.white70,


              fontSize:

              15,


            ),


          ),




          const SizedBox(

            height:15,

          ),




          Container(


            padding:

            const EdgeInsets.symmetric(

              horizontal:18,

              vertical:8,

            ),



            decoration:

            BoxDecoration(

              color:

              Colors.white.withOpacity(.20),

              borderRadius:

              BorderRadius.circular(20),

            ),



            child:

            Row(

              mainAxisSize:

              MainAxisSize.min,


              children: [



                Icon(

                  Icons.circle,

                  size:

                  12,

                  color:

                  cliente.ativo

                      ? Colors.greenAccent

                      : Colors.redAccent,

                ),




                const SizedBox(

                  width:8,

                ),



                Text(


                  cliente.ativo

                      ? "Cliente ativo"

                      : "Cliente inativo",


                  style:

                  const TextStyle(


                    color:

                    Colors.white,


                    fontWeight:

                    FontWeight.w600,


                  ),


                ),



              ],


            ),


          ),


        ],


      ),


    );


  }

    Widget _resumo(){


    return Container(


      padding:

      const EdgeInsets.all(18),



      decoration:

      BoxDecoration(



        color:

        Colors.white,



        borderRadius:

        BorderRadius.circular(22),



        boxShadow: [



          BoxShadow(

            color:

            Colors.black.withOpacity(.04),

            blurRadius:

            10,

          ),



        ],


      ),



      child:

      Row(


        children: [



          Expanded(

            child:

            _miniInfo(

              Icons.badge_rounded,

              "Documento",

              cliente.cpfCnpj,

            ),

          ),




          _divisor(),




          Expanded(

            child:

            _miniInfo(

              Icons.phone_android_rounded,

              "Telefone",

              cliente.telefone,

            ),

          ),





          _divisor(),




          Expanded(

            child:

            _miniInfo(

              Icons.location_city_rounded,

              "Cidade",

              cliente.cidade,

            ),

          ),



        ],


      ),


    );


  }







  Widget _divisor(){


    return Container(

      width:

      1,

      height:

      55,

      color:

      Colors.grey.shade300,

    );


  }







  Widget _miniInfo(

      IconData icon,

      String titulo,

      String valor,

      ){



    return Column(



      children: [



        Icon(

          icon,

          color:

          primaria,

          size:

          26,

        ),




        const SizedBox(

          height:6,

        ),





        Text(

          titulo,

          style:

          const TextStyle(

            color:

            Colors.grey,

            fontSize:

            12,

          ),

        ),





        const SizedBox(

          height:4,

        ),




        Text(

          valor.trim().isEmpty

              ? "-"

              : valor,



          maxLines:

          1,



          overflow:

          TextOverflow.ellipsis,



          textAlign:

          TextAlign.center,



          style:

          const TextStyle(

            fontWeight:

            FontWeight.bold,

            fontSize:

            12,

          ),



        ),



      ],


    );


  }









  Widget _dados(){



    return Column(



      crossAxisAlignment:

      CrossAxisAlignment.start,



      children: [





        _titulo(

          "Dados pessoais",

          Icons.person_outline_rounded,

        ),






        _campo(

          "CPF / CNPJ",

          cliente.cpfCnpj,

          Icons.badge_outlined,

        ),





        _campo(

          "Telefone",

          cliente.telefone,

          Icons.phone_rounded,

        ),





        _campo(

          "Email",

          cliente.email,

          Icons.email_outlined,

        ),







        const SizedBox(

          height:15,

        ),





        _titulo(

          "Endereço",

          Icons.location_on_outlined,

        ),







        _campo(

          "CEP",

          cliente.cep,

          Icons.markunread_mailbox_outlined,

        ),






        _campo(

          "Endereço",

          "${cliente.endereco}, ${cliente.numero}",

          Icons.home_outlined,

        ),






        if(cliente.complemento.isNotEmpty)

          _campo(

            "Complemento",

            cliente.complemento,

            Icons.info_outline,

          ),







        _campo(

          "Cidade / Estado",

          "${cliente.cidade} - ${cliente.estado}",

          Icons.location_city_rounded,

        ),






        if(cliente.tipoCliente == TipoCliente.juridica)

          _empresa(),





        if(cliente.tipoCliente == TipoCliente.rural)

          _haras(),




      ],


    );


  }









  Widget _empresa(){



    return Column(



      crossAxisAlignment:

      CrossAxisAlignment.start,



      children: [





        const SizedBox(

          height:15,

        ),






        _titulo(

          "Dados empresariais",

          Icons.business_center_outlined,

        ),





        _campo(

          "Razão Social",

          cliente.razaoSocial,

          Icons.apartment_rounded,

        ),





        _campo(

          "Nome Fantasia",

          cliente.nomeFantasia,

          Icons.store_rounded,

        ),





      ],


    );


  }









  Widget _haras(){



    return Column(



      crossAxisAlignment:

      CrossAxisAlignment.start,



      children: [



        const SizedBox(

          height:15,

        ),





        _titulo(

          "Dados do Haras",

          Icons.house_rounded,

        ),





        _campo(

          "Nome do Haras",

          cliente.nomeHaras,

          Icons.home_work_rounded,

        ),





        _campo(

          "Registro Rural",

          cliente.idRural,

          Icons.assignment_rounded,

        ),





        _campo(

          "Endereço do Haras",

          cliente.enderecoHaras,

          Icons.location_on_rounded,

        ),



      ],


    );


  }









  Widget _titulo(

      String texto,

      IconData icon,

      ){


    return Padding(



      padding:

      const EdgeInsets.only(

        bottom:12,

      ),



      child:

      Row(



        children: [





          Container(



            padding:

            const EdgeInsets.all(8),



            decoration:

            BoxDecoration(



              color:

              primaria.withOpacity(.12),



              borderRadius:

              BorderRadius.circular(10),



            ),



            child:

            Icon(

              icon,

              size:

              20,

              color:

              primaria,

            ),



          ),






          const SizedBox(

            width:10,

          ),





          Text(



            texto,



            style:

            const TextStyle(



              fontSize:

              18,



              fontWeight:

              FontWeight.bold,



            ),



          ),



        ],



      ),



    );


  }









  Widget _campo(

      String titulo,

      String valor,

      IconData icon,

      ){



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




        boxShadow: [



          BoxShadow(

            color:

            Colors.black.withOpacity(.03),

            blurRadius:

            8,

          ),


        ],



      ),



      child:

      Row(



        children: [





          Container(



            padding:

            const EdgeInsets.all(10),



            decoration:

            BoxDecoration(



              color:

              primaria.withOpacity(.10),



              borderRadius:

              BorderRadius.circular(12),



            ),



            child:

            Icon(



              icon,



              color:

              primaria,



              size:

              22,



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



              children: [





                Text(



                  titulo,



                  style:

                  const TextStyle(



                    color:

                    Colors.grey,



                    fontSize:

                    12,



                  ),



                ),






                const SizedBox(

                  height:4,

                ),





                Text(



                  valor.trim().isEmpty

                      ? "-"

                      : valor,



                  style:

                  const TextStyle(



                    fontSize:

                    15,



                    fontWeight:

                    FontWeight.w600,



                  ),



                ),



              ],



            ),



          ),



        ],



      ),



    );


  }

    Widget _modulos(BuildContext context){


    return Column(



      crossAxisAlignment:

      CrossAxisAlignment.start,



      children: [





        _titulo(

          "Módulos do Cliente",

          Icons.dashboard_customize_rounded,

        ),







        _botaoModulo(


          context,


          "Financeiro",


          "Dívidas, pagamentos e cobranças",


          Icons.account_balance_wallet_rounded,


          Colors.red,


          "Dívidas",


        ),







        _botaoModulo(


          context,


          "Propostas",


          "Orçamentos e negociações comerciais",


          Icons.description_rounded,


          Colors.orange,


          "Propostas",


        ),



      ],



    );


  }









  Widget _botaoModulo(

      BuildContext context,

      String titulo,

      String descricao,

      IconData icon,

      Color cor,

      String modulo,

      ){



    return InkWell(



      borderRadius:

      BorderRadius.circular(22),




      onTap: (){


        abrirModulo(

          context,

          modulo,

        );


      },




      child:

      Container(



        margin:

        const EdgeInsets.only(

          bottom:14,

        ),




        padding:

        const EdgeInsets.all(18),





        decoration:

        BoxDecoration(



          color:

          Colors.white,



          borderRadius:

          BorderRadius.circular(22),





          boxShadow: [



            BoxShadow(



              color:

              Colors.black.withOpacity(.05),



              blurRadius:

              12,



              offset:

              const Offset(0,5),



            ),



          ],



        ),





        child:

        Row(



          children: [





            Container(



              padding:

              const EdgeInsets.all(14),



              decoration:

              BoxDecoration(



                color:

                cor.withOpacity(.12),



                borderRadius:

                BorderRadius.circular(16),



              ),



              child:

              Icon(



                icon,



                color:

                cor,



                size:

                30,



              ),



            ),





            const SizedBox(

              width:15,

            ),





            Expanded(



              child:

              Column(



                crossAxisAlignment:

                CrossAxisAlignment.start,



                children: [





                  Text(



                    titulo,



                    style:

                    const TextStyle(



                      fontSize:

                      18,



                      fontWeight:

                      FontWeight.bold,



                    ),



                  ),





                  const SizedBox(

                    height:5,

                  ),





                  Text(



                    descricao,



                    style:

                    const TextStyle(



                      color:

                      Colors.grey,



                    ),



                  ),



                ],



              ),



            ),






            Container(



              padding:

              const EdgeInsets.all(8),



              decoration:

              BoxDecoration(



                color:

                Colors.grey.withOpacity(.08),



                borderRadius:

                BorderRadius.circular(12),



              ),



              child:

              const Icon(



                Icons.arrow_forward_ios_rounded,



                size:

                16,



                color:

                Colors.grey,



              ),



            ),



          ],



        ),



      ),



    );


  }






}
// =====================================================
// CARD "SITUAÇÃO FINANCEIRA" COM VALORES OCULTOS
// =====================================================
//
// Mostra Total / Pago / Aberto da dívida do cliente,
// mas os valores só aparecem depois que o usuário toca
// no card (fica em modo "oculto" por padrão).


class _ResumoDividaCliente extends StatefulWidget {

  final String clienteId;

  final Color primaria;


  const _ResumoDividaCliente({

    required this.clienteId,

    required this.primaria,

  });


  @override
  State<_ResumoDividaCliente> createState() =>
      _ResumoDividaClienteState();

}



class _ResumoDividaClienteState
    extends State<_ResumoDividaCliente> {


  bool _revelado = false;


  final DividaService _dividaService =
      DividaService();


  final NumberFormat _money =
      NumberFormat.currency(

        locale: "pt_BR",

        symbol: "R\$",

      );




  @override
  Widget build(BuildContext context){


    return StreamBuilder<QuerySnapshot<Map<String,dynamic>>>(


      stream:

      _dividaService.buscarCliente(
        widget.clienteId,
      ),



      builder: (context, snapshot){



        if(!snapshot.hasData){

          return const SizedBox();

        }




        final dividas =

        snapshot.data!.docs

            .map(

              (doc) => DividaModel.fromMap(

                doc.data(),

                doc.id,

              ),

        )

            .toList();




        if(dividas.isEmpty){

          return const SizedBox();

        }




        double total = 0;

        double pago = 0;

        double aberto = 0;



        for(final divida in dividas){


          total += divida.valorTotal;


          final status =
              divida.status.toLowerCase();


          final quitada =

              status == "pago" ||
              status == "quitado" ||
              status == "quitada" ||
              status == "finalizado";


          if(quitada){

            pago += divida.valorTotal;

          } else {

            aberto += divida.valorTotal;

          }


        }




        return InkWell(

          borderRadius: BorderRadius.circular(22),

          onTap: (){

            setState((){

              _revelado = !_revelado;

            });

          },

          child: Container(

            padding: const EdgeInsets.all(18),

            decoration: BoxDecoration(

              color: Colors.white,

              borderRadius: BorderRadius.circular(22),

              boxShadow: [

                BoxShadow(

                  color: Colors.black.withOpacity(.04),

                  blurRadius: 10,

                ),

              ],

            ),

            child: Column(

              crossAxisAlignment: CrossAxisAlignment.start,

              children: [

                Row(

                  children: [

                    Container(

                      padding: const EdgeInsets.all(8),

                      decoration: BoxDecoration(

                        color: widget.primaria.withOpacity(.12),

                        borderRadius: BorderRadius.circular(10),

                      ),

                      child: Icon(

                        Icons.account_balance_wallet_rounded,

                        size: 20,

                        color: widget.primaria,

                      ),

                    ),

                    const SizedBox(width: 10),

                    const Expanded(

                      child: Text(

                        "Situação Financeira",

                        style: TextStyle(

                          fontSize: 18,
                          fontWeight: FontWeight.bold,

                        ),

                      ),

                    ),

                    Icon(

                      _revelado
                          ? Icons.visibility_rounded
                          : Icons.visibility_off_rounded,

                      color: Colors.grey.shade400,

                    ),

                  ],

                ),

                const SizedBox(height: 15),

                Row(

                  children: [

                    Expanded(

                      child: _miniFinanceiro(

                        "Total",
                        total,
                        Colors.blue,

                      ),

                    ),

                    const SizedBox(width: 10),

                    Expanded(

                      child: _miniFinanceiro(

                        "Pago",
                        pago,
                        Colors.green,

                      ),

                    ),

                    const SizedBox(width: 10),

                    Expanded(

                      child: _miniFinanceiro(

                        "Aberto",
                        aberto,
                        Colors.red,

                      ),

                    ),

                  ],

                ),

                if(!_revelado)

                  Padding(

                    padding: const EdgeInsets.only(top: 12),

                    child: Text(

                      "Toque para ver os valores",

                      style: TextStyle(

                        color: Colors.grey.shade500,
                        fontSize: 12,

                      ),

                    ),

                  ),

              ],

            ),

          ),

        );


      },


    );


  }




  Widget _miniFinanceiro(

      String titulo,

      double valor,

      Color cor,

      ){


    return Container(

      padding: const EdgeInsets.all(12),

      decoration: BoxDecoration(

        color: cor.withOpacity(.12),

        borderRadius: BorderRadius.circular(14),

      ),

      child: Column(

        children: [

          Text(

            titulo,

            style: const TextStyle(

              color: Colors.grey,
              fontSize: 12,

            ),

          ),

          const SizedBox(height: 5),

          Text(

            _revelado ? _money.format(valor) : "••••••",

            textAlign: TextAlign.center,

            style: TextStyle(

              color: cor,
              fontWeight: FontWeight.bold,
              fontSize: 13,

            ),

          ),

        ],

      ),

    );

  }


}