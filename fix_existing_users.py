#!/usr/bin/env python
"""
Script pour corriger les utilisateurs existants qui n'ont pas de profil
"""
import os
import sys
import django

# Configuration Django
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'jobstage_backend.settings')
django.setup()

from accounts.models import User, CandidateProfile, RecruiterProfile

def fix_existing_users():
    """Corrige les utilisateurs existants qui n'ont pas de profil"""
    print("🔧 Correction des utilisateurs existants...")
    
    # Utilisateurs candidats sans profil
    candidats_sans_profil = User.objects.filter(
        user_type='candidat'
    ).exclude(
        id__in=CandidateProfile.objects.values_list('user_id', flat=True)
    )
    
    print(f"📊 Candidats sans profil: {candidats_sans_profil.count()}")
    
    for user in candidats_sans_profil:
        try:
            CandidateProfile.objects.create(user=user)
            print(f"✅ Profil candidat créé pour {user.username} ({user.email})")
        except Exception as e:
            print(f"❌ Erreur pour {user.username}: {e}")
    
    # Utilisateurs recruteurs sans profil
    recruteurs_sans_profil = User.objects.filter(
        user_type='recruteur'
    ).exclude(
        id__in=RecruiterProfile.objects.values_list('user_id', flat=True)
    )
    
    print(f"📊 Recruteurs sans profil: {recruteurs_sans_profil.count()}")
    
    for user in recruteurs_sans_profil:
        try:
            RecruiterProfile.objects.create(user=user)
            print(f"✅ Profil recruteur créé pour {user.username} ({user.email})")
        except Exception as e:
            print(f"❌ Erreur pour {user.username}: {e}")
    
    print("✅ Correction terminée!")

if __name__ == "__main__":
    fix_existing_users()
