#!/bin/bash

function getEDTLink()
{
    local VERSION_EDT=$(echo $VERSION | grep -oP "[0-9]{4}\.[0-9]{1,}")
    local EDT64LINK=$(curl -s -G \
        -b /tmp/cookies.txt \
        --data-urlencode "nick=DevelopmentTools10" \
        --data-urlencode "ver=$VERSION_EDT" \
        --data-urlencode "path=DevelopmentTools\\${VERSION_EDT//./_}\\1c_enterprise_development_tools_distr_${VERSION}_linux_x86_64.tar.gz" \
        https://releases.1c.ru/version_file | grep -oP '(?<=a href=")[^"]+(?=">Скачать дистрибутив<)')
    echo "$EDT64LINK"
}

function getclientLink()
{
    local CLIENTLINK=$(curl -s -G \
        -b /tmp/cookies.txt \
        --data-urlencode "nick=Platform83" \
        --data-urlencode "ver=$VERSION" \
        --data-urlencode "path=Platform\\${VERSION//./_}\\client_${VERSION//./_}.deb64.tar.gz" \
        https://releases.1c.ru/version_file | grep -oP '(?<=a href=")[^"]+(?=">Скачать дистрибутив<)')
    echo "$CLIENTLINK"
}

function getServerLink()
{
    local SERVERLINK=$(curl -s -G \
        -b /tmp/cookies.txt \
        --data-urlencode "nick=Platform83" \
        --data-urlencode "ver=$VERSION" \
        --data-urlencode "path=Platform\\${VERSION//./_}\\deb64_${VERSION//./_}.tar.gz" \
        https://releases.1c.ru/version_file | grep -oP '(?<=a href=")[^"]+(?=">Скачать дистрибутив<)')
    echo "$SERVERLINK"
}

function getThincClientLink()
{

    local THINCLIENTLINK=$(curl -s -G \
        -b /tmp/cookies.txt \
        --data-urlencode "nick=Platform83" \
        --data-urlencode "ver=$VERSION" \
        --data-urlencode "path=Platform\\${VERSION//./_}\\thin.client_${VERSION//./_}.deb64.tar.gz" \
        https://releases.1c.ru/version_file | grep -oP '(?<=a href=")[^"]+(?=">Скачать дистрибутив<)')
    echo "$THINCLIENTLINK"
}

if [ -z "$ONEC_USERNAME" ]
then
    echo "ONEC_USERNAME not set"
    exit 1
fi

if [ -z "$ONEC_PASSWORD" ]
then
    echo "ONEC_PASSWORD not set"
    exit 1
fi

if [ -z "$VERSION" ]
then
    echo "VERSION not set"
    exit 1
fi



SRC=$(curl -c /tmp/cookies.txt -s -L https://releases.1c.ru)
cat /tmp/cookies.txt
ACTION=$(echo "$SRC" | grep -oP '(?<=form method="post" id="loginForm" action=")[^"]+(?=")')
EXECUTION=$(echo "$SRC" | grep -oP '(?<=input type="hidden" name="execution" value=")[^"]+(?=")')

curl -s -L \
    -o /dev/null \
    -b /tmp/cookies.txt \
    -c /tmp/cookies.txt \
    --data-urlencode "inviteCode=" \
    --data-urlencode "execution=$EXECUTION" \
    --data-urlencode "_eventId=submit" \
    --data-urlencode "username=$ONEC_USERNAME" \
    --data-urlencode "password=$ONEC_PASSWORD" \
    https://login.1c.ru"$ACTION"

cat /tmp/cookies.txt

if ! grep -q "TGC" /tmp/cookies.txt
then
    echo "Auth failed"
    exit 1
else
    echo "Auth ok"
fi

case "$installer_type" in
  server)
      SERVERLINK=$(getServerLink)
      curl --fail -b /tmp/cookies.txt -o server.tar.gz -L "$SERVERLINK"
      ;;

  client)
        SERVERLINK=$(getServerLink)
        CLIENTLINK=$(getclientLink)
        curl --fail -b /tmp/cookies.txt -o server.tar.gz -L "$SERVERLINK"
        curl --fail -b /tmp/cookies.txt -o client.tar.gz -L "$CLIENTLINK"
        ;;    

  thin-client)
        THINCLIENTLINK=$(getThincClientLink)
        curl --fail -b /tmp/cookies.txt -o thin-client.tar.gz -L "$THINCLIENTLINK"
      ;;
  edt)
    
    EDT64LINK=$(getEDTLink)
    curl --fail -b /tmp/cookies.txt -o edt.tar.gz -L "$EDT64LINK"
esac

rm /tmp/cookies.txt



