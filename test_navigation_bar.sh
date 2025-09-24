#!/bin/bash

echo "🔍 Test de la Barre de Navigation"
echo "================================="

# Aller dans le répertoire frontend
cd /home/oriol/Documents/j/frontend/jobstageapp

# Lancer l'application avec logs détaillés
echo "🚀 Lancement de l'application..."
echo ""
echo "📱 Instructions de test:"
echo "1. Connectez-vous en tant que recruteur"
echo "2. Vérifiez que la barre de navigation en bas est visible"
echo "3. Allez dans 'Offres' (onglet 2)"
echo "4. Cliquez sur une offre pour voir les détails"
echo "5. Appuyez sur le bouton de retour (←)"
echo "6. Vérifiez que vous êtes revenus à 'Offres' avec la barre de navigation visible"
echo "7. Testez aussi 'Candidats' (onglet 3)"
echo ""
echo "🔍 Logs à surveiller:"
echo "- 🔄 Utilisation de pushReplacement pour RecruiterNavigation"
echo "- 📱 OffersListPage.build() appelé"
echo "- 📱 MatchesPage.build() appelé"
echo ""

# Lancer Flutter
flutter run
