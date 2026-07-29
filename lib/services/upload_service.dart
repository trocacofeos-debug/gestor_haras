import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;


class UploadService {


  static const String endpoint =
      "https://gestor-haras-api.onrender.com/api/upload";



  Future<String?> uploadArquivo(
    PlatformFile arquivo,
  ) async {


    try {


      if (arquivo.bytes == null) {

        throw Exception(
          "Arquivo sem bytes",
        );

      }




      final request =
          http.MultipartRequest(

        "POST",

        Uri.parse(endpoint),

      );




      request.files.add(

        http.MultipartFile.fromBytes(

          "file",

          arquivo.bytes!,

          filename:
              arquivo.name,

        ),

      );



      // pasta no Cloudflare R2

      request.fields["pasta"] =
          "documentos";





      final response =
          await request.send();





      final resposta =
          await response.stream
              .bytesToString();





      if(response.statusCode == 200){


        final dados =
            jsonDecode(resposta);



        if(dados["sucesso"] == true){

          return dados["url"];

        }


        throw Exception(
          "Upload não retornou URL",
        );


      }





      throw Exception(
        resposta,
      );





    }catch(e){


      throw Exception(
        "Erro no upload: $e",
      );


    }


  }



  Future<String?> uploadAssinatura(
      PlatformFile arquivo,
      ) async {


    try {


      if(arquivo.bytes == null){

        throw Exception(
          "Arquivo sem bytes",
        );

      }




      final request =
      http.MultipartRequest(

        "POST",

        Uri.parse(endpoint),

      );



      request.files.add(

        http.MultipartFile.fromBytes(

          "file",

          arquivo.bytes!,

          filename:
          "assinatura.png",

        ),

      );



      request.fields["pasta"] =
          "assinaturas";





      final response =
      await request.send();




      final resposta =
      await response.stream
          .bytesToString();




      if(response.statusCode == 200){


        final dados =
        jsonDecode(resposta);



        return dados["url"];

      }



      throw Exception(
        resposta,
      );



    }catch(e){


      throw Exception(
        "Erro upload assinatura: $e",
      );


    }

  }


}