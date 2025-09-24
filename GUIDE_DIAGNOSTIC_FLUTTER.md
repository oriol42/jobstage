# Guide de Diagnostic - Problème de Création d'Offre Flutter 🔍

## ✅ Backend Fonctionnel

Le backend Django fonctionne parfaitement :
- **Serveur** : ✅ Accessible sur `http://localhost:8000`
- **API** : ✅ Endpoints fonctionnels
- **Création d'offre** : ✅ Test réussi (Status 201)
- **Base de données** : ✅ 5 offres publiques disponibles

## 🔍 Diagnostic du Problème Flutter

Le problème vient de l'application Flutter. Voici comment le diagnostiquer :

### 1. Vérifier les Logs Flutter

**Dans votre application Flutter, regardez la console pour ces messages :**

```
🌐 Envoi de la requête POST vers: http://localhost:8000/api/jobs/offres/
📤 Headers: {Authorization: Token ..., Content-Type: application/json}
📦 Données: {...}
📥 Réponse reçue:
   - Status: XXX
   - Headers: {...}
   - Body: {...}
```

### 2. Problèmes Possibles

#### A. Problème de Connexion
**Symptômes :**
- L'app "tourne" indéfiniment
- Pas de logs dans la console
- Erreur de timeout

**Solutions :**
1. Vérifiez que le serveur Django est démarré :
   ```bash
   cd /home/oriol/Documents/j/backend
   source env/bin/activate
   python manage.py runserver 0.0.0.0:8000
   ```

2. Testez la connexion dans un navigateur :
   - Ouvrez : `http://localhost:8000/api/jobs/offres/public/`
   - Vous devriez voir une liste d'offres en JSON

#### B. Problème d'Authentification
**Symptômes :**
- Status 401 (Non autorisé)
- Status 403 (Accès interdit)
- Message "Utilisateur non authentifié"

**Solutions :**
1. Vérifiez que vous êtes bien connecté :
   - Le token doit être sauvegardé
   - Vérifiez dans les logs : `Authorization: Token ...`

2. Reconnectez-vous si nécessaire

#### C. Problème de Format des Données
**Symptômes :**
- Status 400 (Requête invalide)
- Erreur de validation dans la réponse

**Solutions :**
1. Vérifiez le format des données envoyées
2. Assurez-vous que tous les champs requis sont remplis

### 3. Test de Diagnostic

**Ajoutez ce code temporairement dans votre application Flutter :**

```dart
// Dans votre méthode de création d'offre
void _submitOffer() async {
  print('🚀 Début de la création d\'offre...');
  
  // Test de connectivité
  try {
    final response = await http.get(
      Uri.parse('http://localhost:8000/api/jobs/offres/public/'),
      headers: {'Content-Type': 'application/json'},
    );
    print('✅ Serveur accessible - Status: ${response.statusCode}');
  } catch (e) {
    print('❌ Serveur inaccessible: $e');
    return;
  }
  
  // Test d'authentification
  await ApiService.initialize();
  print('🔑 Token: ${ApiService._token}');
  
  // Reste de votre code...
}
```

### 4. Vérifications Spécifiques

#### A. URL de l'API
Vérifiez dans `lib/services/api_service.dart` :
```dart
static const String baseUrl = 'http://localhost:8000/api';
```

#### B. Headers d'Authentification
Vérifiez que le token est bien inclus :
```dart
static Map<String, String> get _headers {
  Map<String, String> headers = {'Content-Type': 'application/json'};
  if (_token != null) {
    headers['Authorization'] = 'Token $_token';
  }
  return headers;
}
```

#### C. Format des Données
Vérifiez que les données sont bien formatées :
```dart
final offreData = {
  'titre': _titreController.text,
  'description': _descriptionController.text,
  'secteur_activite': 'Technologie',
  'competences_requises': _competencesRequises,
  'localisation': _selectedVilles.join(', '),
  'type_contrat': _selectedTypeContrat,
  'niveau_experience': _selectedNiveauExperience,
  // ... autres champs
};
```

### 5. Solutions par Type d'Erreur

#### Erreur de Connexion
```dart
// Ajoutez un timeout et une gestion d'erreur
final response = await http.post(
  Uri.parse('$jobsUrl/offres/'),
  headers: _headers,
  body: json.encode(offreData),
).timeout(Duration(seconds: 30));
```

#### Erreur d'Authentification
```dart
// Vérifiez le token avant l'envoi
if (_token == null) {
  print('❌ Aucun token d\'authentification');
  // Rediriger vers la page de connexion
  return;
}
```

#### Erreur de Validation
```dart
// Vérifiez les données avant l'envoi
if (_titreController.text.isEmpty) {
  print('❌ Titre requis');
  return;
}
```

### 6. Test Manuel

**Pour tester manuellement :**

1. **Ouvrez un navigateur** et allez sur :
   `http://localhost:8000/api/jobs/offres/public/`

2. **Vous devriez voir** une liste d'offres en JSON

3. **Si ça ne marche pas**, le serveur n'est pas démarré

### 7. Logs à Surveiller

**Dans la console Flutter, cherchez :**
- `🌐 Envoi de la requête POST vers: ...`
- `📥 Réponse reçue:`
- `✅ Offre créée avec succès!` ou `❌ Erreur...`

## 🎯 Prochaines Étapes

1. **Lancez l'application Flutter**
2. **Essayez de créer une offre**
3. **Regardez les logs dans la console**
4. **Identifiez le type d'erreur** (connexion, auth, validation)
5. **Appliquez la solution correspondante**

## 📞 Support

Si le problème persiste, partagez :
1. **Les logs de la console Flutter**
2. **Le message d'erreur exact**
3. **Le statut de la réponse HTTP**

---

**Le backend fonctionne parfaitement, le problème est dans l'application Flutter !** 🎯
