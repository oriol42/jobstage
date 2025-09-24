#!/bin/bash

echo "🔄 Redémarrage et Test du Système de Candidatures"
echo "================================================="

# Aller dans le répertoire frontend
cd /home/oriol/Documents/j/frontend/jobstageapp

echo "🧹 Nettoyage des caches..."
flutter clean
flutter pub get

echo ""
echo "🔧 Corrections apportées:"
echo "✅ URLs corrigées dans ApplicationService"
echo "✅ Références à ApplicationsScreen remplacées par MyApplicationsScreen"
echo "✅ Imports ajoutés dans profile_screen.dart"
echo ""

echo "🚀 Lancement de l'application..."
echo "Testez maintenant:"
echo "1. Connectez-vous en tant que candidat"
echo "2. Allez dans 'Offres'"
echo "3. Cliquez sur 'Postuler'"
echo "4. Vérifiez que ça fonctionne sans erreur 404"
echo ""

flutter run -d emulator-5554
