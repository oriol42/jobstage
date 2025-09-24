#!/usr/bin/env python3
"""
Script de test pour vérifier la cohérence entre le backend et le frontend.
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
from jobs.models import Offre

User = get_user_model()

def test_consistency():
    """Tester la cohérence entre backend et frontend"""
    
    print("🔧 Test de cohérence Backend-Frontend...")
    
    # 1. Vérifier les champs du modèle Offre
    print("\n1. Vérification des champs du modèle Offre...")
    
    # Obtenir les champs du modèle
    offre_fields = [field.name for field in Offre._meta.fields]
    print(f"   Champs backend: {offre_fields}")
    
    # Champs attendus par le frontend
    expected_fields = [
        'id', 'entreprise', 'titre', 'description', 'secteur_activite',
        'competences_requises', 'localisation', 'type_contrat', 'type_stage',
        'duree_mois', 'salaire_min', 'salaire_max', 'salaire_text',
        'niveau_etudes', 'niveau_experience', 'experience_requise',
        'date_publication', 'date_expiration', 'statut', 'nombre_candidats',
        'nombre_candidatures', 'avantages', 'processus_recrutement',
        'contact_email', 'contact_telephone', 'is_active'
    ]
    
    missing_fields = [field for field in expected_fields if field not in offre_fields]
    extra_fields = [field for field in offre_fields if field not in expected_fields]
    
    if missing_fields:
        print(f"   ❌ Champs manquants: {missing_fields}")
    else:
        print("   ✅ Tous les champs attendus sont présents")
    
    if extra_fields:
        print(f"   ⚠️  Champs supplémentaires: {extra_fields}")
    
    # 2. Tester la création d'une offre
    print("\n2. Test de création d'offre...")
    
    try:
        # Créer un token pour le recruteur
        recruteur = User.objects.get(username='recruteur_test')
        token, created = Token.objects.get_or_create(user=recruteur)
        
        # Données de test
        offre_data = {
            'titre': 'Développeur Flutter Senior',
            'description': 'Recherche d\'un développeur Flutter expérimenté',
            'secteur_activite': 'Technologie',
            'competences_requises': ['Flutter', 'Dart', 'Firebase'],
            'localisation': 'Douala, Yaoundé',
            'type_contrat': 'CDI',
            'type_stage': None,
            'duree_mois': 0,
            'salaire_min': 500000,
            'salaire_max': 800000,
            'salaire_text': 'Selon profil',
            'niveau_etudes': 'Bac+3',
            'niveau_experience': 'Expérimenté',
            'experience_requise': 3,
            'date_expiration': '2024-12-31T23:59:59Z',
            'contact_email': 'contact@test.com',
            'contact_telephone': '+237 6XX XXX XXX',
            'is_active': True,
            'avantages': ['Assurance santé', 'Télétravail'],
            'processus_recrutement': 'CV + Entretien technique + Entretien RH',
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
            
            # Vérifier que l'offre est accessible publiquement
            public_response = requests.get('http://localhost:8000/api/jobs/offres/public/')
            if public_response.status_code == 200:
                offres = public_response.json()
                if any(offre['id'] == offre_id for offre in offres):
                    print("   ✅ Offre accessible publiquement")
                else:
                    print("   ❌ Offre non accessible publiquement")
            else:
                print("   ❌ Erreur lors de l'accès public")
                
        else:
            print(f"   ❌ Erreur lors de la création: {response.status_code}")
            print(f"   Détails: {response.text}")
            
    except Exception as e:
        print(f"   ❌ Erreur: {e}")
    
    # 3. Vérifier la structure des données retournées
    print("\n3. Vérification de la structure des données...")
    
    try:
        response = requests.get('http://localhost:8000/api/jobs/offres/public/')
        if response.status_code == 200:
            offres = response.json()
            if offres:
                offre = offres[0]
                print(f"   Structure de l'offre: {list(offre.keys())}")
                
                # Vérifier les champs critiques
                critical_fields = ['id', 'titre', 'description', 'entreprise', 'salaire_min', 'salaire_max']
                missing_critical = [field for field in critical_fields if field not in offre]
                
                if missing_critical:
                    print(f"   ❌ Champs critiques manquants: {missing_critical}")
                else:
                    print("   ✅ Tous les champs critiques sont présents")
            else:
                print("   ⚠️  Aucune offre trouvée")
        else:
            print(f"   ❌ Erreur lors de la récupération: {response.status_code}")
            
    except Exception as e:
        print(f"   ❌ Erreur: {e}")
    
    print("\n✅ Test de cohérence terminé!")

if __name__ == "__main__":
    test_consistency()
