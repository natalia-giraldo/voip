#!/bin/bash

# On lit le fichier JSON et on boucle sur chaque utilisateur
echo "Génération de pjsip.conf depuis config.json..."

# On vide le fichier pjsip.conf
> /etc/asterisk/pjsip.conf

# Utilisation de jq pour extraire les données
jq -c '.users[]' config.json | while read i; do
    NOM=$(echo $i | jq -r '.name')
    EXT=$(echo $i | jq -r '.extension')
    MDP=$(echo $i | jq -r '.password')

    cat <<EOF >> /etc/asterisk/pjsip.conf
[$NOM](endpoint_internal)
auth=auth_$NOM
aors=$NOM

[auth_$NOM](auth_userpass)
username=$NOM
password=$MDP

[$NOM](aor_dynamic)
EOF
done


echo "Démarrage d'Asterisk..."
exec asterisk -f
