#!/bin/bash

echo "🔍 Test de Navigation avec Logs de Debug"
echo "========================================"

# Aller dans le répertoire frontend
cd /home/oriol/Documents/j/frontend/jobstageapp

# Nettoyer et reconstruire
echo "🧹 Nettoyage et reconstruction..."
flutter clean
flutter pub get

# Vérifier les erreurs de compilation
echo "🔍 Vérification des erreurs de compilation..."
flutter analyze

# Lancer l'application avec les logs
echo "🚀 Lancement de l'application avec logs de debug..."
echo ""
echo "📱 Instructions de test:"
echo "1. Connectez-vous en tant que recruteur"
echo "2. Allez dans les offres"
echo "3. Cliquez sur une offre pour voir les détails"
echo "4. Appuyez sur le bouton de retour (←)"
echo "5. Observez les logs dans la console"
echo ""
echo "🔍 Logs à surveiller:"
echo "- 🔙 NavigationHelper.handleBackNavigation appelé"
echo "- 📱 OffersListPage.build() appelé"
echo "- 📱 OfferDetailsPage.build() appelé"
echo "- 🔄 Redirection vers..."
echo ""

# Lancer Flutter avec logs détaillés
flutter run --verbose
