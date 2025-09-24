#!/usr/bin/env python3
"""
Script de test pour vérifier que le dashboard du recruteur fonctionne.
"""

import requests
import json

def test_dashboard_recruteur():
    """Tester le dashboard du recruteur"""
    
    print("🔧 Test du dashboard recruteur...")
    
    # 1. Tester la connexion d'un recruteur
    print("\n1. Test de connexion recruteur...")
    
    try:
        login_data = {
            'email': 'recruteur@test.com',
            'password': 'recruteur1234'
        }
        
        response = requests.post(
            'http://192.168.100.61:8000/api/auth/login/',
            json=login_data
        )
        
        if response.status_code == 200:
            data = response.json()
            print("   ✅ Connexion recruteur réussie")
            print(f"   👤 Utilisateur: {data.get('user', {}).get('username')}")
            
            token = data.get('token')
            if token:
                headers = {'Authorization': f'Token {token}'}
                
                # 2. Tester la récupération des offres du recruteur
                print("\n2. Test des offres du recruteur...")
                
                offres_response = requests.get(
                    'http://192.168.100.61:8000/api/jobs/recruteur/offres/',
                    headers=headers
                )
                
                if offres_response.status_code == 200:
                    offres_data = offres_response.json()
                    print(f"   ✅ Offres récupérées: {len(offres_data)} offres")
                    
                    if offres_data:
                        offre = offres_data[0]
                        print(f"   📋 Exemple d'offre:")
                        print(f"      - ID: {offre.get('id')}")
                        print(f"      - Titre: {offre.get('titre')}")
                        print(f"      - Entreprise: {offre.get('entreprise', {}).get('nom', 'N/A')}")
                else:
                    print(f"   ❌ Erreur offres: {offres_response.status_code}")
                    print(f"   Détails: {offres_response.text}")
                
                # 3. Tester la récupération des candidats
                print("\n3. Test des candidats...")
                
                candidats_response = requests.get(
                    'http://192.168.100.61:8000/api/jobs/recruteur/candidats/',
                    headers=headers
                )
                
                if candidats_response.status_code == 200:
                    candidats_data = candidats_response.json()
                    print(f"   ✅ Candidats récupérés: {len(candidats_data.get('results', []))} candidats")
                else:
                    print(f"   ❌ Erreur candidats: {candidats_response.status_code}")
                    print(f"   Détails: {candidats_response.text}")
                
                # 4. Tester la création d'une offre
                print("\n4. Test de création d'offre...")
                
                offre_data = {
                    'titre': 'Test Dashboard - Développeur Flutter',
                    'description': 'Test de création d\'offre depuis le dashboard',
                    'secteur_activite': 'Technologie',
                    'competences_requises': ['Flutter', 'Dart', 'API'],
                    'localisation': 'Douala',
                    'type_contrat': 'CDI',
                    'type_stage': None,
                    'duree_mois': 0,
                    'salaire_min': 600000.0,
                    'salaire_max': 900000.0,
                    'salaire_text': 'Selon profil',
                    'niveau_etudes': 'Bac+3',
                    'niveau_experience': 'Intermédiaire',
                    'experience_requise': 2,
                    'date_expiration': '2024-12-31T23:59:59Z',
                    'contact_email': 'test@test.com',
                    'contact_telephone': '+237 6XX XXX XXX',
                    'is_active': True,
                    'avantages': ['Assurance santé', 'Formation'],
                    'processus_recrutement': 'CV + Entretien technique',
                }
                
                create_response = requests.post(
                    'http://192.168.100.61:8000/api/jobs/offres/',
                    json=offre_data,
                    headers=headers
                )
                
                if create_response.status_code == 201:
                    print("   ✅ Offre créée avec succès")
                    offre_id = create_response.json()['id']
                    print(f"   📋 ID de l'offre: {offre_id}")
                else:
                    print(f"   ❌ Erreur création: {create_response.status_code}")
                    print(f"   Détails: {create_response.text}")
                
        else:
            print(f"   ❌ Erreur de connexion: {response.status_code}")
            print(f"   Détails: {response.text}")
            
    except Exception as e:
        print(f"   ❌ Erreur: {e}")
    
    print("\n✅ Test du dashboard recruteur terminé!")

if __name__ == "__main__":
    test_dashboard_recruteur()
