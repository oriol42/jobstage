# Jobstage App

Application Flutter pour la plateforme de mise en relation emploi et stage développée par CENADI.

## Fonctionnalités

- **Splash Screen** : Écran d'accueil avec animation du logo et du texte "JOBSTAGE"
- **Sélection d'utilisateur** : Interface pour choisir entre Candidat et Recruteur
- **Design moderne** : Interface utilisateur élégante avec Material Design 3
- **Animations fluides** : Transitions et animations pour une expérience utilisateur optimale

## Structure du projet

```
lib/
├── main.dart              # Point d'entrée de l'application
├── splash_screen.dart     # Écran de démarrage avec animations
├── user_selection.dart    # Page de sélection du type d'utilisateur
└── loginscreen.dart       # Écran de connexion (à développer)

assets/
├── images/               # Images de l'application
│   ├── jobstage_logo.png
│   ├── logoapp.png
│   ├── google_logo.png
│   └── facebook_logo.png
└── icons/                # Icônes pour les rôles
    ├── icandidat.jpeg
    └── ientreprise.jpeg
```

## Installation et exécution

1. **Prérequis** :
   - Flutter SDK installé
   - Android Studio ou VS Code avec extension Flutter
   - Émulateur Android ou appareil physique

2. **Installation des dépendances** :
   ```bash
   flutter pub get
   ```

3. **Exécution de l'application** :
   ```bash
   flutter run
   ```

## Dépendances

- `google_fonts: ^6.2.1` - Polices Google personnalisées
- `url_launcher: ^6.2.5` - Ouverture de liens externes
- `cupertino_icons: ^1.0.8` - Icônes iOS

## Navigation

1. **Splash Screen** : S'affiche au démarrage avec animations (2 secondes)
2. **User Selection** : Page de sélection entre Candidat et Recruteur
3. **Pages de développement** : Espaces Candidat et Recruteur (à développer)

## Développement futur

- Intégration de l'authentification
- Développement des espaces Candidat et Recruteur
- Intégration avec une API backend
- Gestion des offres d'emploi et de stage
- Système de matching intelligent

## Auteur

Développé par CENADI (Centre National de Développement Informatique)
Site web : https://www.cenadi.cm/