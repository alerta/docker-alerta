DOCKER_HOST="tcp://54.76.228.10:4242" 

AUTH_REQUIRED=True
CLIENT_ID=988466068957-0lkeb0u8takpfsoasbciou2f44crhk0k.apps.googleusercontent.com
REDIRECT_URL=http://docker.alerta.io:49900/app/oauth2callback.html
ALLOWED_EMAIL_DOMAIN=guardian.co.uk

docker run --link alerta-db:mongo -e AUTH_REQUIRED=$AUTH_REQUIRED -e CLIENT_ID=$CLIENT_ID -e REDIRECT_URL=$REDIRECT_URL -t -i -p 49900:80 $*
# docker run --link alerta-db:mongo -t -i -p 49900:80 $*
