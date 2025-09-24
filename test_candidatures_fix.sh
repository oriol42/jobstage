#!/bin/bash

echo "🔧 Test des Corrections du Système de Candidatures"
echo "================================================="

# Aller dans le répertoire frontend
cd /home/oriol/Documents/j/frontend/jobstageapp

echo "📝 Corrections apportées:"
echo "✅ URLs corrigées: /api/jobs/candidatures/ au lieu de /api/candidatures/"
echo "✅ Structure des données adaptée au backend Django"
echo "✅ Modèle Candidature mis à jour pour correspondre au backend"
echo ""

echo "🎯 Test du système:"
echo "1. Lancez l'application Flutter"
echo "2. Connectez-vous en tant que candidat"
echo "3. Allez dans 'Offres'"
echo "4. Cliquez sur 'Postuler' sur une offre"
echo "5. Vérifiez que la candidature s'envoie sans erreur 404"
echo ""

# Vérifier les erreurs de linting
echo "🔍 Vérification des erreurs de linting..."
flutter analyze lib/services/application_service.dart
flutter analyze lib/models/candidature.dart

echo ""
echo "🚀 Lancement de l'application..."
flutter run
