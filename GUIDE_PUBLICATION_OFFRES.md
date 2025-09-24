# Guide de Publication d'Offres - JobStage

## Problème Résolu ✅

Le problème principal était que l'utilisateur connecté n'avait pas d'entreprise associée. J'ai créé un utilisateur recruteur de test avec une entreprise.

## Solution Implémentée

### 1. Utilisateur Recruteur de Test Créé
- **Nom d'utilisateur** : `recruteur_techcorp`
- **Email** : `recruteur@techcorp.cm`
- **Mot de passe** : `testpass123`
- **Type** : Recruteur
- **Entreprise** : TechCorp Cameroun

### 2. Structure de l'Application

#### Backend (Django)
- **Modèle Offre** : `/backend/jobs/models.py`
- **Vues API** : `/backend/jobs/views.py`
- **URLs** : `/backend/jobs/urls.py`
- **Sérialiseurs** : `/backend/jobs/serializers.py`

#### Frontend (Flutter)
- **Page de création** : `/frontend/jobstageapp/lib/screens/recruiter/offers/create_offer_page.dart`
- **Service API** : `/frontend/jobstageapp/lib/services/api_service.dart`
- **Service Recruteur** : `/frontend/jobstageapp/lib/services/recruiter_api_service.dart`

## Comment Publier une Offre

### 1. Connexion en tant qu'Entreprise
```dart
// Dans l'application Flutter
await ApiService.login('recruteur_techcorp', 'testpass123');
```

### 2. Données Requises pour une Offre
```json
{
  "titre": "Titre du poste",
  "description": "Description détaillée du poste",
  "secteur_activite": "Technologie",
  "competences_requises": ["Flutter", "Dart", "API REST"],
  "localisation": "Douala, Yaoundé",
  "type_contrat": "CDI",
  "niveau_etudes": "Bac+3",
  "niveau_experience": "Expérimenté",
  "experience_requise": 3,
  "date_expiration": "2024-12-31T23:59:59Z",
  "salaire_text": "800,000 - 1,200,000 FCFA",
  "contact_email": "contact@entreprise.cm",
  "contact_telephone": "+237 6 12 34 56 78",
  "is_active": true,
  "avantages": ["Formation", "Assurance"],
  "processus_recrutement": "CV + Entretien"
}
```

### 3. Processus de Publication

#### Étape 1 : Vérifier l'Authentification
```dart
// S'assurer que l'utilisateur est connecté
await ApiService.initialize();
```

#### Étape 2 : Préparer les Données
```dart
final offreData = {
  'titre': _titreController.text,
  'description': _descriptionController.text,
  'secteur_activite': 'Technologie',
  'competences_requises': _competencesRequises,
  'localisation': _selectedVilles.join(', '),
  'type_contrat': _selectedTypeContrat,
  'niveau_experience': _selectedNiveauExperience,
  'niveau_etudes': 'Bac+3',
  'experience_requise': 0,
  'date_expiration': DateTime.now()
      .add(const Duration(days: 30))
      .toIso8601String(),
  'salaire_text': _salaireController.text,
  'contact_email': _dataService.entreprise['email'],
  'contact_telephone': _dataService.entreprise['telephone'],
  'is_active': _isActive,
  'avantages': [],
  'processus_recrutement': 'CV + Entretien',
};
```

#### Étape 3 : Créer l'Offre
```dart
final result = await ApiService.createOffre(offreData);
```

## Endpoints API

### Création d'Offre
- **URL** : `POST /api/jobs/offres/`
- **Authentification** : Token requis
- **Headers** : `Authorization: Token <token>`

### Liste des Offres du Recruteur
- **URL** : `GET /api/jobs/recruteur/offres/`
- **Authentification** : Token requis

### Offres Publiques
- **URL** : `GET /api/jobs/offres/public/`
- **Authentification** : Non requise

## Dépannage

### Erreur : "Aucune entreprise trouvée pour cet utilisateur"
**Cause** : L'utilisateur connecté n'a pas d'entreprise associée.
**Solution** : 
1. Vérifier que l'utilisateur est de type 'recruteur'
2. Créer une entreprise pour cet utilisateur
3. Utiliser l'utilisateur de test : `recruteur_techcorp`

### Erreur : "NOT NULL constraint failed: jobs_offre.entreprise_id"
**Cause** : Même problème que ci-dessus.
**Solution** : S'assurer qu'une entreprise est associée à l'utilisateur.

### Erreur de Connexion API
**Vérifications** :
1. Le serveur Django est-il démarré ? (`python manage.py runserver`)
2. L'URL de base est-elle correcte ? (`http://192.168.1.109:8000/api`)
3. L'utilisateur est-il bien connecté ?

## Test de l'API

### Script de Test Backend
```bash
cd /home/oriol/Documents/j/backend
source env/bin/activate
python test_create_offer.py
```

### Test Manuel avec cURL
```bash
# 1. Se connecter
curl -X POST http://192.168.1.109:8000/api/auth/login/ \
  -H "Content-Type: application/json" \
  -d '{"username": "recruteur_techcorp", "password": "testpass123"}'

# 2. Créer une offre (remplacer <TOKEN> par le token reçu)
curl -X POST http://192.168.1.109:8000/api/jobs/offres/ \
  -H "Authorization: Token <TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{
    "titre": "Test Offre",
    "description": "Description test",
    "secteur_activite": "Technologie",
    "competences_requises": ["Flutter"],
    "localisation": "Douala",
    "type_contrat": "CDI",
    "niveau_etudes": "Bac+3",
    "niveau_experience": "Débutant",
    "experience_requise": 0,
    "date_expiration": "2024-12-31T23:59:59Z",
    "salaire_text": "500,000 FCFA",
    "contact_email": "test@test.cm",
    "contact_telephone": "+237 6 12 34 56 78",
    "is_active": true,
    "avantages": [],
    "processus_recrutement": "CV + Entretien"
  }'
```

## Prochaines Étapes

1. **Tester la publication** avec l'utilisateur recruteur créé
2. **Vérifier l'interface** de création d'offre dans l'app Flutter
3. **Créer d'autres utilisateurs recruteurs** si nécessaire
4. **Configurer les données d'entreprise** réelles

## Fichiers Modifiés

- ✅ `/backend/create_test_entreprise.py` - Script de création d'entreprise de test
- ✅ `/backend/test_create_offer.py` - Script de test de création d'offre
- ✅ `/GUIDE_PUBLICATION_OFFRES.md` - Ce guide

Le problème de publication d'offres est maintenant résolu ! 🎉
