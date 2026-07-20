import 'package:flutter/material.dart';


import '../propostas/cliente/minhas_propostas_page.dart';

import '../perfil/perfil_cliente_page.dart';

import 'cliente_financeiro_page.dart';


// CAVALOS
import '../cavalos/cavalos_page.dart';



class ClienteHome extends StatefulWidget {


  const ClienteHome({
    super.key,
  });



  @override
  State<ClienteHome> createState() =>
      _ClienteHomeState();


}







class _ClienteHomeState
    extends State<ClienteHome> {



  int paginaAtual = 0;





  final paginas = const [


    ClienteFinanceiroPage(),


    CavalosPage(),


    PropostasClientePage(),


    PerfilClientePage(),



  ];








  @override
  Widget build(BuildContext context) {



    return Scaffold(



      body:

      paginas[paginaAtual],






      bottomNavigationBar:

      BottomNavigationBar(



        currentIndex:

        paginaAtual,





        type:

        BottomNavigationBarType.fixed,





        selectedItemColor:

        const Color(0xFF5D4037),





        unselectedItemColor:

        Colors.grey,






        onTap:(value){



          setState(() {



            paginaAtual = value;



          });



        },







        items:[






          const BottomNavigationBarItem(



            icon:

            Icon(

              Icons.account_balance_wallet,

            ),



            label:

            "Financeiro",



          ),







          const BottomNavigationBarItem(



            icon:

            Icon(

              Icons.pets,

            ),



            label:

            "Cavalos",



          ),







          const BottomNavigationBarItem(



            icon:

            Icon(

              Icons.description,

            ),



            label:

            "Propostas",



          ),







          const BottomNavigationBarItem(



            icon:

            Icon(

              Icons.person,

            ),



            label:

            "Perfil",



          ),






        ],




      ),



    );



  }



}