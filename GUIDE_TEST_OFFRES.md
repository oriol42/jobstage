# Guide de Test - Système d'Offres d'Emploi

## 🎯 Objectif
Tester le flux complet de création d'offres par les recruteurs et leur visualisation par les candidats.

## 📋 Prérequis
- Backend Django démarré
- Frontend Flutter compilé et prêt
- Données de test créées

## 🚀 Démarrage du Backend

```bash
cd /home/oriol/Documents/j/backend
source env/bin/activate
python manage.py runserver 0.0.0.0:8000
```

## 📱 Démarrage du Frontend

```bash
cd /home/oriol/Documents/j/frontend/jobstageapp
flutter run
```

## 🔑 Comptes de Test

### Recruteur
- **Username:** `recruteur_test`
- **Password:** `test123`
- **Email:** `recruteur_test@test.com`

### Candidat
- **Username:** `candidat_test`
- **Password:** `test123`
- **Email:** `candidat_test@test.com`

## 🧪 Tests à Effectuer

### 1. Test de Connexion Recruteur
1. Ouvrir l'application Flutter
2. Sélectionner "Recruteur"
3. Se connecter avec les identifiants recruteur
4. Vérifier l'accès au dashboard recruteur

### 2. Test de Création d'Offre
1. Dans le dashboard recruteur, aller à "Mes Offres"
2. Cliquer sur "Créer une nouvelle offre"
3. Remplir le formulaire avec :
   - **Titre:** "Développeur React Native"
   - **Description:** "Développement d'applications mobiles cross-platform"
   - **Type de contrat:** CDI
   - **Localisation:** Yaoundé
   - **Salaire:** 700,000 - 1,000,000 FCFA
   - **Compétences:** React Native, JavaScript, TypeScript
4. Cliquer sur "Publier l'offre"
5. Vérifier que l'offre apparaît dans la liste

### 3. Test de Visualisation Candidat
1. Se déconnecter du compte recruteur
2. Se connecter avec le compte candidat
3. Aller à l'écran "Offres d'Emploi"
4. Vérifier que toutes les offres créées sont visibles :
   - Développeur Flutter Senior
   - Stage Marketing Digital
   - Développeur Web Full-Stack
   - Développeur React Native (nouvellement créée)

### 4. Test de Recherche et Filtres
1. Dans l'écran des offres candidat
2. Tester la barre de recherche avec "Flutter"
3. Tester les filtres :
   - "Emplois" (doit montrer seulement les CDI/CDD)
   - "Stages" (doit montrer seulement les stages)
   - "CDI" (doit filtrer par type de contrat)
   - "Yaoundé" (doit filtrer par localisation)

### 5. Test de Détails d'Offre
1. Cliquer sur une offre pour voir les détails
2. Vérifier que toutes les informations s'affichent correctement :
   - Titre, entreprise, description
   - Salaire, localisation, type de contrat
   - Compétences requises
   - Processus de recrutement

### 6. Test de Favoris
1. Cliquer sur l'icône bookmark d'une offre
2. Vérifier que l'offre est ajoutée aux favoris
3. Aller à l'écran "Favoris" pour vérifier

### 7. Test de Candidature
1. Dans les détails d'une offre, cliquer sur "Postuler maintenant"
2. Vérifier que le message de confirmation s'affiche

## 🔍 Vérifications Backend

### Vérifier les Offres via API
```bash
curl -H "Authorization: Token YOUR_TOKEN" http://localhost:8000/api/jobs/offres/
```

### Vérifier les Statistiques Recruteur
```bash
curl -H "Authorization: Token YOUR_TOKEN" http://localhost:8000/api/jobs/recruteur/statistiques/
```

## 🐛 Problèmes Potentiels et Solutions

### 1. Erreur de Connexion API
- Vérifier que le backend est démarré sur le port 8000
- Vérifier l'adresse IP dans `api_service.dart`

### 2. Offres Non Visibles
- Vérifier que les offres ont le statut "active"
- Vérifier que la date d'expiration n'est pas dépassée
- Vérifier les logs du backend

### 3. Erreurs de Filtres
- Vérifier que les types de contrat correspondent entre frontend et backend
- Vérifier la logique de filtrage dans `filteredOffers`

## ✅ Critères de Succès

- [ ] Les recruteurs peuvent créer des offres
- [ ] Les offres créées apparaissent immédiatement dans l'interface candidat
- [ ] La recherche et les filtres fonctionnent correctement
- [ ] Les détails des offres s'affichent correctement
- [ ] Le système de favoris fonctionne
- [ ] Les candidatures peuvent être soumises

## 📊 Données de Test Disponibles

### Offres Créées
1. **Développeur Flutter Senior** (CDI, Yaoundé)
2. **Stage Marketing Digital** (Stage, Douala)
3. **Développeur Web Full-Stack** (CDD, Yaoundé)

### Utilisateurs
- **Recruteur:** TechCorp Cameroun
- **Candidat:** Marie Martin (Développeuse Mobile)

## 🎉 Résultat Attendu

Le système doit permettre un flux complet :
1. **Recruteur** crée une offre → **Backend** la sauvegarde
2. **Candidat** voit l'offre → **Frontend** récupère depuis l'API
3. **Candidat** peut rechercher, filtrer, et postuler
4. **Recruteur** peut voir les statistiques et candidatures

---

**Note:** Ce guide teste le flux principal. Pour des tests plus approfondis, consultez les logs du backend et les erreurs de la console Flutter.
