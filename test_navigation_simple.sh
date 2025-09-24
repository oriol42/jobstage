#!/bin/bash

echo "🔍 Test Simple de Navigation"
echo "=========================="

# Aller dans le répertoire frontend
cd /home/oriol/Documents/j/frontend/jobstageapp

# Lancer l'application avec logs détaillés
echo "🚀 Lancement de l'application..."
echo ""
echo "📱 Instructions:"
echo "1. Connectez-vous en tant que recruteur"
echo "2. Allez dans 'Offres'"
echo "3. Cliquez sur une offre"
echo "4. Appuyez sur le bouton de retour (←)"
echo "5. Observez les logs ci-dessous"
echo ""
echo "🔍 Logs à surveiller:"
echo "- 🔙 NavigationHelper.handleBackNavigation appelé"
echo "- 🚀 SplashScreen: (si l'app redémarre)"
echo "- 🚨 ATTENTION: (si redirection vers login)"
echo ""

# Lancer Flutter
flutter run
