from django.db.models.signals import post_save
from django.dispatch import receiver
from .models import User, CandidateProfile, Entreprise


@receiver(post_save, sender=User)
def create_user_profile(sender, instance, created, **kwargs):
    """
    Crée automatiquement un profil approprié quand un utilisateur est créé
    """
    if created:
        if instance.user_type == 'candidat':
            # Créer un profil candidat
            CandidateProfile.objects.create(user=instance)
            print(f"✅ Profil candidat créé pour {instance.username}")
        elif instance.user_type == 'recruteur':
            # Créer une entreprise pour le recruteur
            Entreprise.objects.create(
                administrateur=instance,
                nom=f"Entreprise de {instance.username}",
                description="Description à compléter",
                secteur_activite="À définir"
            )
            print(f"✅ Entreprise créée pour {instance.username}")


@receiver(post_save, sender=User)
def save_user_profile(sender, instance, **kwargs):
    """
    Sauvegarde le profil quand l'utilisateur est sauvegardé
    """
    if hasattr(instance, 'candidate_profile'):
        instance.candidate_profile.save()
    elif hasattr(instance, 'entreprise'):
        instance.entreprise.save()
