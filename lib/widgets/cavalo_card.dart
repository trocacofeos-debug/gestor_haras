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


    return GestureDetector(


      behavior: HitTestBehavior.opaque,


      onTap: (){


        debugPrint(
          "CLICOU NO CAVALO: ${cavalo.nome}"
        );


        if(onTap != null){

          onTap!();

        }


      },



      child:

      Card(


        elevation:4,


        margin:

        const EdgeInsets.only(

          bottom:15,

        ),



        clipBehavior:

        Clip.antiAlias,



        shape:

        RoundedRectangleBorder(

          borderRadius:

          BorderRadius.circular(20),

        ),



        child:

        Column(


          children:[



            SizedBox(


              height:200,


              width:double.infinity,



              child:

              cavalo.fotos.isNotEmpty


                  ?

              Image.network(


                cavalo.fotos.first,


                fit:

                BoxFit.cover,



                errorBuilder:

                    (context,error,stack){


                  return const Center(

                    child:

                    Icon(

                      Icons.broken_image,

                      size:60,

                    ),

                  );


                },



              )



                  :


              const Center(

                child:

                Icon(

                  Icons.pets,

                  size:70,

                ),

              ),


            ),




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




                  const SizedBox(height:8),



                  Text(

                    cavalo.raca,

                  ),




                  const SizedBox(height:8),



                  Text(

                    "R\$ ${cavalo.preco.toStringAsFixed(2)}",

                    style:

                    const TextStyle(

                      fontSize:20,

                      fontWeight:

                      FontWeight.bold,

                    ),

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