#!/usr/bin/env python3
"""
Script de test pour vérifier que les corrections fonctionnent.
"""

import os
import sys
import django
import requests
import json

# Configuration Django
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'jobstage_backend.settings')
django.setup()

from django.contrib.auth import get_user_model
from rest_framework.authtoken.models import Token

User = get_user_model()

def test_fixes():
    """Tester que les corrections fonctionnent"""
    
    print("🔧 Test des corrections...")
    
    # 1. Tester l'endpoint public des offres
    print("\n1. Test de l'endpoint public des offres...")
    
    try:
        response = requests.get('http://localhost:8000/api/jobs/offres/public/')
        
        if response.status_code == 200:
            data = response.json()
            print(f"   ✅ Endpoint public accessible: {len(data)} offres")
            
            if data:
                offre = data[0]
                print(f"   📋 Structure de l'offre:")
                print(f"      - ID: {offre.get('id')}")
                print(f"      - Titre: {offre.get('titre')}")
                print(f"      - Salaire min: {offre.get('salaire_min')} (type: {type(offre.get('salaire_min'))})")
                print(f"      - Salaire max: {offre.get('salaire_max')} (type: {type(offre.get('salaire_max'))})")
                print(f"      - Entreprise: {offre.get('entreprise_nom', 'N/A')}")
        else:
            print(f"   ❌ Erreur: {response.status_code}")
            print(f"   Détails: {response.text}")
            
    except Exception as e:
        print(f"   ❌ Erreur: {e}")
    
    # 2. Tester la création d'une offre
    print("\n2. Test de création d'offre...")
    
    try:
        # Créer un token pour le recruteur
        recruteur = User.objects.get(username='recruteur_test')
        token, created = Token.objects.get_or_create(user=recruteur)
        
        # Données de test avec types corrects
        offre_data = {
            'titre': 'Test Développeur Flutter',
            'description': 'Test de création d\'offre',
            'secteur_activite': 'Technologie',
            'competences_requises': ['Flutter', 'Dart'],
            'localisation': 'Douala',
            'type_contrat': 'CDI',
            'type_stage': None,
            'duree_mois': 0,
            'salaire_min': 500000.0,  # Float au lieu de int
            'salaire_max': 800000.0,  # Float au lieu de int
            'salaire_text': 'Selon profil',
            'niveau_etudes': 'Bac+3',
            'niveau_experience': 'Expérimenté',
            'experience_requise': 3,
            'date_expiration': '2024-12-31T23:59:59Z',
            'contact_email': 'test@test.com',
            'contact_telephone': '+237 6XX XXX XXX',
            'is_active': True,
            'avantages': ['Assurance santé'],
            'processus_recrutement': 'CV + Entretien',
        }
        
        # Créer l'offre via l'API
        headers = {'Authorization': f'Token {token.key}'}
        response = requests.post(
            'http://localhost:8000/api/jobs/offres/',
            json=offre_data,
            headers=headers
        )
        
        if response.status_code == 201:
            print("   ✅ Offre créée avec succès")
            offre_id = response.json()['id']
            print(f"   📋 ID de l'offre: {offre_id}")
        else:
            print(f"   ❌ Erreur lors de la création: {response.status_code}")
            print(f"   Détails: {response.text}")
            
    except Exception as e:
        print(f"   ❌ Erreur: {e}")
    
    # 3. Tester l'authentification candidat
    print("\n3. Test d'authentification candidat...")
    
    try:
        # Tester la connexion d'un candidat
        login_data = {
            'email': 'lyode@gmail.com',
            'password': 'lyode1234'
        }
        
        response = requests.post(
            'http://localhost:8000/api/auth/login/',
            json=login_data
        )
        
        if response.status_code == 200:
            data = response.json()
            print("   ✅ Connexion candidat réussie")
            print(f"   👤 Utilisateur: {data.get('user', {}).get('username')}")
            
            # Tester la récupération du profil
            token = data.get('token')
            if token:
                headers = {'Authorization': f'Token {token}'}
                profile_response = requests.get(
                    'http://localhost:8000/api/auth/profile/',
                    headers=headers
                )
                
                if profile_response.status_code == 200:
                    profile_data = profile_response.json()
                    print("   ✅ Profil récupéré avec succès")
                    print(f"   📋 Profil: {profile_data.get('profile') is not None}")
                else:
                    print(f"   ❌ Erreur profil: {profile_response.status_code}")
                    print(f"   Détails: {profile_response.text}")
        else:
            print(f"   ❌ Erreur de connexion: {response.status_code}")
            print(f"   Détails: {response.text}")
            
    except Exception as e:
        print(f"   ❌ Erreur: {e}")
    
    print("\n✅ Test des corrections terminé!")

if __name__ == "__main__":
    test_fixes()
