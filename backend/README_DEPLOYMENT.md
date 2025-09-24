# Guide de Déploiement JOBSTAGE sur Render

## Configuration PostgreSQL

Le projet a été configuré pour utiliser PostgreSQL en production et SQLite en développement.

### Variables d'environnement requises

1. **SECRET_KEY** : Clé secrète Django (générée automatiquement par Render)
2. **DEBUG** : `False` pour la production
3. **ALLOWED_HOSTS** : URL de votre application Render
4. **DATABASE_URL** : URL de connexion PostgreSQL (fournie par Render)
5. **CORS_ALLOW_ALL_ORIGINS** : `True` pour permettre les requêtes CORS

### Déploiement sur Render

1. **Connecter le repository GitHub** à Render
2. **Créer une base de données PostgreSQL** sur Render
3. **Configurer les variables d'environnement** :
   - `SECRET_KEY` : Générée automatiquement
   - `DEBUG` : `False`
   - `ALLOWED_HOSTS` : `votre-app.onrender.com`
   - `DATABASE_URL` : Fournie par la base de données PostgreSQL
   - `CORS_ALLOW_ALL_ORIGINS` : `True`

### Commandes de build

```bash
pip install -r requirements.txt
python manage.py migrate
python manage.py collectstatic --noinput
```

### Commande de démarrage

```bash
gunicorn jobstage_backend.wsgi:application
```

## Fichiers supprimés

Les fichiers suivants ont été supprimés car ils n'étaient plus nécessaires :
- Tous les fichiers de test (`test_*.py`)
- Tous les fichiers de création de données de test (`create_*.py`)
- Tous les fichiers de debug (`debug_*.py`)
- Le fichier de base de données SQLite (`db.sqlite3`)

## Structure finale

```
backend/
├── accounts/
├── applications/
├── jobs/
├── jobstage_backend/
├── media/
├── requirements.txt
├── Procfile
├── render.yaml
├── deploy.sh
└── env.example
```

## Notes importantes

- La base de données sera recréée lors du déploiement
- Les fichiers statiques sont servis par WhiteNoise
- La configuration de sécurité est activée en production
- CORS est configuré pour permettre les requêtes depuis l'application Flutter
