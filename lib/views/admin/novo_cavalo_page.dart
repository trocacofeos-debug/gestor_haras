import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../models/cavalo_model.dart';
import '../../services/cavalo_service.dart';
import '../../services/storage_service.dart';



class NovoCavaloPage extends StatefulWidget {

  const NovoCavaloPage({
    super.key,
  });


  @override
  State<NovoCavaloPage> createState() =>
      _NovoCavaloPageState();

}





class _NovoCavaloPageState
    extends State<NovoCavaloPage> {



  final _formKey =
      GlobalKey<FormState>();



  // ==========================
  // CAMPOS
  // ==========================


  final nome =
      TextEditingController();


  final raca =
      TextEditingController();


  final sexo =
      TextEditingController();


  final pelagem =
      TextEditingController();


  final registro =
      TextEditingController();


  final idade =
      TextEditingController();


  final descricao =
      TextEditingController();


  final preco =
      TextEditingController();





  final CavaloService service =
      CavaloService();



  final StorageService storage =
      StorageService();



  final ImagePicker picker =
      ImagePicker();





  // ==========================
  // IMAGENS
  // ==========================


  final List<Uint8List> imagens = [];



  bool salvando = false;



  String status = "";



  // ==========================
  // CONFIGURAÇÕES ANÚNCIO
  // ==========================


  bool destaqueSelecionado = false;


  bool vendidoSelecionado = false;






  @override
  void dispose() {


    nome.dispose();

    raca.dispose();

    sexo.dispose();

    pelagem.dispose();

    registro.dispose();

    idade.dispose();

    descricao.dispose();

    preco.dispose();


    super.dispose();

  }







  // ==========================
  // SELECIONAR FOTOS
  // ==========================


  Future<void> selecionarFotos() async {


    try {


      final arquivos =
          await picker.pickMultiImage(

        imageQuality:
            80,

      );



      if (arquivos.isEmpty) {
        return;
      }



      for (final arquivo in arquivos) {


        final bytes =
            await arquivo.readAsBytes();


        imagens.add(bytes);


      }



      if (!mounted) return;


      setState(() {});



    } catch (e) {


      if (!mounted) return;


      ScaffoldMessenger.of(context)
          .showSnackBar(

        SnackBar(

          content:
              Text(
            "Erro ao selecionar fotos: $e",
          ),

        ),

      );


    }


  }







  // ==========================
  // SALVAR CAVALO
  // ==========================


  Future<void> salvar() async {


    if (!_formKey.currentState!.validate()) {

      return;

    }





    if (imagens.isEmpty) {


      ScaffoldMessenger.of(context)
          .showSnackBar(

        const SnackBar(

          content:
              Text(
            "Selecione pelo menos uma foto",
          ),

        ),

      );


      return;

    }





    setState(() {


      salvando = true;


      status =
          "Enviando imagens para Cloudflare R2...";


    });





    try {



      final fotos =
          await storage.uploadMultiplasImagens(
        imagens,
      );





      if (fotos.isEmpty) {


        throw Exception(
          "Nenhuma imagem retornada pelo servidor",
        );


      }






      setState(() {


        status =
            "Fotos enviadas. Salvando cavalo...";


      });






      final cavalo =
          CavaloModel(


        nome:
            nome.text.trim(),



        raca:
            raca.text.trim(),



        sexo:
            sexo.text.trim(),



        pelagem:
            pelagem.text.trim(),



        registro:
            registro.text.trim(),



        idade:
            int.tryParse(
              idade.text.trim(),
            ) ??
            0,



        descricao:
            descricao.text.trim(),



        preco:
            double.tryParse(
              preco.text.replaceAll(",", "."),
            ) ??
            0,



        status:

            vendidoSelecionado

                ? "vendido"

                : "disponivel",





        fotos:
            fotos,





        // CAMPOS OBRIGATÓRIOS
        destaque:
            destaqueSelecionado,



        vendido:
            vendidoSelecionado,



        fotoPrincipal:
            fotos.first,


      );






      await service.criar(
        cavalo,
      );






      if (!mounted) return;




      ScaffoldMessenger.of(context)
          .showSnackBar(

        const SnackBar(

          content:
              Text(
            "Cavalo cadastrado com sucesso 🐎",
          ),

        ),

      );





      Navigator.pop(context);




    } catch (e) {



      if (!mounted) return;



      ScaffoldMessenger.of(context)
          .showSnackBar(

        SnackBar(

          content:
              Text(
            "Erro ao cadastrar:\n$e",
          ),

        ),

      );



    } finally {



      if (mounted) {


        setState(() {


          salvando = false;


          status = "";


        });


      }


    }



  }

  
  // ==========================
  // BUILD
  // ==========================


  @override
  Widget build(BuildContext context) {


    return Scaffold(


      backgroundColor:
          const Color(0xffF7F4F0),




      appBar:

      AppBar(


        title:

            const Text(
          "Cadastrar Cavalo",
        ),



        backgroundColor:

            const Color(0xFF5D4037),



        foregroundColor:

            Colors.white,



        elevation:

            0,


      ),





      body:


      SingleChildScrollView(



        padding:

            const EdgeInsets.all(16),




        child:


        Form(



          key:

              _formKey,




          child:


          Column(



            children: [





              // ==========================
              // CABEÇALHO
              // ==========================


              Container(



                width:

                    double.infinity,




                padding:

                    const EdgeInsets.all(20),




                decoration:


                    BoxDecoration(



                  color:

                      const Color(0xFF5D4037),




                  borderRadius:

                      BorderRadius.circular(24),





                  boxShadow: [



                    BoxShadow(


                      color:

                          Colors.black.withValues(
                            alpha: .15,
                          ),



                      blurRadius:

                          12,



                      offset:

                          const Offset(0,6),


                    ),


                  ],


                ),





                child:


                const Row(



                  children: [




                    Icon(



                      Icons.pets,



                      color:

                          Colors.white,



                      size:

                          45,


                    ),





                    SizedBox(

                      width:

                          15,

                    ),






                    Expanded(



                      child:


                      Column(



                        crossAxisAlignment:

                            CrossAxisAlignment.start,




                        children: [




                          Text(



                            "Novo Cavalo",




                            style:


                            TextStyle(



                              color:

                                  Colors.white,



                              fontSize:

                                  22,



                              fontWeight:

                                  FontWeight.bold,


                            ),



                          ),





                          SizedBox(

                            height:

                                5,

                          ),






                          Text(



                            "Cadastre um animal no haras",




                            style:


                            TextStyle(



                              color:

                                  Colors.white70,


                            ),



                          ),




                        ],



                      ),



                    ),




                  ],



                ),




              ),






              const SizedBox(

                height:

                    20,

              ),







              // ==========================
              // DADOS DO CAVALO
              // ==========================



              _secao(



                titulo:

                    "Dados do Cavalo",




                icon:

                    Icons.pets,




                child:


                Column(



                  children: [



                    campo(

                      "Nome",

                      nome,

                      Icons.pets,

                    ),




                    campo(

                      "Raça",

                      raca,

                      Icons.category,

                    ),




                    campo(

                      "Sexo",

                      sexo,

                      Icons.male,

                    ),




                    campo(

                      "Pelagem",

                      pelagem,

                      Icons.color_lens,

                    ),




                    campo(

                      "Registro",

                      registro,

                      Icons.badge,

                    ),




                    campo(



                      "Idade",




                      idade,




                      Icons.calendar_month,




                      teclado:

                          TextInputType.number,


                    ),



                  ],



                ),



              ),






              const SizedBox(

                height:

                    16,

              ),







              // ==========================
              // COMERCIAL
              // ==========================


              _secao(



                titulo:

                    "Informações Comerciais",




                icon:

                    Icons.attach_money,





                child:


                Column(



                  children: [




                    campo(



                      "Preço",



                      preco,



                      Icons.money,




                      teclado:

                          TextInputType.number,


                    ),






                    campo(



                      "Descrição",




                      descricao,



                      Icons.description,




                      linhas:

                          4,



                    ),





                  ],



                ),



              ),






              const SizedBox(

                height:

                    16,

              ),







              // ==========================
              // CONFIGURAÇÃO DO ANÚNCIO
              // ==========================


              _secao(



                titulo:

                    "Configurações do anúncio",




                icon:

                    Icons.settings,




                child:


                Column(



                  children: [






                    SwitchListTile(



                      contentPadding:

                          EdgeInsets.zero,




                      title:

                          const Text(

                        "Cavalo em destaque",

                      ),





                      subtitle:

                          const Text(

                        "Aparece na área premium do site",

                      ),






                      value:

                          destaqueSelecionado,







                      activeThumbColor:

                          const Color(
                            0xFF5D4037,
                          ),







                      onChanged:

                          salvando

                              ? null

                              : (valor) {


                                  setState(() {


                                    destaqueSelecionado =
                                        valor;


                                  });


                                },



                    ),







                    SwitchListTile(



                      contentPadding:

                          EdgeInsets.zero,




                      title:

                          const Text(

                        "Cavalo vendido",

                      ),





                      subtitle:

                          const Text(

                        "Remove da lista disponível",

                      ),





                      value:

                          vendidoSelecionado,







                      activeThumbColor:

                          Colors.red,







                      onChanged:

                          salvando

                              ? null

                              : (valor) {



                                  setState(() {


                                    vendidoSelecionado =
                                        valor;



                                  });



                                },




                    ),





                  ],



                ),



              ),





              const SizedBox(

                height:

                    16,

              ),

                            // ==========================
              // FOTOS
              // ==========================


              _secao(

                titulo:
                    "Fotos do Cavalo",

                icon:
                    Icons.photo_library,


                child:

                Column(

                  children: [


                    SizedBox(

                      width:
                          double.infinity,


                      child:

                      ElevatedButton.icon(


                        icon:

                        const Icon(
                          Icons.add_a_photo,
                        ),



                        label:

                        const Text(
                          "Selecionar Fotos",
                        ),



                        style:

                        ElevatedButton.styleFrom(


                          backgroundColor:
                              const Color(0xFF5D4037),


                          foregroundColor:
                              Colors.white,


                          padding:

                              const EdgeInsets.symmetric(
                            vertical: 14,
                          ),


                          shape:

                          RoundedRectangleBorder(

                            borderRadius:

                            BorderRadius.circular(
                              15,
                            ),

                          ),

                        ),



                        onPressed:

                        salvando

                            ? null

                            :

                        selecionarFotos,



                      ),

                    ),





                    const SizedBox(

                      height:
                          15,

                    ),






                    if (imagens.isEmpty)

                      Container(

                        width:

                            double.infinity,


                        padding:

                            const EdgeInsets.all(
                          25,
                        ),



                        decoration:

                        BoxDecoration(


                          color:

                              Colors.grey.shade100,


                          borderRadius:

                          BorderRadius.circular(
                            15,
                          ),

                        ),



                        child:

                        const Column(

                          children: [


                            Icon(

                              Icons.image_outlined,

                              size:

                                  45,

                              color:

                                  Colors.grey,

                            ),



                            SizedBox(

                              height:

                                  10,

                            ),




                            Text(

                              "Nenhuma foto selecionada",

                            ),



                          ],

                        ),


                      ),







                    Wrap(

                      spacing:

                          10,


                      runSpacing:

                          10,



                      children:

                      imagens.map((img) {


                        return Stack(


                          children: [




                            ClipRRect(


                              borderRadius:

                              BorderRadius.circular(
                                15,
                              ),



                              child:

                              Image.memory(


                                img,


                                width:

                                    110,


                                height:

                                    110,


                                fit:

                                    BoxFit.cover,


                              ),



                            ),







                            Positioned(



                              right:

                                  0,



                              top:

                                  0,




                              child:

                              InkWell(


                                onTap:

                                salvando

                                    ? null

                                    :

                                () {


                                  setState(() {


                                    imagens.remove(img);


                                  });


                                },



                                child:

                                const CircleAvatar(



                                  radius:

                                      14,



                                  backgroundColor:

                                      Colors.red,



                                  child:

                                  Icon(


                                    Icons.close,


                                    size:

                                        16,


                                    color:

                                        Colors.white,

                                  ),



                                ),



                              ),



                            ),




                          ],



                        );


                      }).toList(),



                    ),



                  ],


                ),


              ),






              const SizedBox(

                height:

                    20,

              ),







              if (status.isNotEmpty)

                Container(

                  width:

                      double.infinity,


                  padding:

                      const EdgeInsets.all(
                    12,
                  ),



                  decoration:

                  BoxDecoration(


                    color:

                        Colors.orange.shade100,


                    borderRadius:

                    BorderRadius.circular(
                      12,
                    ),


                  ),



                  child:

                  Text(



                    status,



                    textAlign:

                        TextAlign.center,



                    style:

                    const TextStyle(



                      fontWeight:

                          FontWeight.bold,


                    ),



                  ),



                ),






              const SizedBox(

                height:

                    20,

              ),







              SizedBox(



                width:

                    double.infinity,



                height:

                    55,




                child:

                ElevatedButton.icon(



                  icon:



                  salvando


                      ?


                  const SizedBox(


                    width:

                        22,


                    height:

                        22,



                    child:

                    CircularProgressIndicator(



                      color:

                          Colors.white,



                      strokeWidth:

                          2,


                    ),



                  )



                      :



                  const Icon(

                    Icons.save,

                  ),





                  label:

                  Text(



                    salvando


                        ?


                    "Enviando..."


                        :


                    "Cadastrar Cavalo",



                  ),






                  style:

                  ElevatedButton.styleFrom(



                    backgroundColor:

                        const Color(
                          0xFF5D4037,
                        ),



                    foregroundColor:

                        Colors.white,



                    shape:

                    RoundedRectangleBorder(



                      borderRadius:

                      BorderRadius.circular(
                        15,
                      ),



                    ),



                  ),





                  onPressed:


                  salvando

                      ? null

                      :

                  salvar,



                ),



              ),



            ],


          ),


        ),


      ),


    );


  }

    // ==========================
  // CAMPO INPUT
  // ==========================

  Widget campo(
    String label,
    TextEditingController controller,
    IconData icon, {
    TextInputType? teclado,
    int linhas = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 12,
      ),

      child: TextFormField(

        controller: controller,

        keyboardType: teclado,

        maxLines: linhas,


        decoration: InputDecoration(

          labelText: label,

          prefixIcon:

          Icon(
            icon,
            color: const Color(0xFF5D4037),
          ),


          filled: true,

          fillColor:
              Colors.white,


          border:

          OutlineInputBorder(

            borderRadius:

            BorderRadius.circular(
              15,
            ),


            borderSide:
                BorderSide.none,

          ),


        ),



        validator: (value) {


          if (value == null ||
              value.trim().isEmpty) {


            return "Informe $label";


          }


          return null;


        },


      ),

    );

  }







  // ==========================
  // CARD DE SEÇÃO
  // ==========================

  Widget _secao({

    required String titulo,

    required IconData icon,

    required Widget child,

  }) {


    return Card(


      elevation:

          3,


      shadowColor:

          Colors.black12,



      shape:

      RoundedRectangleBorder(


        borderRadius:

        BorderRadius.circular(
          22,
        ),


      ),




      child:

      Padding(


        padding:

        const EdgeInsets.all(
          18,
        ),



        child:

        Column(



          crossAxisAlignment:

          CrossAxisAlignment.start,




          children: [




            Row(



              children: [




                Container(



                  padding:

                  const EdgeInsets.all(
                    8,
                  ),




                  decoration:

                  BoxDecoration(



                    color:

                    const Color(
                      0xFF5D4037,
                    ).withValues(
                      alpha: .10,
                    ),



                    borderRadius:

                    BorderRadius.circular(
                      12,
                    ),



                  ),





                  child:

                  Icon(


                    icon,


                    color:

                    const Color(
                      0xFF5D4037,
                    ),


                  ),




                ),





                const SizedBox(

                  width:

                  10,

                ),





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




              ],



            ),






            const SizedBox(

              height:

              16,

            ),





            child,




          ],



        ),



      ),



    );

  }
    }