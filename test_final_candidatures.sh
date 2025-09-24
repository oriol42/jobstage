#!/bin/bash

echo "🔧 Test Final du Système de Candidatures Corrigé"
echo "================================================"

# Aller dans le répertoire frontend
cd /home/oriol/Documents/j/frontend/jobstageapp

echo "✅ Corrections apportées:"
echo "1. Erreur de type corrigée dans ApplicationService"
echo "2. Gestion des réponses vides du backend"
echo "3. Erreur Hero widget corrigée dans ApplyJobDialog"
echo "4. SnackBars avec behavior: floating"
echo ""

echo "🧹 Nettoyage et redémarrage..."
flutter clean
flutter pub get

echo ""
echo "🚀 Lancement de l'application..."
echo ""
echo "📋 Instructions de test:"
echo "1. Connectez-vous en tant que candidat (lyode@gmail.com)"
echo "2. Allez dans 'Offres'"
echo "3. Cliquez sur 'Postuler' sur une offre"
echo "4. Sélectionnez un CV (PDF)"
echo "5. Cliquez sur 'Envoyer'"
echo "6. Vérifiez que ça fonctionne sans erreur"
echo "7. Allez dans 'Mes Candidatures' pour voir la candidature"
echo ""

flutter run -d emulator-5554
