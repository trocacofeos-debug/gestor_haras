from fastapi import (
    FastAPI,
    UploadFile,
    File,
    Form,
    HTTPException,
    Query,
)

from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse

from backend.services.r2_service import upload_file

import uuid
import logging


# =====================================================
# LOG
# =====================================================

logger = logging.getLogger("gestor_haras")


# =====================================================
# APP
# =====================================================

app = FastAPI(
    title="Gestor Haras Upload API",
    version="1.0.0",
)


# =====================================================
# CORS - FLUTTER WEB
# =====================================================

app.add_middleware(

    CORSMiddleware,

    allow_origins=[
        "*",
    ],

    allow_credentials=False,

    allow_methods=[
        "GET",
        "POST",
        "OPTIONS",
        "DELETE",
    ],

    allow_headers=[
        "*",
    ],

)


# =====================================================
# HOME
# =====================================================

@app.get("/")
async def home():

    return {

        "status": "online",

        "api": "gestor_haras",

        "servico": "upload",

    }



# =====================================================
# STATUS UPLOAD
# =====================================================

@app.get("/api/upload")
async def status():

    return {

        "status": "online",

        "servico": "upload",

        "storage": "cloudflare_r2",

    }



# =====================================================
# UPLOAD R2
# =====================================================

@app.post("/api/upload")
async def upload(

    file: UploadFile = File(...),

    pasta: str = Form(
        "documentos"
    ),

):

    try:


        if not file.filename:


            raise HTTPException(

                status_code=400,

                detail="Arquivo não informado",

            )



        extensao = ""


        if "." in file.filename:

            extensao = (

                "."

                + file.filename.split(".")[-1]

            )



        nome = (

            f"{pasta}/"

            f"{uuid.uuid4()}"

            f"{extensao}"

        )



        url = upload_file(

            arquivo=file.file,

            nome=nome,

            content_type=(

                file.content_type

                or

                "application/octet-stream"

            ),

        )



        return {


            "sucesso": True,


            "arquivo": nome,


            "url": url,


        }



    except HTTPException:

        raise



    except Exception as e:


        logger.error(

            f"Erro upload R2: {e}"

        )


        return JSONResponse(

            status_code=500,

            content={


                "sucesso": False,


                "erro": str(e),


            },

        )


    finally:


        await file.close()



# =====================================================
# DELETE FUTURO
# =====================================================

@app.delete("/api/upload")
async def delete_upload(

    url: str = Query(...),

):


    return {


        "sucesso": False,


        "mensagem":

            "Exclusão ainda não implementada",


        "url": url,


    }