// ignore_for_file: avoid_print

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http_parser/http_parser.dart';


class CloudflareR2Service {


  CloudflareR2Service();



  final Dio _dio = Dio(

    BaseOptions(

      connectTimeout:
          const Duration(minutes: 2),

      sendTimeout:
          const Duration(minutes: 5),

      receiveTimeout:
          const Duration(minutes: 5),

      responseType:
          ResponseType.json,

      headers: {

        "Accept":
            "application/json",

      },

    ),

  );






  // =====================================================
  // API VERCEL
  // =====================================================


  static const String uploadEndpoint =

      "https://gestor-haras-app-one.vercel.app/api/upload";







  // =====================================================
  // DETECTAR TIPO DO ARQUIVO
  // =====================================================


  MediaType descobrirMime(String nome){


    final arquivo =
        nome.toLowerCase();



    if(arquivo.endsWith(".pdf")){

      return MediaType(
        "application",
        "pdf",
      );

    }



    if(
      arquivo.endsWith(".jpg") ||
      arquivo.endsWith(".jpeg")
    ){

      return MediaType(
        "image",
        "jpeg",
      );

    }



    if(arquivo.endsWith(".png")){

      return MediaType(
        "image",
        "png",
      );

    }



    return MediaType(
      "application",
      "octet-stream",
    );


  }








  // =====================================================
  // UPLOAD ÚNICO
  // =====================================================


  Future<String> uploadArquivo({


    required PlatformFile arquivo,


    required String pasta,


  }) async {


    try {



      if(arquivo.bytes == null){


        throw Exception(

          "Arquivo sem dados. Gere novamente o arquivo.",

        );


      }



      if(arquivo.bytes!.isEmpty){


        throw Exception(

          "Arquivo vazio.",

        );


      }





      final mime =

          descobrirMime(
            arquivo.name,
          );







      final formData = FormData.fromMap({



        "file": MultipartFile.fromBytes(



          arquivo.bytes!,



          filename:
              arquivo.name,



          contentType:
              mime,



        ),






        "pasta":

            pasta,



      });








      final response = await _dio.post(



        uploadEndpoint,



        data:
            formData,



      );








      if(response.statusCode == 200){



        final data =
            response.data;





        if(
          data is Map &&

          data["sucesso"] == true &&

          data["url"] != null

        ){



          return data["url"]
              .toString();



        }







        throw Exception(

          data["erro"] ??

          "Upload realizado mas URL não retornada",

        );



      }







      throw Exception(

        "Erro HTTP ${response.statusCode}",

      );






    }






    on DioException catch(e){



      print(
        "ERRO UPLOAD R2:"
      );


      print(
        e.message
      );





      if(e.response != null){


        throw Exception(

          "Erro servidor: "
          "${e.response?.statusCode}\n"
          "${e.response?.data}",

        );


      }







      throw Exception(

        "Falha conexão upload: "
        "${e.message}",

      );





    }






    catch(e){


      throw Exception(

        "Erro upload arquivo: $e",

      );


    }



  }









  // =====================================================
  // MULTIPLOS ARQUIVOS
  // =====================================================


  Future<List<String>> uploadMultiplosArquivos({


    required List<PlatformFile> arquivos,


    required String pasta,


  }) async {



    final urls =
        <String>[];




    for(final arquivo in arquivos){


      final url =
          await uploadArquivo(

            arquivo:
                arquivo,

            pasta:
                pasta,

          );


      urls.add(url);


    }



    return urls;


  }









  // =====================================================
  // EXCLUIR ARQUIVO
  // =====================================================


  Future<bool> excluirArquivo({


    required String arquivoUrl,


  }) async {


    try {



      final response =
          await _dio.delete(



        uploadEndpoint,



        queryParameters:{


          "url":
              arquivoUrl,


        },


      );





      return response.statusCode == 200;





    }catch(e){



      print(
        "Erro excluir R2: $e"
      );


      return false;


    }


  }




}