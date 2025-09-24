from django.contrib.auth.models import AbstractUser, BaseUserManager
from django.db import models
from django.conf import settings


class UserManager(BaseUserManager):
    """Gestionnaire personnalisé pour le modèle User"""
    
    def create_user(self, username, email, phone=None, password=None, **extra_fields):
        if not email:
            raise ValueError('L\'email est obligatoire')
        email = self.normalize_email(email)
        user = self.model(username=username, email=email, phone=phone, **extra_fields)
        user.set_password(password)
        user.save(using=self._db)
        return user
    
    def create_superuser(self, username, email, phone=None, password=None, **extra_fields):
        extra_fields.setdefault('is_staff', True)
        extra_fields.setdefault('is_superuser', True)
        extra_fields.setdefault('user_type', 'recruteur')
        
        if extra_fields.get('is_staff') is not True:
            raise ValueError('Le superutilisateur doit avoir is_staff=True.')
        if extra_fields.get('is_superuser') is not True:
            raise ValueError('Le superutilisateur doit avoir is_superuser=True.')
            
        return self.create_user(username, email, phone, password, **extra_fields)


class User(AbstractUser):
    """Modèle utilisateur personnalisé"""
    USER_TYPE_CHOICES = [
        ('candidat', 'Candidat'),
        ('recruteur', 'Recruteur'),
    ]
    
    user_type = models.CharField(
        max_length=10,
        choices=USER_TYPE_CHOICES,
        default='candidat'
    )
    email = models.EmailField(unique=True)
    phone = models.CharField(max_length=15, unique=True, blank=True, null=True)
    is_verified = models.BooleanField(default=False)
    
    # Champs pour les candidats
    localisation = models.CharField(max_length=100, blank=True, null=True)
    domaine_etude = models.CharField(max_length=100, blank=True, null=True)
    niveau_etude = models.CharField(max_length=50, blank=True, null=True)
    annee_diplome = models.IntegerField(blank=True, null=True)
    universite = models.CharField(max_length=200, blank=True, null=True)
    competences = models.JSONField(default=list, blank=True)
    experiences = models.JSONField(default=list, blank=True)
    cv_path = models.CharField(max_length=500, blank=True, null=True)
    lettre_motivation_path = models.CharField(max_length=500, blank=True, null=True)
    disponible = models.BooleanField(default=True)
    preferences = models.JSONField(default=dict, blank=True)
    score_matching = models.FloatField(default=0.0)
    
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    objects = UserManager()
    
    USERNAME_FIELD = 'email'
    REQUIRED_FIELDS = ['username']

    def __str__(self):
        return f"{self.username} ({self.get_user_type_display()})"


class CandidateProfile(models.Model):
    """Profil candidat avec informations supplémentaires"""
    user = models.OneToOneField(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='candidate_profile')
    nui = models.CharField(max_length=20, unique=True, blank=True, null=True)
    profile_photo = models.ImageField(upload_to='profile_photos/', blank=True, null=True)
    cv_file = models.FileField(upload_to='cv_files/', blank=True, null=True)
    job_title = models.CharField(max_length=100, blank=True, null=True)
    experience_years = models.IntegerField(default=0, blank=True, null=True)
    skills = models.TextField(blank=True, null=True)  # Comma separated skills
    bio = models.TextField(blank=True, null=True)
    expected_salary = models.DecimalField(max_digits=10, decimal_places=2, blank=True, null=True)
    location = models.CharField(max_length=100, blank=True, null=True)
    contract_type = models.CharField(max_length=50, blank=True, null=True)
    
    # Préférences d'emploi
    preferred_job_type = models.CharField(max_length=50, blank=True, null=True)
    experience_level = models.CharField(max_length=50, blank=True, null=True)
    salary_range_min = models.IntegerField(blank=True, null=True)
    salary_range_max = models.IntegerField(blank=True, null=True)
    preferred_work_location = models.CharField(max_length=100, blank=True, null=True)
    remote_work = models.BooleanField(default=False)
    preferred_industries = models.TextField(blank=True, null=True)  # Comma separated industries
    
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return f"Profile of {self.user.username}"

    @property
    def completion_percentage(self):
        """Calcule le pourcentage de complétude du profil"""
        fields = [
            self.nui, self.profile_photo, self.cv_file, self.job_title,
            self.experience_years, self.skills, self.bio,
            self.expected_salary, self.location, self.contract_type
        ]
        completed_fields = sum(1 for field in fields if field is not None and (isinstance(field, str) and field.strip() != '' or not isinstance(field, str)))
        
        # Ajouter les champs utilisateur qui font partie de la complétude du profil
        user_fields = [
            self.user.first_name, self.user.last_name, self.user.phone
        ]
        completed_user_fields = sum(1 for field in user_fields if field is not None and field.strip() != '')

        total_fields = len(fields) + len(user_fields)
        if total_fields == 0:
            return 0.0
        return (completed_fields + completed_user_fields) / total_fields


class Entreprise(models.Model):
    """Modèle pour les entreprises"""
    administrateur = models.OneToOneField(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='entreprise')
    nom = models.CharField(max_length=200, verbose_name="Nom de l'entreprise")
    description = models.TextField(verbose_name="Description de l'entreprise")
    secteur_activite = models.CharField(max_length=100, verbose_name="Secteur d'activité")
    localisations = models.JSONField(default=list, verbose_name="Localisations")
    adresse = models.TextField(verbose_name="Adresse")
    telephone = models.CharField(max_length=20, verbose_name="Téléphone")
    email = models.EmailField(verbose_name="Email")
    site_web = models.URLField(blank=True, verbose_name="Site web")
    logo = models.ImageField(upload_to='logos/', blank=True, verbose_name="Logo")
    position_google_maps = models.URLField(blank=True, verbose_name="Position Google Maps")
    numero_service_client = models.CharField(max_length=20, blank=True, verbose_name="Numéro service client")
    is_verified = models.BooleanField(default=False, verbose_name="Entreprise vérifiée")
    date_creation = models.DateTimeField(auto_now_add=True, verbose_name="Date de création")
    date_validation = models.DateTimeField(auto_now_add=True, verbose_name="Date de validation")
    statut_validation = models.CharField(
        max_length=20,
        choices=[
            ('en_attente', 'En attente'),
            ('valide', 'Validé'),
            ('rejete', 'Rejeté'),
        ],
        default='en_attente',
        verbose_name="Statut de validation"
    )
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        verbose_name = "Entreprise"
        verbose_name_plural = "Entreprises"
        ordering = ['-date_creation']

    def __str__(self):
        return self.nom