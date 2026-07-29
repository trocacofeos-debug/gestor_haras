// ignore_for_file: deprecated_member_use

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../models/cavalo_model.dart';
import '../models/despesa_cavalo_model.dart';


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


    return Card(

      clipBehavior:
      Clip.antiAlias,


      child: InkWell(

        onTap: onTap,

        child: Column(

          children:[


            if(cavalo.fotos.isNotEmpty)

              Image.network(

                cavalo.fotos.first,

                height:180,

                width:double.infinity,

                fit:BoxFit.cover,

              ),



            ListTile(

              title:
              Text(
                cavalo.nome,
                style:
                const TextStyle(
                  fontWeight:
                  FontWeight.bold,
                ),
              ),


              subtitle:
              Text(
                "${cavalo.raca}\nR\$ ${cavalo.preco.toStringAsFixed(2)}",
              ),


            ),


            Padding(

              padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),

              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(

                stream: FirebaseFirestore.instance
                    .collection('cavalos')
                    .doc(cavalo.id)
                    .collection('despesas')
                    .snapshots(),

                builder: (context, snapshot) {

                  final total = (snapshot.data?.docs ?? [])
                      .map(
                        (doc) => DespesaCavaloModel.fromMap(
                          doc.data(),
                          doc.id,
                        ),
                      )
                      .fold<double>(
                        0,
                        (soma, d) => soma + d.valor,
                      );

                  return Container(

                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),

                    decoration: BoxDecoration(

                      color: Colors.red.withOpacity(.08),

                      borderRadius: BorderRadius.circular(10),

                    ),

                    child: Row(

                      mainAxisSize: MainAxisSize.min,

                      children: [

                        const Icon(
                          Icons.receipt_long_rounded,
                          size: 16,
                          color: Colors.redAccent,
                        ),

                        const SizedBox(width: 6),

                        Text(

                          "Despesas: R\$ ${total.toStringAsFixed(2)}",

                          style: const TextStyle(

                            color: Colors.redAccent,
                            fontWeight: FontWeight.bold,
                            fontSize: 12.5,

                          ),

                        ),

                      ],

                    ),

                  );

                },

              ),

            ),


          ],


        ),

      ),


    );

  }

}