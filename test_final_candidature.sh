#!/bin/bash

echo "🎯 Test Final - Système de Candidatures Complet"
echo "==============================================="

# Aller dans le répertoire frontend
cd /home/oriol/Documents/j/frontend/jobstageapp

echo "✅ Corrections apportées:"
echo "1. Erreur Hero widget résolue (SimpleApplyDialog)"
echo "2. ApplicationService corrigé (gestion des types)"
echo "3. AuthService.uploadCV() corrigé (baseUrl async)"
echo "4. ApplicationService.applyToJob() corrigé (MultipartRequest)"
echo "5. Envoi direct des fichiers au backend"
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
echo "5. Optionnel: Ajoutez une lettre de motivation"
echo "6. Cliquez sur 'Envoyer'"
echo "7. Vérifiez que la candidature s'envoie avec succès"
echo "8. Allez dans 'Mes Candidatures' pour voir la candidature"
echo ""

flutter run -d emulator-5554
