#!/bin/bash

echo "🔍 Test de connexion avec le recruteur irontech"
echo "=============================================="

# Aller dans le répertoire frontend
cd /home/oriol/Documents/j/frontend/jobstageapp

echo "📋 Instructions:"
echo "1. Connectez-vous avec le compte recruteur: irontech@gmail.com"
echo "2. Mot de passe: (utilisez le mot de passe que vous avez défini)"
echo "3. Allez dans l'onglet 'Candidatures'"
echo "4. Vous devriez voir 2 candidatures de lyode"
echo ""

echo "🔑 Comptes de test disponibles:"
echo "- Candidat: lyode@gmail.com (a déjà postulé)"
echo "- Recruteur: irontech@gmail.com (a des offres et des candidatures)"
echo ""

echo "🚀 Lancement de l'application..."
flutter run -d emulator-5554
