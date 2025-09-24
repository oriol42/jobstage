from rest_framework import serializers
from .models import Offre, Candidature, Favori
from accounts.serializers import EntrepriseSerializer, CandidateProfileSerializer


class OffreSerializer(serializers.ModelSerializer):
    entreprise = EntrepriseSerializer(read_only=True)
    entreprise_id = serializers.IntegerField(write_only=True)
    salaire_display = serializers.ReadOnlyField()
    duree_display = serializers.ReadOnlyField()
    is_expired = serializers.ReadOnlyField()
    
    class Meta:
        model = Offre
        fields = [
            'id', 'entreprise', 'entreprise_id', 'titre', 'description',
            'secteur_activite', 'competences_requises', 'localisation',
            'type_contrat', 'type_stage', 'duree_mois', 'salaire_min',
            'salaire_max', 'salaire_text', 'niveau_etudes', 'niveau_experience',
            'experience_requise', 'date_publication', 'date_expiration',
            'statut', 'nombre_candidats', 'nombre_candidatures', 'avantages',
            'processus_recrutement', 'contact_email', 'contact_telephone',
            'is_active', 'salaire_display', 'duree_display', 'is_expired',
            'created_at', 'updated_at'
        ]
        read_only_fields = ['nombre_candidats', 'nombre_candidatures', 'created_at', 'updated_at']

    def validate(self, data):
        if data['date_expiration'] <= data['date_publication']:
            raise serializers.ValidationError(
                "La date d'expiration doit être postérieure à la date de publication"
            )
        if data['salaire_max'] < data['salaire_min']:
            raise serializers.ValidationError(
                "Le salaire maximum doit être supérieur au salaire minimum"
            )
        return data


class OffreCreateSerializer(serializers.ModelSerializer):
    """Sérialiseur simplifié pour la création d'offres"""
    
    class Meta:
        model = Offre
        fields = [
            'titre', 'description', 'secteur_activite', 'competences_requises',
            'localisation', 'type_contrat', 'type_stage', 'duree_mois',
            'salaire_min', 'salaire_max', 'salaire_text', 'niveau_etudes',
            'niveau_experience', 'experience_requise', 'date_expiration',
            'avantages', 'processus_recrutement', 'contact_email',
            'contact_telephone', 'is_active'
        ]

    def create(self, validated_data):
        # Récupérer l'entreprise de l'utilisateur connecté
        request = self.context.get('request')
        if request and request.user.is_authenticated:
            try:
                from accounts.models import Entreprise
                entreprise = Entreprise.objects.get(administrateur=request.user)
                validated_data['entreprise'] = entreprise
            except Entreprise.DoesNotExist:
                from rest_framework import serializers
                raise serializers.ValidationError("Aucune entreprise trouvée pour cet utilisateur")
        else:
            from rest_framework import serializers
            raise serializers.ValidationError("Utilisateur non authentifié")
        
        return Offre.objects.create(**validated_data)


class CandidatureSerializer(serializers.ModelSerializer):
    candidat = CandidateProfileSerializer(read_only=True)
    candidat_id = serializers.IntegerField(write_only=True)
    offre = OffreSerializer(read_only=True)
    offre_id = serializers.IntegerField(write_only=True)
    
    class Meta:
        model = Candidature
        fields = [
            'id', 'candidat', 'candidat_id', 'offre', 'offre_id',
            'cv_path', 'lettre_motivation_path', 'statut', 'date_candidature',
            'date_vue', 'score_matching', 'created_at', 'updated_at'
        ]
        read_only_fields = ['date_candidature', 'created_at', 'updated_at']


class CandidatureCreateSerializer(serializers.ModelSerializer):
    """Sérialiseur pour la création de candidatures"""
    
    class Meta:
        model = Candidature
        fields = ['offre', 'cv_path', 'lettre_motivation_path']

    def create(self, validated_data):
        # Le candidat sera ajouté dans la vue
        return Candidature.objects.create(**validated_data)


class FavoriSerializer(serializers.ModelSerializer):
    offre = OffreSerializer(read_only=True)
    offre_id = serializers.IntegerField(write_only=True)
    
    class Meta:
        model = Favori
        fields = ['id', 'offre', 'offre_id', 'date_ajout']


class OffreListSerializer(serializers.ModelSerializer):
    """Sérialiseur simplifié pour les listes d'offres"""
    entreprise_nom = serializers.CharField(source='entreprise.nom', read_only=True)
    salaire_display = serializers.ReadOnlyField()
    duree_display = serializers.ReadOnlyField()
    is_expired = serializers.ReadOnlyField()
    
    class Meta:
        model = Offre
        fields = [
            'id', 'titre', 'description', 'secteur_activite', 'localisation',
            'type_contrat', 'type_stage', 'duree_mois', 'niveau_etudes', 'niveau_experience',
            'salaire_min', 'salaire_max', 'salaire_text', 'salaire_display', 'duree_display',
            'date_publication', 'date_expiration', 'statut', 'nombre_candidats',
            'nombre_candidatures', 'is_active', 'is_expired', 'entreprise_nom',
            'competences_requises', 'avantages', 'processus_recrutement',
            'contact_email', 'contact_telephone'
        ]
