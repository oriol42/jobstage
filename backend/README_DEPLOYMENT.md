# Guide de Déploiement Jobstage sur Render

## Prérequis
- Compte Render.com
- Base de données PostgreSQL (fournie par Render)

## Étapes de déploiement

### 1. Préparation du projet
Le projet est déjà configuré avec :
- ✅ `requirements.txt` - Dépendances Python
- ✅ `Procfile` - Configuration Gunicorn
- ✅ `render.yaml` - Configuration Render
- ✅ `settings.py` - Configuration production
- ✅ `whitenoise` - Servir les fichiers statiques

### 2. Déploiement sur Render

1. **Connecter le repository GitHub**
   - Aller sur [render.com](https://render.com)
   - Créer un nouveau "Web Service"
   - Connecter le repository GitHub

2. **Configuration du service**
   - **Build Command**: `pip install -r requirements.txt && python manage.py collectstatic --noinput && python manage.py migrate`
   - **Start Command**: `gunicorn jobstage_backend.wsgi`
   - **Python Version**: 3.12

3. **Variables d'environnement**
   - `SECRET_KEY`: Générée automatiquement par Render
   - `DEBUG`: `False`
   - `ALLOWED_HOSTS`: `jobstage-backend.onrender.com`
   - `CORS_ALLOW_ALL_ORIGINS`: `False`
   - `DATABASE_URL`: Fournie automatiquement par Render

4. **Base de données PostgreSQL**
   - Créer une base de données PostgreSQL sur Render
   - La variable `DATABASE_URL` sera automatiquement configurée

### 3. Configuration CORS pour le frontend

Une fois déployé, mettre à jour l'URL de base dans l'application Flutter :
```dart
// Dans network_config.dart
static const String productionBaseUrl = 'https://jobstage-backend.onrender.com/api';
```

### 4. Vérification du déploiement

1. **Test de l'API**
   ```bash
   curl https://jobstage-backend.onrender.com/api/auth/register/
   ```

2. **Test des fichiers statiques**
   - Vérifier que les CSS/JS se chargent correctement

3. **Test de la base de données**
   - Vérifier que les migrations ont été appliquées
   - Tester la création d'utilisateur

### 5. Monitoring

- Logs disponibles dans le dashboard Render
- Métriques de performance
- Gestion des erreurs

## Structure des fichiers

```
backend/
├── Procfile                 # Configuration Gunicorn
├── requirements.txt         # Dépendances Python
├── render.yaml             # Configuration Render
├── .env                    # Variables d'environnement locales
├── staticfiles/            # Fichiers statiques collectés
└── jobstage_backend/
    └── settings.py         # Configuration Django
```

## Notes importantes

- Le service gratuit de Render peut "s'endormir" après 15 minutes d'inactivité
- Pour un usage en production, considérer un plan payant
- Les fichiers statiques sont servis par WhiteNoise
- La base de données PostgreSQL est persistante même en plan gratuit