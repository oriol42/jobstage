#!/bin/bash

# Script de déploiement pour Render
echo "Démarrage du déploiement..."

# Installer les dépendances
pip install -r requirements.txt

# Effectuer les migrations
python manage.py migrate

# Collecter les fichiers statiques
python manage.py collectstatic --noinput

# Créer un superutilisateur si nécessaire (optionnel)
# python manage.py createsuperuser --noinput

echo "Déploiement terminé!"
