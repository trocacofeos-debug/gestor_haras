import 'package:flutter/material.dart';

import '../../services/cavalo_service.dart';
import '../../widgets/cavalo_card.dart';
import 'detalhe_cavalo_page.dart';



class CavalosPage extends StatelessWidget {

  const CavalosPage({
    super.key,
  });



  @override
  Widget build(BuildContext context) {


    final service = CavaloService();



    return Scaffold(


      appBar: AppBar(

        title: const Text(
          "Cavalos Disponíveis",
        ),

      ),



      body: StreamBuilder(


        stream: service.listar(),



        builder: (context, snapshot) {



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

                    size:70,

                    color:Colors.grey,

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






            itemBuilder:

            (context,index){



              final cavalo =
                  cavalos[index];





              return Padding(


                padding:

                const EdgeInsets.only(

                  bottom:15,

                ),



                child:

                CavaloCard(


                  cavalo:
                  cavalo,



                  onTap:(){



                    Navigator.push(


                      context,


                      MaterialPageRoute(


                        builder:(_)=>


                            DetalheCavaloPage(


                              cavalo:
                              cavalo,


                            ),


                      ),


                    );


                  },


                ),


              );



            },


          );




        },


      ),


    );


  }


}