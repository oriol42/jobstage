#!/bin/bash

echo "🚀 Test du Système de Candidatures Amélioré"
echo "==========================================="

# Aller dans le répertoire frontend
cd /home/oriol/Documents/j/frontend/jobstageapp

# Installer les dépendances si nécessaire
echo "📦 Vérification des dépendances..."
flutter pub get

echo ""
echo "🎯 Instructions de test:"
echo ""
echo "1. CÔTÉ CANDIDAT:"
echo "   - Connectez-vous en tant que candidat"
echo "   - Allez dans 'Offres'"
echo "   - Cliquez sur 'Postuler' sur une offre"
echo "   - Sélectionnez un CV (PDF/DOC)"
echo "   - Optionnel: Ajoutez une lettre de motivation"
echo "   - Ajoutez un message personnalisé"
echo "   - Cliquez sur 'Envoyer'"
echo "   - Vérifiez dans 'Mes Candidatures'"
echo ""
echo "2. CÔTÉ RECRUTEUR:"
echo "   - Connectez-vous en tant que recruteur"
echo "   - Allez dans l'onglet 'Candidatures'"
echo "   - Vérifiez que la candidature apparaît"
echo "   - Testez les actions: Marquer comme vue, Présélectionner, etc."
echo "   - Vérifiez les filtres par statut"
echo ""
echo "3. FONCTIONNALITÉS TESTÉES:"
echo "   ✅ Upload de CV via AuthService existant"
echo "   ✅ Candidature avec message personnalisé"
echo "   ✅ Vérification candidature existante"
echo "   ✅ Suivi des statuts (En cours, Acceptée, Refusée)"
echo "   ✅ Filtres par statut"
echo "   ✅ Interface utilisateur améliorée"
echo "   ✅ Gestion des erreurs"
echo ""

# Lancer Flutter
echo "🚀 Lancement de l'application..."
flutter run

