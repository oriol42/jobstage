from django.db import models
from django.contrib.auth import get_user_model
from django.core.validators import MinValueValidator, MaxValueValidator
from django.utils import timezone

User = get_user_model()

class Offre(models.Model):
    TYPE_CONTRAT_CHOICES = [
        ('CDI', 'CDI'),
        ('CDD', 'CDD'),
        ('Stage', 'Stage'),
        ('Freelance', 'Freelance'),
        ('Temps partiel', 'Temps partiel'),
    ]
    
    TYPE_STAGE_CHOICES = [
        ('Stage court', 'Stage court'),
        ('Stage long', 'Stage long'),
        ('PFE', 'PFE'),
    ]
    
    NIVEAU_ETUDES_CHOICES = [
        ('Bac', 'Bac'),
        ('Bac+2', 'Bac+2'),
        ('Bac+3', 'Bac+3'),
        ('Bac+5', 'Bac+5'),
        ('Doctorat', 'Doctorat'),
    ]
    
    NIVEAU_EXPERIENCE_CHOICES = [
        ('Sans expérience', 'Sans expérience'),
        ('Débutant', 'Débutant'),
        ('Intermédiaire', 'Intermédiaire'),
        ('Expérimenté', 'Expérimenté'),
        ('Senior', 'Senior'),
        ('Expert', 'Expert'),
    ]
    
    STATUT_CHOICES = [
        ('active', 'Active'),
        ('expiree', 'Expirée'),
        ('suspendue', 'Suspendue'),
        ('supprimee', 'Supprimée'),
    ]

    # Informations de base
    id = models.AutoField(primary_key=True)
    entreprise = models.ForeignKey('accounts.Entreprise', on_delete=models.CASCADE, related_name='offres')
    titre = models.CharField(max_length=200, verbose_name="Titre du poste")
    description = models.TextField(verbose_name="Description du poste")
    secteur_activite = models.CharField(max_length=100, verbose_name="Secteur d'activité")
    
    # Compétences et localisation
    competences_requises = models.JSONField(default=list, verbose_name="Compétences requises")
    localisation = models.CharField(max_length=200, verbose_name="Localisation")
    
    # Type de contrat
    type_contrat = models.CharField(max_length=20, choices=TYPE_CONTRAT_CHOICES, verbose_name="Type de contrat")
    type_stage = models.CharField(max_length=20, choices=TYPE_STAGE_CHOICES, blank=True, null=True, verbose_name="Type de stage")
    duree_mois = models.PositiveIntegerField(default=0, verbose_name="Durée en mois")
    
    # Rémunération
    salaire_min = models.DecimalField(max_digits=10, decimal_places=0, default=0, verbose_name="Salaire minimum (FCFA)")
    salaire_max = models.DecimalField(max_digits=10, decimal_places=0, default=0, verbose_name="Salaire maximum (FCFA)")
    salaire_text = models.CharField(max_length=100, blank=True, verbose_name="Salaire (texte libre)")
    
    # Niveau requis
    niveau_etudes = models.CharField(max_length=20, choices=NIVEAU_ETUDES_CHOICES, verbose_name="Niveau d'études")
    niveau_experience = models.CharField(max_length=20, choices=NIVEAU_EXPERIENCE_CHOICES, verbose_name="Niveau d'expérience")
    experience_requise = models.PositiveIntegerField(default=0, verbose_name="Expérience requise (années)")
    
    # Dates
    date_publication = models.DateTimeField(default=timezone.now, verbose_name="Date de publication")
    date_expiration = models.DateTimeField(verbose_name="Date d'expiration")
    
    # Statut et statistiques
    statut = models.CharField(max_length=20, choices=STATUT_CHOICES, default='active', verbose_name="Statut")
    nombre_candidats = models.PositiveIntegerField(default=0, verbose_name="Nombre de candidats")
    nombre_candidatures = models.PositiveIntegerField(default=0, verbose_name="Nombre de candidatures")
    
    # Informations supplémentaires
    avantages = models.JSONField(default=list, verbose_name="Avantages")
    processus_recrutement = models.TextField(blank=True, verbose_name="Processus de recrutement")
    
    # Contact
    contact_email = models.EmailField(verbose_name="Email de contact")
    contact_telephone = models.CharField(max_length=20, verbose_name="Téléphone de contact")
    
    # Métadonnées
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    is_active = models.BooleanField(default=True, verbose_name="Offre active")

    class Meta:
        verbose_name = "Offre d'emploi"
        verbose_name_plural = "Offres d'emploi"
        ordering = ['-date_publication']

    def __str__(self):
        return f"{self.titre} - {self.entreprise.nom}"

    @property
    def is_expired(self):
        return timezone.now() > self.date_expiration

    @property
    def salaire_display(self):
        if self.salaire_text:
            return self.salaire_text
        if self.salaire_min == 0 and self.salaire_max == 0:
            return "Non spécifié"
        if self.salaire_min == self.salaire_max:
            return f"{self.salaire_min:,.0f} FCFA"
        return f"{self.salaire_min:,.0f} - {self.salaire_max:,.0f} FCFA"

    @property
    def duree_display(self):
        if self.type_contrat == 'Stage':
            return f"{self.duree_mois} mois"
        return self.get_type_contrat_display()

    def clean(self):
        from django.core.exceptions import ValidationError
        if self.date_expiration <= self.date_publication:
            raise ValidationError("La date d'expiration doit être postérieure à la date de publication")
        if self.salaire_max < self.salaire_min:
            raise ValidationError("Le salaire maximum doit être supérieur au salaire minimum")


class Candidature(models.Model):
    STATUT_CHOICES = [
        ('envoyee', 'Envoyée'),
        ('vue', 'Vue'),
        ('en_cours', 'En cours'),
        ('acceptee', 'Acceptée'),
        ('refusee', 'Refusée'),
    ]

    id = models.AutoField(primary_key=True)
    candidat = models.ForeignKey('accounts.CandidateProfile', on_delete=models.CASCADE, related_name='candidatures')
    offre = models.ForeignKey(Offre, on_delete=models.CASCADE, related_name='candidatures')
    
    # Documents
    cv_path = models.FileField(upload_to='candidatures/cv/', verbose_name="CV")
    lettre_motivation_path = models.FileField(upload_to='candidatures/lettres/', blank=True, null=True, verbose_name="Lettre de motivation")
    
    # Statut et dates
    statut = models.CharField(max_length=20, choices=STATUT_CHOICES, default='envoyee', verbose_name="Statut")
    date_candidature = models.DateTimeField(default=timezone.now, verbose_name="Date de candidature")
    date_vue = models.DateTimeField(blank=True, null=True, verbose_name="Date de consultation")
    
    # Score de matching
    score_matching = models.FloatField(default=0.0, validators=[MinValueValidator(0.0), MaxValueValidator(100.0)], verbose_name="Score de matching (%)")
    
    # Métadonnées
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        verbose_name = "Candidature"
        verbose_name_plural = "Candidatures"
        unique_together = ['candidat', 'offre']
        ordering = ['-date_candidature']

    def __str__(self):
        return f"{self.candidat.user.get_full_name()} - {self.offre.titre}"

    def marquer_vue(self):
        if not self.date_vue:
            self.date_vue = timezone.now()
            self.statut = 'vue'
            self.save(update_fields=['date_vue', 'statut'])


class Favori(models.Model):
    """Modèle pour les offres mises en favori par les candidats"""
    id = models.AutoField(primary_key=True)
    candidat = models.ForeignKey('accounts.CandidateProfile', on_delete=models.CASCADE, related_name='favoris')
    offre = models.ForeignKey(Offre, on_delete=models.CASCADE, related_name='favoris')
    date_ajout = models.DateTimeField(default=timezone.now, verbose_name="Date d'ajout")

    class Meta:
        verbose_name = "Favori"
        verbose_name_plural = "Favoris"
        unique_together = ['candidat', 'offre']
        ordering = ['-date_ajout']

    def __str__(self):
        return f"{self.candidat.user.get_full_name()} - {self.offre.titre}"
