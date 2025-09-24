from django.urls import path
from . import views

urlpatterns = [
    # Offres
    path('offres/', views.OffreListCreateView.as_view(), name='offre-list-create'),
    path('offres/public/', views.OffrePublicListView.as_view(), name='offre-public-list'),
    path('offres/<int:pk>/', views.OffreDetailView.as_view(), name='offre-detail'),
    path('recruteur/offres/', views.OffresRecruteurView.as_view(), name='offres-recruteur'),
    path('offres/recommandees/', views.offres_recommandees, name='offres-recommandees'),
    path('recruteur/statistiques/', views.statistiques_offres, name='statistiques-offres'),
    
    # Candidatures
    path('candidatures/', views.CandidatureListCreateView.as_view(), name='candidature-list-create'),
    path('candidatures/<int:pk>/', views.CandidatureDetailView.as_view(), name='candidature-detail'),
    
    # Favoris
    path('favoris/', views.FavorisListView.as_view(), name='favoris-list'),
    path('favoris/<int:offre_id>/', views.toggle_favori, name='toggle-favori'),
]
