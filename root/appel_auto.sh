#!/bin/bash

# Chemins
FICHIER_CSV="/root/prospects.csv"
SPOOL_DIR="/var/spool/asterisk/outgoing"
TEMP_DIR="/tmp"

echo "=== Lancement de la campagne de prospection ==="

# Lecture du fichier CSV
shuf $FICHIER_CSV | while IFS=',' read -r NOM NUMERO
do
    NOM=$(echo $NOM | tr -d '[:space:]')

    echo "Traitement de : $NOM"


    cat <<EOF > $TEMP_DIR/appel_$NOM.call
Channel: PJSIP/$NOM
MaxRetries: 1
RetryTime: 60
WaitTime: 30
Context: svi-google
Extension: s
Priority: 1
CallerID: "La plateforme service client" <8000>
EOF

    chown asterisk:asterisk $TEMP_DIR/appel_$NOM.call

    # On définit la date de l'appel (tout de suite ou différé)
    DELAI=$((1 + RANDOM % 10))
    touch -d "+$DELAI seconds" $TEMP_DIR/appel_$NOM.call

    # Déplacement final
    mv $TEMP_DIR/appel_$NOM.call $SPOOL_DIR/

    echo " -> Appel programmé vers PJSIP/$NOM dans $DELAI secondes."
done

