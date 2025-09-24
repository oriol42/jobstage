from django.contrib import admin
from .models import Offre, Candidature, Favori


@admin.register(Offre)
class OffreAdmin(admin.ModelAdmin):
    list_display = ('titre', 'entreprise', 'type_contrat', 'niveau_experience', 'statut', 'is_active', 'date_publication')
    list_filter = ('statut', 'type_contrat', 'niveau_experience', 'is_active', 'date_publication', 'secteur_activite')
    search_fields = ('titre', 'description', 'entreprise__nom', 'localisation')
    readonly_fields = ('nombre_candidats', 'nombre_candidatures', 'created_at', 'updated_at')
    ordering = ('-date_publication',)
    
    fieldsets = (
        ('Informations générales', {
            'fields': ('titre', 'description', 'entreprise', 'secteur_activite', 'statut')
        }),
        ('Détails de l\'emploi', {
            'fields': ('type_contrat', 'type_stage', 'duree_mois', 'niveau_experience', 'experience_requise', 'localisation')
        }),
        ('Rémunération', {
            'fields': ('salaire_min', 'salaire_max', 'salaire_text')
        }),
        ('Niveau requis', {
            'fields': ('niveau_etudes', 'competences_requises')
        }),
        ('Dates', {
            'fields': ('date_publication', 'date_expiration')
        }),
        ('Contact', {
            'fields': ('contact_email', 'contact_telephone')
        }),
        ('Statistiques', {
            'fields': ('nombre_candidats', 'nombre_candidatures', 'is_active')
        }),
    )


@admin.register(Candidature)
class CandidatureAdmin(admin.ModelAdmin):
    list_display = ('candidat', 'offre', 'statut', 'date_candidature', 'score_matching')
    list_filter = ('statut', 'date_candidature')
    search_fields = ('candidat__user__first_name', 'candidat__user__last_name', 'offre__titre')
    readonly_fields = ('date_candidature', 'created_at', 'updated_at')
    ordering = ('-date_candidature',)


@admin.register(Favori)
class FavoriAdmin(admin.ModelAdmin):
    list_display = ('candidat', 'offre', 'date_ajout')
    list_filter = ('date_ajout',)
    search_fields = ('candidat__user__first_name', 'candidat__user__last_name', 'offre__titre')
    ordering = ('-date_ajout',)