# Guide de Dépannage - Publication d'Offres

## Problème Identifié ✅

**Erreur principale** : `NOT NULL constraint failed: jobs_offre.entreprise_id`

L'erreur indique que le champ `entreprise_id` est `None` lors de la création d'une offre, ce qui viole la contrainte NOT NULL de la base de données.

## Solutions Implémentées

### 1. ✅ Utilisateur Recruteur Créé
- **Nom d'utilisateur** : `recruteur_techcorp`
- **Email** : `recruteur@techcorp.cm`
- **Mot de passe** : `testpass123`
- **Type** : Recruteur
- **Entreprise** : TechCorp Cameroun (ID: 3)

### 2. ✅ URL Backend Corrigée
- **Ancienne URL** : `http://192.168.1.109:8000/api`
- **Nouvelle URL** : `http://localhost:8000/api`

### 3. ✅ Gestion d'Erreurs Améliorée
- Logs détaillés dans le frontend
- Messages d'erreur plus explicites
- Bouton "Détails" pour voir l'erreur complète

## Problème Restant

Malgré toutes les corrections, l'erreur persiste. Le problème semble être que la méthode `perform_create` dans la vue Django ne trouve pas l'entreprise de l'utilisateur connecté.

## Solutions à Tester

### Solution 1: Vérifier l'Authentification
```bash
# Dans le terminal backend
cd /home/oriol/Documents/j/backend
source env/bin/activate
python debug_entreprise_issue.py
```

### Solution 2: Tester la Création d'Offre
```bash
# Dans le terminal backend
cd /home/oriol/Documents/j/backend
source env/bin/activate
python test_authenticated_creation.py
```

### Solution 3: Vérifier les Logs Django
Les logs de débogage devraient apparaître dans la console du serveur Django. Si vous ne les voyez pas, le problème pourrait être ailleurs.

## Instructions pour l'Utilisateur

### 1. Démarrer le Serveur Backend
```bash
cd /home/oriol/Documents/j/backend
source env/bin/activate
python manage.py runserver 0.0.0.0:8000
```

### 2. Tester la Publication d'Offre
1. Ouvrir l'application Flutter
2. Se connecter avec :
   - **Email** : `recruteur@techcorp.cm`
   - **Mot de passe** : `testpass123`
3. Aller dans la section "Offres" → "Créer une offre"
4. Remplir le formulaire
5. Cliquer sur "Publier"

### 3. En Cas d'Erreur
1. Regarder le message d'erreur affiché
2. Cliquer sur "Détails" pour voir l'erreur complète
3. Vérifier les logs dans la console du serveur Django

## Fichiers Modifiés

### Frontend
- `lib/services/api_service.dart` - URL corrigée et logs ajoutés
- `lib/screens/recruiter/offers/create_offer_page.dart` - Gestion d'erreurs améliorée

### Backend
- `jobs/views.py` - Logs de débogage ajoutés
- Scripts de test créés pour diagnostiquer le problème

## Prochaines Étapes

Si le problème persiste :

1. **Vérifier les logs Django** dans la console du serveur
2. **Tester avec un autre utilisateur** recruteur
3. **Vérifier la base de données** directement
4. **Examiner les permissions** de l'utilisateur

## Contact

Si vous avez besoin d'aide supplémentaire, fournissez :
1. Le message d'erreur exact affiché
2. Les logs de la console Django
3. Les étapes exactes que vous avez suivies
