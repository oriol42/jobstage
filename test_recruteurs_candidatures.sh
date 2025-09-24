#!/bin/bash

echo "🔍 Test des recruteurs et leurs candidatures"
echo "==========================================="

# Aller dans le répertoire frontend
cd /home/oriol/Documents/j/frontend/jobstageapp

echo "📋 Instructions:"
echo ""
echo "1. Connectez-vous avec l'un de ces comptes recruteur:"
echo "   - irontech@gmail.com (a 2 candidatures)"
echo "   - video@gmail.com (a 1 candidature)"
echo "   - contact@techcorp.cm (a 0 candidatures)"
echo ""
echo "2. Allez dans l'onglet 'Candidatures'"
echo "3. Vous devriez voir les candidatures correspondantes"
echo ""
echo "🔑 Comptes de test disponibles:"
echo "- irontech@gmail.com : 2 candidatures (CENADI, dev javascriots)"
echo "- video@gmail.com : 1 candidature (dev)"
echo "- contact@techcorp.cm : 0 candidatures"
echo ""

echo "🚀 Lancement de l'application..."
flutter run -d emulator-5554
