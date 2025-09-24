# Guide de Debug - Problème de Création d'Offre Flutter 🔍

## 🎯 Problème Identifié

Le **backend fonctionne parfaitement** (Status 201), mais l'**application Flutter** ne peut pas créer d'offres. Le problème est côté frontend.

## 🔧 Solution : Page de Debug

J'ai créé une page de debug spéciale pour identifier le problème exact.

### 1. **Ajouter la Page de Debug**

Dans votre `main.dart` ou routeur, ajoutez :

```dart
import 'screens/debug_creation_offre.dart';

// Dans vos routes
'/debug-offre': (context) => const DebugCreationOffrePage(),
```

### 2. **Utiliser la Page de Debug**

1. **Lancez l'application Flutter**
2. **Naviguez vers** `/debug-offre`
3. **Exécutez les tests** dans l'ordre :
   - **Test Connectivité** : Vérifie si l'app peut accéder au serveur
   - **Test Auth** : Vérifie si l'utilisateur est connecté
   - **Test Création d'Offre** : Teste la création d'offre

### 3. **Analyser les Résultats**

#### A. **Test de Connectivité**
```
✅ Connectivité OK - 5 offres trouvées
```
**= Le serveur est accessible**

```
❌ Problème de connectivité: SocketException: Failed to connect
```
**= Problème de réseau ou URL incorrecte**

#### B. **Test d'Authentification**
```
✅ Authentification OK - Token: 132eb1bfdff29c9c45b9...
```
**= L'utilisateur est connecté**

```
❌ Aucun token d'authentification trouvé
```
**= L'utilisateur n'est pas connecté**

#### C. **Test de Création d'Offre**
```
✅ Offre créée avec succès!
   - ID: 123
   - Titre: Test Offre
```
**= Tout fonctionne parfaitement**

```
❌ Erreur lors de la création:
   SocketException: Failed to connect
```
**= Problème de connexion**

## 🔍 Problèmes Possibles et Solutions

### 1. **Problème de Connexion**

#### Symptômes :
- Test de connectivité échoue
- Erreur `SocketException`

#### Solutions :
1. **Vérifiez l'URL** dans `lib/services/api_service.dart` :
   ```dart
   static const String baseUrl = 'http://localhost:8000/api';
   ```

2. **Changez l'URL** si nécessaire :
   ```dart
   // Pour émulateur Android
   static const String baseUrl = 'http://10.0.2.2:8000/api';
   
   // Pour IP locale
   static const String baseUrl = 'http://192.168.100.59:8000/api';
   ```

3. **Vérifiez que le serveur Django est démarré** :
   ```bash
   cd /home/oriol/Documents/j/backend
   source env/bin/activate
   python manage.py runserver 0.0.0.0:8000
   ```

### 2. **Problème d'Authentification**

#### Symptômes :
- Test d'authentification échoue
- Token null

#### Solutions :
1. **Connectez-vous d'abord** dans l'app
2. **Vérifiez que le token est sauvegardé**
3. **Reconnectez-vous** si nécessaire

### 3. **Problème de Format des Données**

#### Symptômes :
- Test de connectivité et auth OK
- Création d'offre échoue avec erreur 400

#### Solutions :
1. **Vérifiez les données** envoyées
2. **Remplissez tous les champs** requis
3. **Vérifiez le format** des dates et autres données

## 📱 Test Complet

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

### 3. **Connectez-vous**
- Email : `jobs@innovationtech.cm`
- Mot de passe : `innovation2024`

### 4. **Allez sur la page de debug**
- Naviguez vers `/debug-offre`
- Exécutez tous les tests
- Analysez les résultats

### 5. **Partagez les résultats**
- Copiez les logs de debug
- Identifiez le problème exact
- Appliquez la solution correspondante

## 🎯 URLs à Tester

Si `localhost` ne fonctionne pas, essayez :

```dart
// Pour émulateur Android
static const String baseUrl = 'http://10.0.2.2:8000/api';

// Pour IP locale (remplacez par votre IP)
static const String baseUrl = 'http://192.168.100.59:8000/api';

// Pour IP spécifique
static const String baseUrl = 'http://192.168.1.109:8000/api';
```

## 📊 Logs à Surveiller

### Dans la Console Flutter :
```
🌐 Envoi de la requête POST vers: http://localhost:8000/api/jobs/offres/
📤 Headers: {Authorization: Token ..., Content-Type: application/json}
📦 Données: {"titre": "...", "description": "..."}
📥 Réponse reçue: Status: 201
✅ Offre créée avec succès: {titre: "...", localisation: "..."}
```

### En cas d'erreur :
```
❌ Problème de connectivité: SocketException: Failed to connect
❌ Aucun token d'authentification trouvé
❌ Erreur HTTP 400: {"titre": ["Ce champ est requis"]}
```

## 🚀 Prochaines Étapes

1. **Utilisez la page de debug** pour identifier le problème exact
2. **Partagez les logs** que vous obtenez
3. **Appliquez la solution** correspondante
4. **Testez à nouveau** jusqu'à ce que tout fonctionne

---

**La page de debug va nous dire exactement où est le problème !** 🎯

Utilisez `/debug-offre` dans votre app et partagez-moi les résultats.
