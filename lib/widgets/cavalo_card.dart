import 'package:flutter/material.dart';

import '../models/cavalo_model.dart';


class CavaloCard extends StatelessWidget {


  final CavaloModel cavalo;


  final VoidCallback? onTap;



  const CavaloCard({

    super.key,

    required this.cavalo,

    this.onTap,

  });





  @override
  Widget build(BuildContext context){



    return InkWell(


      onTap:
      onTap,


      borderRadius:
      BorderRadius.circular(20),



      child:

      Card(


        elevation:
        4,


        clipBehavior:
        Clip.antiAlias,


        shape:

        RoundedRectangleBorder(

          borderRadius:

          BorderRadius.circular(20),

        ),




        child:

        Column(



          crossAxisAlignment:

          CrossAxisAlignment.start,



          children:[





            // =========================
            // IMAGEM
            // =========================


            SizedBox(


              height:
              200,


              width:
              double.infinity,



              child:


              cavalo.fotos.isNotEmpty


                  ?


              Image.network(



                cavalo.fotos.first,



                fit:
                BoxFit.cover,



                loadingBuilder:

                    (context,child,loading){



                  if(loading == null){

                    return child;

                  }



                  return const Center(

                    child:

                    CircularProgressIndicator(),

                  );


                },



                errorBuilder:

                    (context,error,stack){



                  return Container(


                    color:
                    Colors.grey.shade300,



                    child:

                    const Center(

                      child:

                      Icon(

                        Icons.broken_image,

                        size:60,

                      ),

                    ),


                  );


                },


              )



                  :



              Container(


                color:
                Colors.grey.shade300,



                child:

                const Center(

                  child:

                  Icon(

                    Icons.pets,

                    size:70,

                  ),

                ),


              ),



            ),







            // =========================
            // INFORMAÇÕES
            // =========================



            Padding(


              padding:

              const EdgeInsets.all(16),



              child:

              Column(



                crossAxisAlignment:

                CrossAxisAlignment.start,



                children:[





                  Text(



                    cavalo.nome,



                    style:

                    const TextStyle(



                      fontSize:22,


                      fontWeight:

                      FontWeight.bold,


                    ),



                  ),







                  const SizedBox(

                    height:8,

                  ),







                  Text(


                    cavalo.raca.isEmpty

                        ?

                    "Raça não informada"

                        :

                    cavalo.raca,



                    style:

                    const TextStyle(


                      color:

                      Colors.grey,


                    ),



                  ),







                  const SizedBox(

                    height:8,

                  ),







                  Text(



                    "R\$ ${cavalo.preco.toStringAsFixed(2)}",



                    style:

                    const TextStyle(



                      fontSize:20,


                      fontWeight:

                      FontWeight.bold,



                      color:

                      Color(0xFF5D4037),



                    ),



                  ),







                  const SizedBox(

                    height:8,

                  ),





                  Row(



                    children:[



                      const Icon(

                        Icons.pets,

                        size:18,

                      ),




                      const SizedBox(

                        width:6,

                      ),





                      Text(



                        cavalo.status.toUpperCase(),



                        style:

                        const TextStyle(



                          fontWeight:

                          FontWeight.bold,



                        ),



                      ),




                    ],



                  ),





                ],



              ),



            ),





          ],



        ),



      ),



    );


  }



}