#!/bin/bash
# ==============================================================
# Script d'installation automatisée d'Asterisk "On the fly"
# ==============================================================

# 1. Arrêter le script si une erreur se produit
set -e

echo "=== Mise à jour du système et installation des prérequis ==="
apt-get update && apt-get upgrade -y
apt-get install -y build-essential wget curl libncurses5-dev uuid-dev \
                   libjansson-dev libxml2-dev sqlite3 libsqlite3-dev \
                   libedit-dev sox mpg123

# Téléchargement des sources (Version 23)
echo "=== Téléchargement d'Asterisk ==="
cd /usr/src
wget http://downloads.asterisk.org/pub/telephony/asterisk/asterisk-23-current.tar.gz
tar xvf asterisk-23-current.tar.gz
cd asterisk-23.*/

# Compilation et Installation
echo "=== Compilation (Cela peut prendre quelques minutes) ==="
# Installation des dépendances automatiques manquantes
contrib/scripts/install_prereq install
./configure --with-jansson-bundled
make menuselect.makeopts
make
make install

# 4. Génération des fichiers de configuration de base
echo "=== Création des configurations par défaut ==="
make samples
make config

# Démarrage du service
systemctl enable asterisk
systemctl start asterisk

echo "=== ✅ Installation d'Asterisk terminée avec succès ! ==="
asterisk -V
