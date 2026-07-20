import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';


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
  // UPLOAD ÚNICO
  // =====================================================


  Future<String> uploadArquivo({


    required PlatformFile arquivo,


    required String pasta,


  }) async {



    try {



      if(arquivo.bytes == null){


        throw Exception(

          "Arquivo sem dados. Selecione novamente.",

        );


      }






      final formData = FormData.fromMap({



        "file": MultipartFile.fromBytes(


          arquivo.bytes!,


          filename:
              arquivo.name,


        ),






        "pasta": pasta,



      });









      final response = await _dio.post(



        uploadEndpoint,



        data: formData,



      );








      if(response.statusCode == 200){



        final data = response.data;





        if(data is Map &&

            data["sucesso"] == true &&

            data["url"] != null){



          return data["url"].toString();



        }





        throw Exception(

          data["erro"] ??

          "API retornou resposta inválida",

        );



      }







      throw Exception(

        "Falha HTTP ${response.statusCode}",

      );






    }



    on DioException catch(e){



      // ignore: avoid_print
      print(
        "ERRO DIO UPLOAD:"
      );

      // ignore: avoid_print
      print(
        e.message
      );





      if(e.response != null){


        throw Exception(

          "Erro API ${e.response?.statusCode}: "
          "${e.response?.data}",

        );


      }





      throw Exception(

        "Erro de conexão com servidor upload: "
        "${e.message}",

      );



    }




    catch(e){



      throw Exception(

        "Erro no upload: $e",

      );


    }



  }









  // =====================================================
  // MULTIPLOS DOCUMENTOS
  // =====================================================



  Future<List<String>> uploadMultiplosArquivos({



    required List<PlatformFile> arquivos,


    required String pasta,



  }) async {



    final urls = <String>[];




    for(final arquivo in arquivos){



      final url = await uploadArquivo(


        arquivo: arquivo,


        pasta: pasta,


      );



      urls.add(url);



    }



    return urls;



  }









  // =====================================================
  // EXCLUIR DOCUMENTO
  // =====================================================



  Future<bool> excluirArquivo({


    required String arquivoUrl,


  }) async {



    try {



      final response = await _dio.delete(



        uploadEndpoint,



        queryParameters: {



          "url": arquivoUrl,


        },


      );





      return response.statusCode == 200;




    }catch(e){



      // ignore: avoid_print
      print(
        "Erro excluir arquivo: $e"
      );



      return false;


    }


  }



}