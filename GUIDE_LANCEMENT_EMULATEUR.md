# 🚀 Guide de Lancement - JobStage avec Émulateur Android

## Configuration Automatique ✅

L'application a été configurée pour fonctionner avec l'émulateur Android :
- **Backend Django** : `http://10.0.2.2:8000` (adresse spéciale émulateur)
- **Frontend Flutter** : Configuré pour se connecter au backend

## 🎯 Lancement Rapide

### Option 1 : Lancement Automatique (Recommandé)
```bash
cd /home/oriol/Documents/j
./start_app.sh
```

### Option 2 : Lancement Manuel

#### 1. Backend Django
```bash
cd /home/oriol/Documents/j
./start_backend.sh
```

#### 2. Frontend Flutter (dans un nouveau terminal)
```bash
cd /home/oriol/Documents/j
./start_frontend.sh
```

## 📱 Configuration Émulateur

### Adresses Configurées
- **Émulateur Android** : `http://10.0.2.2:8000`
- **Navigateur local** : `http://localhost:8000`
- **Réseau local** : `http://192.168.183.190:8000`

### Vérification
```bash
# Tester la connectivité
curl http://10.0.2.2:8000/api/jobs/offres/public/

# Vérifier les ports
netstat -tlnp | grep :8000
```

## 🔧 Dépannage

### Si le backend ne démarre pas
```bash
cd /home/oriol/Documents/j/backend
source env/bin/activate
python manage.py makemigrations
python manage.py migrate
python manage.py runserver 0.0.0.0:8000
```

### Si l'émulateur ne se connecte pas
1. Vérifiez que l'émulateur est démarré : `flutter devices`
2. Vérifiez que le backend écoute sur 0.0.0.0:8000
3. Testez avec : `curl http://10.0.2.2:8000/api/jobs/offres/public/`

### Si vous changez d'adresse IP
Modifiez le fichier : `frontend/jobstageapp/lib/services/api_service.dart`
```dart
static const String baseUrl = 'http://10.0.2.2:8000/api';
```

## 📋 Scripts Disponibles

- `start_app.sh` : Lance tout automatiquement
- `start_backend.sh` : Lance seulement le backend
- `start_frontend.sh` : Lance seulement le frontend
- `diagnostic.sh` : Diagnostic de l'état de l'application

## ✅ Vérification du Fonctionnement

1. **Backend** : http://localhost:8000/admin (interface admin Django)
2. **API** : http://localhost:8000/api/jobs/offres/public/ (endpoint public)
3. **Frontend** : Application Flutter sur l'émulateur

## 🎯 Prochaines Étapes

1. Lancez l'application avec `./start_app.sh`
2. Testez la connexion dans l'émulateur
3. Créez des comptes utilisateur
4. Testez la création d'offres d'emploi

---
*Configuration effectuée le $(date)*
