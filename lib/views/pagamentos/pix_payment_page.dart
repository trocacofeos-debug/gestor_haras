import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';


class PixPaymentPage extends StatefulWidget {


  final double valor;

  final String descricao;



  const PixPaymentPage({

    super.key,

    required this.valor,

    required this.descricao,

  });



  @override
  State<PixPaymentPage> createState() =>
      _PixPaymentPageState();

}






class _PixPaymentPageState
    extends State<PixPaymentPage> {



  static const String chavePix =
      'haras.sg@hotmail.com';



  late String pixCodigo;






  @override
  void initState(){

    super.initState();


    pixCodigo =
        gerarPixPayload(

      chave:
          chavePix,


      valor:
          widget.valor,


      descricao:
          widget.descricao,


    );

  }






  // =====================================================
  // GERAR PIX COPIA E COLA
  // =====================================================


  String campo(
      String id,
      String valor,
      ){

    return
        id +

        valor.length
            .toString()
            .padLeft(2,'0') +

        valor;

  }







  String gerarPixPayload({

    required String chave,

    required double valor,

    required String descricao,

  }) {



    final merchantAccount =



        campo(

          "00",

          "BR.GOV.BCB.PIX",

        )

        +

        campo(

          "01",

          chave,

        );








    final payloadSemCrc =



        campo(

          "00",

          "01",

        )

        +



        campo(

          "26",

          merchantAccount,

        )

        +



        campo(

          "52",

          "0000",

        )

        +



        campo(

          "53",

          "986",

        )

        +



        campo(

          "54",

          valor.toStringAsFixed(2),

        )

        +



        campo(

          "58",

          "BR",

        )

        +



        campo(

          "59",

          "GESTOR HARAS",

        )

        +



        campo(

          "60",

          "NITEROI",

        )

        +



        // ignore: prefer_interpolation_to_compose_strings
        campo(

          "62",

          campo(

            "05",

            descricao.length > 25

                ? descricao.substring(0,25)

                : descricao,

          ),

        )

        +



        "6304";






    final crc =
        calcularCRC16(
          payloadSemCrc,
        );




    return

        payloadSemCrc +

        crc;


  }








  String calcularCRC16(
      String texto
      ){



    int crc =
        0xFFFF;





    for(final c in texto.codeUnits){



      crc ^= c << 8;




      for(int i = 0; i < 8; i++){



        if((crc & 0x8000) != 0){


          crc =
              (crc << 1) ^ 0x1021;


        }else{


          crc <<= 1;


        }



        crc &= 0xFFFF;



      }


    }






    return crc

        .toRadixString(16)

        .toUpperCase()

        .padLeft(
          4,
          '0',
        );


  }









  Future<void> copiarPix() async {



    await Clipboard.setData(

      ClipboardData(

        text:
            pixCodigo,

      ),

    );





    if(!mounted) return;





    ScaffoldMessenger.of(context)
        .showSnackBar(



      const SnackBar(

        content:

            Text(

              'PIX Copia e Cola copiado!',

            ),

      ),


    );


  }









  @override
  Widget build(BuildContext context) {



    return Scaffold(



      backgroundColor:
          const Color(0xFFF4F6FA),




      appBar:
          AppBar(



        title:
            const Text(
              'Pagamento PIX',
            ),



        backgroundColor:
            Colors.green,



        foregroundColor:
            Colors.white,



      ),







      body:
          SingleChildScrollView(



        padding:
            const EdgeInsets.all(20),





        child:
            Column(



          children: [







            const Icon(

              Icons.pix,

              size:
                  80,

              color:
                  Colors.green,

            ),






            const SizedBox(
              height:20,
            ),






            Text(



              widget.descricao,



              textAlign:
                  TextAlign.center,



              style:
                  const TextStyle(



                fontSize:
                    20,



                fontWeight:
                    FontWeight.bold,



              ),



            ),








            const SizedBox(
              height:10,
            ),







            Text(

              'Valor da parcela',

              style:

                  TextStyle(

                color:
                    Colors.grey.shade700,

              ),

            ),








            const SizedBox(
              height:6,
            ),








            Text(



              'R\$ ${widget.valor.toStringAsFixed(2)}',




              style:
                  const TextStyle(



                fontSize:
                    30,



                fontWeight:
                    FontWeight.bold,



                color:
                    Colors.green,



              ),



            ),







            const SizedBox(
              height:30,
            ),









            Card(



              elevation:
                  4,



              child:
                  Padding(



                padding:
                    const EdgeInsets.all(16),




                child:
                    QrImageView(



                  data:
                      pixCodigo,



                  size:
                      260,



                ),



              ),



            ),








            const SizedBox(
              height:20,
            ),








            const Text(



              'Escaneie o QR Code usando o aplicativo do banco.',



              textAlign:
                  TextAlign.center,



            ),









            const SizedBox(
              height:25,
            ),







            Container(



              width:
                  double.infinity,



              padding:
                  const EdgeInsets.all(16),




              decoration:
                  BoxDecoration(



                color:
                    Colors.white,



                borderRadius:
                    BorderRadius.circular(12),




                border:
                    Border.all(

                  color:
                      Colors.grey.shade300,

                ),



              ),





              child:
                  Column(



                children:[






                  const Text(



                    'PIX Copia e Cola',



                    style:
                        TextStyle(



                      fontWeight:
                          FontWeight.bold,



                    ),



                  ),







                  const SizedBox(
                    height:8,
                  ),








                  SelectableText(



                    pixCodigo,



                    textAlign:
                        TextAlign.center,



                    style:
                        const TextStyle(

                      fontSize:
                          12,

                    ),



                  ),



                ],



              ),



            ),









            const SizedBox(
              height:25,
            ),







            SizedBox(



              width:
                  double.infinity,



              child:
                  ElevatedButton.icon(



                onPressed:
                    copiarPix,



                icon:
                    const Icon(
                      Icons.copy,
                    ),



                label:
                    const Text(
                      'Copiar PIX Copia e Cola',
                    ),





                style:
                    ElevatedButton.styleFrom(



                  backgroundColor:
                      Colors.green,



                  foregroundColor:
                      Colors.white,



                  padding:
                      const EdgeInsets.symmetric(

                    vertical:
                        14,

                  ),



                ),



              ),



            ),









            const SizedBox(
              height:10,
            ),









            const Text(



              'Após o pagamento, o administrador poderá confirmar a baixa da parcela.',



              textAlign:
                  TextAlign.center,



              style:
                  TextStyle(



                fontSize:
                    12,



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