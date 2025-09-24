from rest_framework import generics, status, filters
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated, AllowAny
from rest_framework.response import Response
from django_filters.rest_framework import DjangoFilterBackend
from django.db.models import Q, Count
from django.utils import timezone
from datetime import timedelta

from .models import Offre, Candidature, Favori
from .serializers import (
    OffreSerializer, OffreCreateSerializer, OffreListSerializer,
    CandidatureSerializer, CandidatureCreateSerializer, FavoriSerializer
)
from accounts.models import Entreprise, CandidateProfile


class OffreListCreateView(generics.ListCreateAPIView):
    """Liste et création des offres"""
    queryset = Offre.objects.filter(is_active=True, statut='active')
    permission_classes = [IsAuthenticated]
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    filterset_fields = ['type_contrat', 'niveau_experience', 'secteur_activite', 'localisation']
    search_fields = ['titre', 'description', 'competences_requises']
    ordering_fields = ['date_publication', 'salaire_min', 'salaire_max']
    ordering = ['-date_publication']

    def get_serializer_class(self):
        if self.request.method == 'POST':
            return OffreCreateSerializer
        return OffreListSerializer


class OffrePublicListView(generics.ListAPIView):
    """Liste publique des offres (sans authentification)"""
    queryset = Offre.objects.filter(is_active=True, statut='active')
    permission_classes = [AllowAny]
    serializer_class = OffreListSerializer
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    filterset_fields = ['type_contrat', 'niveau_experience', 'secteur_activite', 'localisation']
    search_fields = ['titre', 'description', 'competences_requises']
    ordering_fields = ['date_publication', 'salaire_min', 'salaire_max']
    ordering = ['-date_publication']


    def get_queryset(self):
        queryset = super().get_queryset()
        
        # Filtrer les offres non expirées
        queryset = queryset.filter(date_expiration__gt=timezone.now())
        
        # Filtres supplémentaires
        salaire_min = self.request.query_params.get('salaire_min')
        salaire_max = self.request.query_params.get('salaire_max')
        
        if salaire_min:
            queryset = queryset.filter(salaire_max__gte=salaire_min)
        if salaire_max:
            queryset = queryset.filter(salaire_min__lte=salaire_max)
            
        return queryset

    def perform_create(self, serializer):
        # Récupérer l'entreprise de l'utilisateur connecté
        print(f"🔍 perform_create - Utilisateur connecté: {self.request.user}")
        print(f"🔍 perform_create - Type utilisateur: {getattr(self.request.user, 'user_type', 'N/A')}")
        
        try:
            entreprise = Entreprise.objects.get(administrateur=self.request.user)
            print(f"✅ Entreprise trouvée: {entreprise.nom} (ID: {entreprise.id})")
            # Ajouter l'entreprise aux données validées
            validated_data = serializer.validated_data.copy()
            validated_data['entreprise'] = entreprise
            serializer.save(**validated_data)
        except Entreprise.DoesNotExist:
            print(f"❌ Aucune entreprise trouvée pour l'utilisateur: {self.request.user}")
            
            # Lister toutes les entreprises pour debug
            entreprises = Entreprise.objects.all()
            print(f"📋 Toutes les entreprises ({entreprises.count()}):")
            for e in entreprises:
                print(f"   - {e.nom} (ID: {e.id}, Admin: {e.administrateur.username})")
            
            from rest_framework import serializers
            raise serializers.ValidationError("Aucune entreprise trouvée pour cet utilisateur")


class OffreDetailView(generics.RetrieveUpdateDestroyAPIView):
    """Détail, modification et suppression d'une offre"""
    queryset = Offre.objects.all()
    serializer_class = OffreSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        # Un recruteur ne peut voir que ses propres offres
        if hasattr(self.request.user, 'entreprise'):
            return Offre.objects.filter(entreprise__administrateur=self.request.user)
        return Offre.objects.none()

    def perform_destroy(self, instance):
        # Soft delete - marquer comme supprimée
        instance.statut = 'supprimee'
        instance.is_active = False
        instance.save()


class OffresRecruteurView(generics.ListAPIView):
    """Liste des offres d'un recruteur"""
    serializer_class = OffreSerializer
    permission_classes = [IsAuthenticated]
    filter_backends = [DjangoFilterBackend, filters.SearchFilter]
    filterset_fields = ['statut', 'type_contrat', 'is_active']
    search_fields = ['titre', 'description']

    def get_queryset(self):
        try:
            entreprise = Entreprise.objects.get(administrateur=self.request.user)
            return Offre.objects.filter(entreprise=entreprise).order_by('-date_publication')
        except Entreprise.DoesNotExist:
            return Offre.objects.none()


class CandidatureListCreateView(generics.ListCreateAPIView):
    """Liste et création des candidatures"""
    permission_classes = [IsAuthenticated]

    def get_serializer_class(self):
        if self.request.method == 'POST':
            return CandidatureCreateSerializer
        return CandidatureSerializer

    def get_queryset(self):
        # Vérifier d'abord le type d'utilisateur pour déterminer la logique
        if self.request.user.user_type == 'recruteur' and hasattr(self.request.user, 'entreprise'):
            # Recruteur - voir les candidatures de ses offres
            return Candidature.objects.filter(offre__entreprise__administrateur=self.request.user)
        elif self.request.user.user_type == 'candidat' and hasattr(self.request.user, 'candidate_profile'):
            # Candidat - voir ses propres candidatures
            return Candidature.objects.filter(candidat__user=self.request.user)
        
        return Candidature.objects.none()

    def perform_create(self, serializer):
        if hasattr(self.request.user, 'candidate_profile'):
            serializer.save(candidat=self.request.user.candidate_profile)
        else:
            from rest_framework import serializers
            raise serializers.ValidationError("Seuls les candidats peuvent postuler")


class CandidatureDetailView(generics.RetrieveUpdateDestroyAPIView):
    """Détail et modification d'une candidature"""
    serializer_class = CandidatureSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        # Vérifier d'abord le type d'utilisateur pour déterminer la logique
        if self.request.user.user_type == 'recruteur' and hasattr(self.request.user, 'entreprise'):
            # Recruteur - voir les candidatures de ses offres
            return Candidature.objects.filter(offre__entreprise__administrateur=self.request.user)
        elif self.request.user.user_type == 'candidat' and hasattr(self.request.user, 'candidate_profile'):
            # Candidat - voir ses propres candidatures
            return Candidature.objects.filter(candidat__user=self.request.user)
        
        return Candidature.objects.none()


@api_view(['POST', 'DELETE'])
@permission_classes([IsAuthenticated])
def toggle_favori(request, offre_id):
    """Ajouter ou retirer une offre des favoris"""
    if not hasattr(request.user, 'candidateprofile'):
        return Response(
            {"error": "Seuls les candidats peuvent gérer leurs favoris"},
            status=status.HTTP_403_FORBIDDEN
        )

    try:
        offre = Offre.objects.get(id=offre_id, is_active=True)
    except Offre.DoesNotExist:
        return Response(
            {"error": "Offre non trouvée"},
            status=status.HTTP_404_NOT_FOUND
        )

    candidat = request.user.candidateprofile
    favori, created = Favori.objects.get_or_create(
        candidat=candidat,
        offre=offre
    )

    if request.method == 'DELETE':
        favori.delete()
        return Response({"message": "Offre retirée des favoris"})
    else:
        if not created:
            return Response({"message": "Offre déjà dans les favoris"})
        return Response({"message": "Offre ajoutée aux favoris"})


class FavorisListView(generics.ListAPIView):
    """Liste des favoris d'un candidat"""
    serializer_class = FavoriSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        if hasattr(self.request.user, 'candidateprofile'):
            return Favori.objects.filter(candidat__user=self.request.user)
        return Favori.objects.none()


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def offres_recommandees(request):
    """Offres recommandées pour un candidat"""
    if not hasattr(request.user, 'candidateprofile'):
        return Response(
            {"error": "Seuls les candidats peuvent voir les offres recommandées"},
            status=status.HTTP_403_FORBIDDEN
        )

    candidat = request.user.candidateprofile
    
    # Logique de recommandation basée sur les compétences et le profil
    offres = Offre.objects.filter(
        is_active=True,
        statut='active',
        date_expiration__gt=timezone.now()
    ).order_by('-date_publication')[:20]

    # Filtrer par compétences du candidat
    if candidat.competences:
        offres = offres.filter(
            Q(competences_requises__overlap=candidat.competences) |
            Q(secteur_activite__icontains=candidat.domaine_etude)
        )

    serializer = OffreListSerializer(offres, many=True)
    return Response(serializer.data)


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def statistiques_offres(request):
    """Statistiques des offres pour un recruteur"""
    if not hasattr(request.user, 'entreprise'):
        return Response(
            {"error": "Seuls les recruteurs peuvent voir les statistiques"},
            status=status.HTTP_403_FORBIDDEN
        )

    entreprise = request.user.entreprise
    offres = Offre.objects.filter(entreprise=entreprise)
    
    stats = {
        'total_offres': offres.count(),
        'offres_actives': offres.filter(statut='active', is_active=True).count(),
        'offres_expirees': offres.filter(statut='expiree').count(),
        'total_candidatures': Candidature.objects.filter(offre__entreprise=entreprise).count(),
        'candidatures_ce_mois': Candidature.objects.filter(
            offre__entreprise=entreprise,
            date_candidature__gte=timezone.now().replace(day=1)
        ).count(),
        'offres_par_type': {},
        'candidatures_par_offre': []
    }

    # Statistiques par type de contrat
    for type_contrat, _ in Offre.TYPE_CONTRAT_CHOICES:
        count = offres.filter(type_contrat=type_contrat).count()
        if count > 0:
            stats['offres_par_type'][type_contrat] = count

    # Top 5 des offres avec le plus de candidatures
    from django.db import models
    top_offres = offres.annotate(
        nb_candidatures=models.Count('candidatures')
    ).order_by('-nb_candidatures')[:5]

    for offre in top_offres:
        stats['candidatures_par_offre'].append({
            'titre': offre.titre,
            'candidatures': offre.nb_candidatures
        })

    return Response(stats)
