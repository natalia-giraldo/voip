#!/bin/bash

CSV="/root/user_ldap.csv"
CONF="/etc/asterisk/pjsip.conf"

echo "=== Création des utilisateurs Asterisk ==="


while IFS=',' read -r NOM NUMERO MDP
do
    # vérifie si l'utilisateur existe déjà dans le fichier pour éviter les doublons
    if grep -q "\[$NOM\]" "$CONF"; then
        echo "L'utilisateur $NOM existe déjà. Ignoré."
        continue
    fi

    echo "Ajout de l'utilisateur : $NOM (Ext: $NUMERO)"

    # injection de la configuration à la fin du fichier pjsip.conf
    cat <<EOF >> "$CONF"

; --- UTILISATEUR $NOM ($NUMERO) CRÉÉ PAR LE SCRIPT ---
[$NOM](endpoint_internal)
auth=auth_$NOM
aors=$NOM

[auth_$NOM](auth_userpass)
username=$NOM
password=$MDP

[$NOM](aor_dynamic)
EOF

done < "$CSV"

echo "Rechargement de la configuration Asterisk..."
asterisk -rx "core reload"
echo "Terminé !"
