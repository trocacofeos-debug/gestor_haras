import 'package:flutter/material.dart';

import '../models/cavalo_model.dart';


class CavaloCard extends StatelessWidget {


final CavaloModel cavalo;


const CavaloCard({
super.key,
required this.cavalo, required Null Function() onTap,
});



@override
Widget build(BuildContext context){


return Card(

clipBehavior:
Clip.antiAlias,


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


],


),


);

}

}