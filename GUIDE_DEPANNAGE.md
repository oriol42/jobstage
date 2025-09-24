# Guide de Dépannage - JobStage

## 🚨 Problèmes Courants et Solutions

### 1. Erreur "setState() called after dispose()"

**Problème :** Le widget essaie de mettre à jour l'état après avoir été supprimé.

**Solution :** ✅ **CORRIGÉ** - Ajout de vérifications `mounted` dans tous les `setState()`.

### 2. Erreur de Connexion Socket (Connection timed out)

**Problème :** Le frontend ne peut pas se connecter au backend.

**Solutions :**

#### A. Vérifier l'adresse IP
```bash
# Obtenir l'adresse IP actuelle
ip route get 1.1.1.1 | awk '{print $7}' | head -1
```

#### B. Mettre à jour l'API Service
Dans `frontend/jobstageapp/lib/services/api_service.dart` :
```dart
static const String baseUrl = 'http://VOTRE_IP:8000/api';
```

#### C. Vérifier que le backend est démarré
```bash
cd /home/oriol/Documents/j/backend
source env/bin/activate
python manage.py runserver 0.0.0.0:8000
```

#### D. Tester la connexion
```bash
curl http://VOTRE_IP:8000/api/jobs/offres/
# Doit retourner: {"detail":"Informations d'authentification non fournies."}
```

### 3. Problèmes d'Authentification

**Problème :** Erreur 401 Unauthorized.

**Solutions :**

#### A. Vérifier le token
```dart
// Dans le service API
print('Token actuel: $_token');
```

#### B. Se reconnecter
1. Se déconnecter de l'app
2. Se reconnecter avec les identifiants de test

### 4. Offres Non Visibles

**Problème :** Les offres ne s'affichent pas dans l'interface candidat.

**Solutions :**

#### A. Vérifier les données de test
```bash
cd /home/oriol/Documents/j/backend
source env/bin/activate
python test_offers.py
```

#### B. Vérifier l'API directement
```bash
python test_api.py
```

#### C. Vérifier les logs
- Backend : Regarder la console Django
- Frontend : Regarder la console Flutter

### 5. Problèmes de Compilation Flutter

**Problème :** Erreurs de compilation ou de linting.

**Solutions :**

#### A. Nettoyer le projet
```bash
cd /home/oriol/Documents/j/frontend/jobstageapp
flutter clean
flutter pub get
```

#### B. Vérifier les erreurs de linting
```bash
flutter analyze
```

#### C. Redémarrer l'application
```bash
flutter run
```

## 🔧 Scripts de Diagnostic

### 1. Vérifier l'État du Système
```bash
#!/bin/bash
echo "=== Diagnostic JobStage ==="
echo "1. Adresse IP:"
ip route get 1.1.1.1 | awk '{print $7}' | head -1

echo "2. Backend en cours d'exécution:"
ps aux | grep "manage.py runserver" | grep -v grep

echo "3. Port 8000 ouvert:"
netstat -tlnp | grep :8000

echo "4. Test de connexion backend:"
curl -s http://localhost:8000/api/jobs/offres/ | head -1
```

### 2. Redémarrer Tout le Système
```bash
#!/bin/bash
echo "=== Redémarrage JobStage ==="

# Arrêter le backend
pkill -f "manage.py runserver"

# Attendre 2 secondes
sleep 2

# Redémarrer le backend
cd /home/oriol/Documents/j/backend
source env/bin/activate
python manage.py runserver 0.0.0.0:8000 &

echo "Backend redémarré sur le port 8000"
echo "Frontend: flutter run dans le dossier frontend/jobstageapp"
```

## 📱 Tests de Validation

### 1. Test Backend
```bash
cd /home/oriol/Documents/j/backend
source env/bin/activate
python test_api.py
```

### 2. Test Frontend
1. Ouvrir l'application Flutter
2. Se connecter avec `candidat_test` / `test123`
3. Aller à l'écran "Offres d'Emploi"
4. Vérifier que les offres s'affichent

### 3. Test Recruteur
1. Se connecter avec `recruteur_test` / `test123`
2. Aller à "Mes Offres"
3. Créer une nouvelle offre
4. Vérifier qu'elle apparaît dans la liste

## 🐛 Logs Utiles

### Backend (Django)
```bash
cd /home/oriol/Documents/j/backend
source env/bin/activate
python manage.py runserver 0.0.0.0:8000 --verbosity=2
```

### Frontend (Flutter)
```bash
cd /home/oriol/Documents/j/frontend/jobstageapp
flutter run --verbose
```

## 📞 Support

Si les problèmes persistent :

1. **Vérifier les logs** : Backend et Frontend
2. **Tester l'API** : Utiliser `test_api.py`
3. **Vérifier la connectivité** : `curl` et `ping`
4. **Redémarrer** : Backend et Frontend
5. **Nettoyer** : `flutter clean` et `python manage.py migrate`

## ✅ Checklist de Validation

- [ ] Backend démarré sur le port 8000
- [ ] Adresse IP correcte dans `api_service.dart`
- [ ] Données de test créées (`test_offers.py`)
- [ ] API fonctionnelle (`test_api.py`)
- [ ] Frontend compile sans erreurs
- [ ] Connexion candidat fonctionne
- [ ] Connexion recruteur fonctionne
- [ ] Offres visibles dans l'interface candidat
- [ ] Création d'offres fonctionne
- [ ] Recherche et filtres fonctionnent

---

**Note :** La plupart des problèmes viennent de l'adresse IP qui change. Mettez toujours à jour `api_service.dart` avec la bonne adresse IP.

