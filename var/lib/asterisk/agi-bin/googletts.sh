#!/bin/bash
# Récupération des arguments envoyés par extensions.conf
TEXT=$1
LANG=$2

# Création d'un nom de fichier unique basé sur le texte (md5) pour éviter de retélécharger 2 fois la même chose
MD5=$(echo $TEXT | md5sum | cut -d ' ' -f 1)
FILE="/tmp/$MD5"

# Si le fichier audio n'existe pas déjà, on le télécharge chez Google
if [ ! -f "$FILE.wav" ]; then
    # URL magique de Google Translate (client=tw-ob permet l'accès gratuit)
    wget -q -U Mozilla -O "$FILE.mp3" "http://translate.google.com/translate_tts?ie=UTF-8&client=tw-ob&q=$TEXT&tl=$LANG"

    # Conversion du MP3 en WAV compatible Asterisk (8000Hz, Mono)
    sox "$FILE.mp3" -r 8000 -c 1 "$FILE.wav"

    # Nettoyage du MP3
    rm "$FILE.mp3"
fi

# On dit à Asterisk de jouer le fichier (STREAM FILE attend le chemin sans l'extension .wav)
echo "STREAM FILE $FILE \"\""
read RESPONSE
