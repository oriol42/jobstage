# 🔍 Guide de Debug - Navigation Recruteur

## 🎯 Objectif

Diagnostiquer précisément pourquoi le bouton de retour redirige vers l'écran de login au lieu de revenir au dashboard.

## 🔧 Logs Ajoutés

### 1. NavigationHelper
- Logs détaillés dans `handleBackNavigation()`
- Logs dans `_redirectToAppropriateScreen()`
- Logs dans `_redirectToLogin()`

### 2. Écrans de Recruteur
- Logs dans `OffersListPage.build()`
- Logs dans `OfferDetailsPage.build()`
- Logs dans `MatchesPage.build()`

## 🧪 Test avec Logs

### 1. Lancer le Test
```bash
cd /home/oriol/Documents/j
./test_navigation_debug.sh
```

### 2. Scénario de Test
1. **Connectez-vous en tant que recruteur**
2. **Allez dans "Offres"**
3. **Cliquez sur une offre** pour voir les détails
4. **Appuyez sur le bouton de retour** (←)
5. **Observez les logs** dans la console

## 📋 Logs à Surveiller

### Logs Normaux (Attendus)
```
🔙 NavigationHelper.handleBackNavigation appelé
   - checkAuth: true
   - fallbackScreen: OffersListPage
   - isLoggedIn: true
   - currentUser: recruteur
   - canPop: true
   - ✅ Retour normal avec pop()
```

### Logs Problématiques (À Investiguer)
```
🔙 NavigationHelper.handleBackNavigation appelé
   - checkAuth: true
   - fallbackScreen: OffersListPage
   - isLoggedIn: false  ← PROBLÈME !
   - currentUser: null  ← PROBLÈME !
   - ❌ Utilisateur non authentifié, redirection vers login
```

## 🔍 Diagnostic des Problèmes

### Problème 1: Utilisateur Non Authentifié
**Symptôme**: `isLoggedIn: false`
**Cause**: Token expiré ou perdu
**Solution**: Vérifier la gestion du token dans AuthService

### Problème 2: Fallback Non Utilisé
**Symptôme**: `canPop: false` mais pas de fallback
**Cause**: NavigationHelper ne fonctionne pas
**Solution**: Vérifier l'implémentation du NavigationHelper

### Problème 3: Redirection Incorrecte
**Symptôme**: Redirection vers login au lieu du fallback
**Cause**: Logique de redirection défaillante
**Solution**: Corriger la logique dans `_redirectToAppropriateScreen()`

## 🚨 Points de Vérification

### 1. Vérifier l'Authentification
```dart
final authService = AuthService();
print('Token: ${authService.token}');
print('User: ${authService.currentUser}');
print('isLoggedIn: ${authService.isLoggedIn}');
```

### 2. Vérifier la Pile de Navigation
```dart
print('canPop: ${Navigator.of(context).canPop()}');
print('Route count: ${Navigator.of(context).widget.initialRoute}');
```

### 3. Vérifier les Fallbacks
```dart
print('fallbackScreen: ${fallbackScreen?.runtimeType}');
```

## 📱 Test avec l'Émulateur

### 1. Lancer l'Application
```bash
cd /home/oriol/Documents/j/frontend/jobstageapp
flutter run
```

### 2. Observer les Logs
Les logs apparaîtront dans la console avec des emojis pour faciliter l'identification :
- 🔙 Navigation
- 📱 Écrans
- ✅ Succès
- ❌ Erreur
- ⚠️ Avertissement
- 🔄 Redirection

## 🔧 Corrections Possibles

### Si `isLoggedIn: false`
1. Vérifier la persistance du token
2. Vérifier l'initialisation d'AuthService
3. Vérifier la synchronisation entre ApiService et AuthService

### Si `canPop: false` sans fallback
1. Vérifier que NavigationHelper est utilisé
2. Vérifier que le fallback est fourni
3. Vérifier la logique de redirection

### Si redirection incorrecte
1. Vérifier la logique dans `_redirectToAppropriateScreen()`
2. Vérifier les conditions d'authentification
3. Vérifier les types d'utilisateur

## 📊 Analyse des Logs

### Logs de Succès
```
🔙 NavigationHelper.handleBackNavigation appelé
   - checkAuth: true
   - fallbackScreen: OffersListPage
   - isLoggedIn: true
   - currentUser: recruteur
   - canPop: true
   - ✅ Retour normal avec pop()
```

### Logs d'Erreur
```
🔙 NavigationHelper.handleBackNavigation appelé
   - checkAuth: true
   - fallbackScreen: OffersListPage
   - isLoggedIn: false
   - currentUser: null
   - ❌ Utilisateur non authentifié, redirection vers login
   - 🔄 Redirection vers login
```

## 🎯 Résultat Attendu

Après le test, vous devriez voir des logs qui montrent :
1. **Navigation normale** avec `canPop: true`
2. **Retour réussi** avec `pop()`
3. **Pas de redirection** vers login

Si vous voyez des redirections vers login, les logs vous indiqueront exactement pourquoi.

---
*Guide de debug créé le $(date)*
