#!/bin/bash

echo "🔧 Diagnostic JobStage - $(date)"
echo "=================================="

# 1. Adresse IP
echo "1. Adresse IP actuelle:"
IP=$(ip route get 1.1.1.1 | awk '{print $7}' | head -1)
echo "   $IP"

# 2. Vérifier si le backend est en cours d'exécution
echo "2. Backend en cours d'exécution:"
if pgrep -f "manage.py runserver" > /dev/null; then
    echo "   ✅ Backend démarré"
else
    echo "   ❌ Backend arrêté"
fi

# 3. Vérifier le port 8000
echo "3. Port 8000:"
if netstat -tlnp 2>/dev/null | grep :8000 > /dev/null; then
    echo "   ✅ Port 8000 ouvert"
else
    echo "   ❌ Port 8000 fermé"
fi

# 4. Test de connexion backend
echo "4. Test de connexion backend:"
if curl -s --connect-timeout 5 http://$IP:8000/api/jobs/offres/ > /dev/null; then
    echo "   ✅ Backend accessible"
else
    echo "   ❌ Backend inaccessible"
fi

# 5. Vérifier l'adresse IP dans api_service.dart
echo "5. Adresse IP dans api_service.dart:"
API_IP=$(grep -o "http://[0-9.]*:8000" /home/oriol/Documents/j/frontend/jobstageapp/lib/services/api_service.dart | head -1)
echo "   $API_IP"

if [[ "$API_IP" == "http://$IP:8000" ]]; then
    echo "   ✅ Adresse IP correcte"
else
    echo "   ❌ Adresse IP incorrecte - Mise à jour nécessaire"
    echo "   Commande: sed -i 's/http:\/\/[0-9.]*:8000/http:\/\/$IP:8000/g' /home/oriol/Documents/j/frontend/jobstageapp/lib/services/api_service.dart"
fi

# 6. Vérifier les données de test
echo "6. Données de test:"
cd /home/oriol/Documents/j/backend
if [ -f "test_offers.py" ]; then
    echo "   ✅ Script de test disponible"
else
    echo "   ❌ Script de test manquant"
fi

echo ""
echo "🎯 Actions recommandées:"
echo "1. Si backend arrêté: cd /home/oriol/Documents/j/backend && source env/bin/activate && python manage.py runserver 0.0.0.0:8000 &"
echo "2. Si adresse IP incorrecte: Mettre à jour api_service.dart"
echo "3. Si données manquantes: python test_offers.py"
echo "4. Pour tester l'API: python test_api.py"
echo ""
echo "📱 Frontend: cd /home/oriol/Documents/j/frontend/jobstageapp && flutter run"

