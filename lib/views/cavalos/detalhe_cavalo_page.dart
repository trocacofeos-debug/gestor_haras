import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/cavalo_model.dart';



class DetalheCavaloPage extends StatelessWidget {


  final CavaloModel cavalo;



  const DetalheCavaloPage({

    super.key,

    required this.cavalo,

  });





  Future<void> abrirWhatsApp() async {


    final mensagem = Uri.encodeComponent(

'''
Olá, tenho interesse no cavalo:

🐎 Nome: ${cavalo.nome}

Raça: ${cavalo.raca}

Valor:
R\$ ${cavalo.preco.toStringAsFixed(2)}

Gostaria de mais informações.
'''

    );



    final url = Uri.parse(

      "https://wa.me/?text=$mensagem",

    );




    if(await canLaunchUrl(url)){


      await launchUrl(

        url,

        mode: LaunchMode.externalApplication,

      );


    }


  }







  @override
  Widget build(BuildContext context){


    return Scaffold(


      backgroundColor:

      const Color(0xffF7F4F0),





      body:


      CustomScrollView(


        slivers:[




          SliverAppBar(


            expandedHeight:

            360,



            pinned:

            true,



            backgroundColor:

            const Color(0xFF5D4037),




            leading:


            IconButton(


              icon:

              const Icon(

                Icons.arrow_back,

                color:

                Colors.white,

              ),



              onPressed:(){


                Navigator.pop(context);


              },


            ),






            flexibleSpace:


            FlexibleSpaceBar(



              title:


              Text(


                cavalo.nome,


                style:


                const TextStyle(


                  color:

                  Colors.white,


                  fontWeight:

                  FontWeight.bold,


                ),


              ),





              background:


              _galeriaFotos(),



            ),



          ),






          SliverToBoxAdapter(



            child:


            Padding(


              padding:


              const EdgeInsets.all(18),





              child:


              Column(



                crossAxisAlignment:


                CrossAxisAlignment.start,





                children:[





                  _cardPrincipal(),






                  const SizedBox(

                    height:25,

                  ),





                  const Text(



                    "Detalhes do animal",



                    style:


                    TextStyle(



                      fontSize:22,


                      fontWeight:

                      FontWeight.bold,


                    ),



                  ),






                  const SizedBox(

                    height:15,

                  ),







                  Wrap(



                    spacing:

                    10,



                    runSpacing:

                    10,



                    children:[





                      _chip(

                        Icons.category,

                        cavalo.raca,

                      ),





                      _chip(

                        Icons.male,

                        cavalo.sexo,

                      ),





                      _chip(

                        Icons.color_lens,

                        cavalo.pelagem,

                      ),





                      _chip(

                        Icons.cake,

                        "${cavalo.idade} anos",

                      ),





                      _chip(

                        Icons.badge,

                        cavalo.registro,

                      ),



                    ],



                  ),





                  const SizedBox(

                    height:25,

                  ),





                  _descricao(),





                  const SizedBox(

                    height:120,

                  ),



                ],



              ),



            ),



          ),



        ],



      ),





      floatingActionButton:


      FloatingActionButton.extended(



        backgroundColor:

        const Color(0xFF25D366),




        icon:


        const Icon(

          Icons.chat,

          color:

          Colors.white,

        ),





        label:


        const Text(

          "Tenho interesse",

          style:

          TextStyle(

            color:

            Colors.white,

            fontWeight:

            FontWeight.bold,

          ),

        ),




        onPressed:

        abrirWhatsApp,



      ),




    );


  }
  Widget _galeriaFotos(){


    debugPrint("==============================");
    debugPrint("LISTA DE FOTOS DO CAVALO");
    debugPrint(cavalo.fotos.toString());
    debugPrint("==============================");



    if(cavalo.fotos.isEmpty){


      return _erroImagem(
        "Nenhuma foto cadastrada",
      );


    }




    return Stack(


      children:[




        PageView.builder(


          itemCount:

          cavalo.fotos.length,




          itemBuilder:

          (context,index){



            final url =

            cavalo.fotos[index].trim();




            debugPrint(

              "ABRINDO IMAGEM R2: $url"

            );





            if(url.isEmpty){


              return _erroImagem(

                "URL vazia",

              );


            }





            return GestureDetector(



              onTap:(){


                Navigator.push(


                  context,


                  MaterialPageRoute(


                    builder:(context)=>


                    TelaImagem(


                      url:url,


                    ),


                  ),


                );



              },





              child:


              SizedBox.expand(


                child:


                Image.network(



                  url,



                  fit:

                  BoxFit.cover,




                  headers:{


                    "Accept":

                    "image/*",


                  },




                  loadingBuilder:


                  (
                    context,
                    child,
                    loading
                  ){



                    if(loading == null){


                      return child;


                    }




                    return Container(



                      color:

                      Colors.grey.shade200,




                      child:


                      const Center(



                        child:


                        CircularProgressIndicator(),



                      ),



                    );


                  },







                  errorBuilder:


                  (
                    context,
                    error,
                    stack
                  ){



                    debugPrint(

                      "ERRO AO CARREGAR R2"

                    );


                    debugPrint(url);


                    debugPrint(

                      error.toString()

                    );





                    return _erroImagem(

                      "Erro ao carregar imagem",

                    );



                  },



                ),



              ),



            );



          },



        ),






        if(cavalo.fotos.length > 1)


          Positioned(



            right:20,

            bottom:20,




            child:


            Container(



              padding:


              const EdgeInsets.symmetric(


                horizontal:14,

                vertical:8,


              ),




              decoration:


              BoxDecoration(



                color:

                Colors.black54,



                borderRadius:


                BorderRadius.circular(30),



              ),





              child:


              Text(



                "${cavalo.fotos.length} fotos",




                style:


                const TextStyle(


                  color:

                  Colors.white,


                  fontWeight:

                  FontWeight.bold,


                ),



              ),




            ),



          ),




      ],



    );



  }








  Widget _erroImagem(String texto){


    return Container(



      color:

      Colors.grey.shade300,





      child:


      Center(



        child:


        Column(



          mainAxisAlignment:


          MainAxisAlignment.center,




          children:[



            const Icon(



              Icons.broken_image,

              size:70,


              color:

              Colors.grey,


            ),





            const SizedBox(

              height:12,

            ),






            Text(



              texto,



              style:


              const TextStyle(


                color:

                Colors.black54,


              ),



            ),




          ],



        ),



      ),



    );



  }

    Widget _descricao(){


    return Card(


      elevation:3,


      shape:


      RoundedRectangleBorder(


        borderRadius:


        BorderRadius.circular(20),


      ),




      child:


      Padding(


        padding:


        const EdgeInsets.all(18),




        child:


        Column(


          crossAxisAlignment:


          CrossAxisAlignment.start,



          children:[



            const Text(


              "Descrição",



              style:


              TextStyle(


                fontSize:20,


                fontWeight:


                FontWeight.bold,


              ),


            ),




            const SizedBox(


              height:10,


            ),




            Text(


              cavalo.descricao.trim().isEmpty

                  ?

              "Sem descrição cadastrada."

                  :

              cavalo.descricao,



              style:


              const TextStyle(


                fontSize:16,


                height:1.5,


              ),



            ),



          ],



        ),



      ),



    );


  }








  Widget _cardPrincipal(){


    return Card(


      elevation:5,


      shadowColor:

      Colors.black26,




      shape:


      RoundedRectangleBorder(


        borderRadius:


        BorderRadius.circular(25),


      ),




      child:


      Padding(


        padding:


        const EdgeInsets.all(20),




        child:


        Column(



          crossAxisAlignment:


          CrossAxisAlignment.start,



          children:[



            Text(



              cavalo.nome,



              style:


              const TextStyle(


                fontSize:28,


                fontWeight:


                FontWeight.bold,


              ),



            ),




            const SizedBox(


              height:10,


            ),





            Text(


              "R\$ ${cavalo.preco.toStringAsFixed(2)}",



              style:


              const TextStyle(


                fontSize:26,


                color:


                Color(0xFF5D4037),


                fontWeight:


                FontWeight.bold,


              ),



            ),




            const SizedBox(


              height:15,


            ),




            Chip(


              avatar:


              const Icon(


                Icons.pets,


                color:


                Color(0xFF5D4037),


              ),



              label:


              Text(


                cavalo.status.toUpperCase(),


              ),



            ),




          ],



        ),



      ),



    );


  }









  Widget _chip(


      IconData icon,


      String texto,


      ){



    return Chip(



      avatar:


      Icon(



        icon,


        size:18,


        color:


        const Color(0xFF5D4037),


      ),




      label:


      Text(



        texto.trim().isEmpty

            ?

        "Não informado"

            :

        texto,



      ),



    );



  }



}









// =======================================================
// TELA DE IMAGEM COMPLETA COM ZOOM
// =======================================================


class TelaImagem extends StatelessWidget {


  final String url;




  const TelaImagem({


    super.key,


    required this.url,


  });







  @override
  Widget build(BuildContext context){



    return Scaffold(



      backgroundColor:


      Colors.black,





      appBar:


      AppBar(



        backgroundColor:


        Colors.black,



        iconTheme:


        const IconThemeData(


          color:


          Colors.white,


        ),



      ),





      body:


      Center(



        child:


        InteractiveViewer(



          minScale:


          0.5,



          maxScale:


          5,





          child:


          Image.network(



            url,



            fit:


            BoxFit.contain,




            loadingBuilder:


            (
              context,
              child,
              loading
            ){



              if(loading == null){


                return child;


              }




              return const Center(



                child:


                CircularProgressIndicator(



                  color:


                  Colors.white,



                ),



              );


            },






            errorBuilder:


            (
              context,
              error,
              stack
            ){



              return Column(



                mainAxisAlignment:


                MainAxisAlignment.center,




                children:[



                  const Icon(



                    Icons.broken_image,


                    size:80,


                    color:


                    Colors.white,


                  ),





                  const SizedBox(


                    height:15,


                  ),





                  const Text(



                    "Imagem indisponível",



                    style:


                    TextStyle(


                      color:


                      Colors.white,


                      fontSize:18,


                    ),



                  ),




                  const SizedBox(


                    height:10,


                  ),




                  Text(



                    url,



                    textAlign:


                    TextAlign.center,



                    style:


                    const TextStyle(



                      color:


                      Colors.white70,


                      fontSize:12,


                    ),



                  ),



                ],



              );


            },



          ),



        ),



      ),



    );



  }



}