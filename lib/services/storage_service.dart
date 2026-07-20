// ignore_for_file: avoid_print

import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';



class StorageService {


  final Dio dio = Dio();



  static const String uploadUrl =
      "https://gestor-haras-app-one.vercel.app/api/upload";





  Future<String?> uploadImagem(

      Uint8List bytes,

      String nomeArquivo,

      ) async {


    try {



      final mimeType =
          lookupMimeType(nomeArquivo)
              ??
          "image/jpeg";





      final multipart =

      MultipartFile.fromBytes(

        bytes,


        filename:
        nomeArquivo,


        contentType:

        MediaType.parse(
          mimeType,
        ),


      );







      final formData =

      FormData.fromMap({



        // IMPORTANTE
        // FastAPI espera "file"
        "file":

        multipart,



        // opcional
        "pasta":

        "cavalos",


      });








      final response =

      await dio.post(


        uploadUrl,


        data:

        formData,



        options:

        Options(


          headers:{


            "Accept":

            "application/json",



          },



          validateStatus:

              (status){


            return status != null &&
                status < 500;


          },


        ),



      );







      print(
          "STATUS R2: ${response.statusCode}"
      );



      print(
          "RESPOSTA R2: ${response.data}"
      );







      if(response.statusCode == 200){



        final data =
        response.data;



        if(data is Map &&

            data["url"] != null){



          return

          data["url"].toString();



        }



      }







      return null;




    }

    catch(e){



      print(

        "ERRO UPLOAD R2: $e",

      );



      return null;



    }



  }









  Future<List<String>>

  uploadMultiplasImagens(

      List<Uint8List> imagens,

      ) async {



    final List<String> urls = [];





    for(int i = 0;

    i < imagens.length;

    i++){






      final url =

      await uploadImagem(


        imagens[i],



        "cavalo_${DateTime.now().millisecondsSinceEpoch}_$i.jpg",


      );







      if(url != null){


        urls.add(url);


      }



    }







    return urls;



  }




}