#!/bin/bash

echo "📱 Démarrage du frontend Flutter JobStage..."

# Aller dans le répertoire frontend
cd /home/oriol/Documents/j/frontend/jobstageapp

# Vérifier que Flutter est installé
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter n'est pas installé ou n'est pas dans le PATH"
    exit 1
fi

# Vérifier les appareils connectés
echo "🔍 Vérification des appareils disponibles..."
flutter devices

echo ""
echo "🚀 Lancement de l'application Flutter..."
echo "📱 L'application va se lancer sur l'émulateur Android"
echo "🌐 Backend configuré pour: http://10.0.2.2:8000"
echo ""

# Lancer l'application
flutter run
