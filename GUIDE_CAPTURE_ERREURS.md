# Guide de Capture d'Erreurs - Création d'Offres 🔍

## ✅ Nouveau Recruteur Créé

**Identifiants de test :**
- **Nom d'utilisateur** : `recruteur_test_1`
- **Mot de passe** : `testpass123`
- **Entreprise** : Entreprise Test

## 🚀 Code de Capture d'Erreurs Implémenté

### 1. **API Service Amélioré** (`lib/services/api_service.dart`)

#### ✅ Gestion d'erreurs détaillée
- Capture des messages d'erreur du serveur
- Parsing des erreurs de validation
- Messages d'erreur explicites

#### ✅ Test de connectivité
- Vérification de la connexion au serveur
- Test d'authentification
- Timeout configuré

#### ✅ Logs détaillés
```dart
print('🌐 Envoi de la requête POST vers: $jobsUrl/offres/');
print('📤 Headers: $_headers');
print('📦 Données: ${json.encode(offreData)}');
print('📥 Réponse reçue: Status: ${response.statusCode}');
```

### 2. **Page de Test** (`lib/screens/test_error_capture.dart`)

#### ✅ Interface de diagnostic
- Test de connectivité
- Test d'authentification
- Test de création d'offre
- Affichage des erreurs détaillées

#### ✅ Capture d'erreurs complète
- Messages d'erreur du serveur
- Stack trace complet
- Détails de validation

## 📱 Comment Utiliser

### 1. **Ajouter la Page de Test à votre App**

Dans votre `main.dart` ou routeur, ajoutez :

```dart
import 'screens/test_error_capture.dart';

// Dans vos routes
'/test-errors': (context) => const TestErrorCapturePage(),
```

### 2. **Tester avec le Nouveau Recruteur**

1. **Connectez-vous** avec :
   - Nom d'utilisateur : `recruteur_test_1`
   - Mot de passe : `testpass123`

2. **Allez sur la page de test** : `/test-errors`

3. **Exécutez les tests** dans l'ordre :
   - Test de connectivité
   - Test d'authentification
   - Test de création d'offre

### 3. **Analyser les Erreurs**

#### A. **Erreurs de Connexion**
```
❌ Problème de connectivité: SocketException: Failed to connect
```
**Solution :** Vérifiez que le serveur Django est démarré

#### B. **Erreurs d'Authentification**
```
❌ Aucun token d'authentification trouvé
```
**Solution :** Reconnectez-vous dans l'app

#### C. **Erreurs de Validation**
```
❌ Erreur lors de la création:
titre: Ce champ est requis
description: Ce champ ne peut pas être vide
```
**Solution :** Remplissez tous les champs requis

#### D. **Erreurs de Serveur**
```
❌ Erreur serveur (500)
Détails: NOT NULL constraint failed: jobs_offre.entreprise_id
```
**Solution :** Problème de configuration backend

## 🔧 Code de Capture d'Erreurs dans votre App

### 1. **Dans votre page de création d'offre existante**

Le code est déjà amélioré avec :
- Logs détaillés
- Capture d'erreurs complète
- Affichage des détails d'erreur

### 2. **Utilisation du Service API**

```dart
try {
  final result = await ApiService.createOffre(offreData);
  if (result != null) {
    // Succès
    print('✅ Offre créée: ${result['titre']}');
  }
} catch (e) {
  // Erreur capturée avec détails
  print('❌ Erreur: $e');
  // Afficher l'erreur à l'utilisateur
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('Erreur: $e'),
      backgroundColor: Colors.red,
      action: SnackBarAction(
        label: 'Détails',
        onPressed: () => _showErrorDetails(e),
      ),
    ),
  );
}
```

## 📊 Types d'Erreurs Capturées

### 1. **Erreurs de Connexion**
- `SocketException` : Serveur inaccessible
- `TimeoutException` : Délai d'attente dépassé
- `ConnectionError` : Problème de réseau

### 2. **Erreurs d'Authentification**
- Status 401 : Token invalide
- Status 403 : Accès interdit
- Token manquant

### 3. **Erreurs de Validation**
- Status 400 : Données invalides
- Champs requis manquants
- Format de données incorrect

### 4. **Erreurs de Serveur**
- Status 500 : Erreur interne
- Problèmes de base de données
- Erreurs de configuration

## 🎯 Test Complet

### 1. **Démarrez le serveur Django**
```bash
cd /home/oriol/Documents/j/backend
source env/bin/activate
python manage.py runserver 0.0.0.0:8000
```

### 2. **Lancez l'application Flutter**
```bash
cd /home/oriol/Documents/j/frontend/jobstageapp
flutter run
```

### 3. **Testez la création d'offre**
1. Connectez-vous avec `recruteur_test_1` / `testpass123`
2. Allez sur la page de création d'offre
3. Remplissez le formulaire
4. Cliquez sur "Publier"
5. Regardez les logs dans la console

### 4. **Analysez les résultats**
- **Succès** : Offre créée avec ID
- **Erreur** : Message d'erreur détaillé affiché

## 📝 Logs à Surveiller

### Dans la Console Flutter :
```
🌐 Envoi de la requête POST vers: http://localhost:8000/api/jobs/offres/
📤 Headers: {Authorization: Token ..., Content-Type: application/json}
📦 Données: {"titre": "...", "description": "..."}
📥 Réponse reçue: Status: 201
✅ Offre créée avec succès: {id: 123, titre: "..."}
```

### En cas d'erreur :
```
❌ Erreur HTTP 400: {"titre": ["Ce champ est requis"]}
❌ Exception lors de la création d'offre:
   Erreur: Requête invalide (400)
   Détails: titre: Ce champ est requis
```

## 🚀 Prochaines Étapes

1. **Testez avec votre nouveau recruteur**
2. **Identifiez le type d'erreur** dans les logs
3. **Appliquez la solution** correspondante
4. **Partagez les logs** si le problème persiste

---

**Le code de capture d'erreurs est maintenant prêt !** 🎉

Utilisez les identifiants `recruteur_test_1` / `testpass123` pour tester et voir les erreurs détaillées.
