import 'package:flutter/material.dart';

import '../../services/cavalo_service.dart';
import '../../models/cavalo_model.dart';

import '../cavalos/detalhe_cavalo_page.dart';



class AdminCavalosPage extends StatelessWidget {


  const AdminCavalosPage({
    super.key,
  });



  @override
  Widget build(BuildContext context) {


    final service =
        CavaloService();



    return Scaffold(


      appBar: AppBar(

        title:

        const Text(
          "Gerenciar Cavalos",
        ),

      ),





      floatingActionButton:

      FloatingActionButton.extended(


        icon:

        const Icon(
          Icons.add,
        ),



        label:

        const Text(
          "Novo Cavalo",
        ),




        onPressed: () {



          Navigator.pushNamed(

            context,

            "/novo-cavalo",

          );



        },


      ),







      body:

      StreamBuilder<List<CavaloModel>>(



        stream:

        service.listar(),





        builder:(context,snapshot){





          if(snapshot.connectionState ==

              ConnectionState.waiting){



            return const Center(

              child:

              CircularProgressIndicator(),

            );


          }






          if(snapshot.hasError){


            return Center(


              child:

              Text(

                "Erro ao carregar cavalos\n${snapshot.error}",

              ),


            );


          }







          final cavalos =

              snapshot.data ?? [];







          if(cavalos.isEmpty){



            return const Center(


              child:

              Column(

                mainAxisAlignment:

                MainAxisAlignment.center,


                children:[



                  Icon(

                    Icons.pets,

                    size:80,

                    color:
                    Colors.grey,

                  ),



                  SizedBox(

                    height:15,

                  ),




                  Text(

                    "Nenhum cavalo cadastrado",

                    style:

                    TextStyle(

                      fontSize:18,

                    ),

                  ),



                ],



              ),


            );



          }








          return ListView.builder(



            padding:

            const EdgeInsets.all(16),





            itemCount:

            cavalos.length,






            itemBuilder:(context,index){



              final cavalo =

              cavalos[index];







              return Card(



                elevation:

                3,



                margin:

                const EdgeInsets.only(

                  bottom:15,

                ),




                shape:

                RoundedRectangleBorder(

                  borderRadius:

                  BorderRadius.circular(18),

                ),







                child:

                InkWell(



                  borderRadius:

                  BorderRadius.circular(18),





                  onTap:(){





                    Navigator.push(



                      context,



                      MaterialPageRoute(



                        builder:(context)=>



                            DetalheCavaloPage(



                              cavalo:

                              cavalo,



                            ),



                      ),



                    );




                  },







                  child:

                  Padding(



                    padding:

                    const EdgeInsets.all(12),





                    child:

                    Row(



                      children:[





                        ClipRRect(



                          borderRadius:

                          BorderRadius.circular(15),






                          child:



                          cavalo.fotos.isNotEmpty



                              ?



                          Image.network(



                            cavalo.fotos.first,



                            width:

                            90,



                            height:

                            90,



                            fit:

                            BoxFit.cover,



                            errorBuilder:

                                (context,error,stackTrace){



                              return const Icon(

                                Icons.image_not_supported,

                                size:60,

                              );



                            },



                          )



                              :



                          Container(



                            width:

                            90,



                            height:

                            90,



                            decoration:

                            BoxDecoration(

                              color:

                              Colors.grey.shade200,

                              borderRadius:

                              BorderRadius.circular(15),

                            ),



                            child:

                            const Icon(

                              Icons.pets,

                              size:45,

                            ),



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



                            children:[






                              Text(



                                cavalo.nome,



                                style:

                                const TextStyle(



                                  fontSize:18,



                                  fontWeight:

                                  FontWeight.bold,



                                ),



                              ),






                              const SizedBox(

                                height:5,

                              ),





                              Text(



                                cavalo.raca,



                                style:

                                TextStyle(

                                  color:

                                  Colors.grey.shade700,

                                ),



                              ),






                              const SizedBox(

                                height:8,

                              ),






                              Text(



                                "R\$ ${cavalo.preco.toStringAsFixed(2)}",



                                style:

                                const TextStyle(



                                  color:

                                  Colors.green,



                                  fontSize:16,



                                  fontWeight:

                                  FontWeight.bold,



                                ),



                              ),




                            ],



                          ),



                        ),







                        const Icon(

                          Icons.arrow_forward_ios,

                          size:18,

                        ),





                      ],



                    ),



                  ),



                ),



              );





            },



          );




        },



      ),



    );



  }



}