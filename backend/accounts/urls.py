from django.urls import path
from . import views

urlpatterns = [
    # Authentification
    path('register/', views.register, name='register'),
    path('login/', views.login_view, name='login'),
    path('logout/', views.logout_view, name='logout'),
    
    # Profil utilisateur
    path('profile/', views.user_profile, name='user_profile'),
    path('change-password/', views.change_password, name='change_password'),
    path('profile/upload-photo/', views.upload_profile_photo, name='upload_profile_photo'),
    path('profile/update-user/', views.update_user_info, name='update_user_info'),
    path('profile/update-candidate/', views.update_candidate_profile, name='update_candidate_profile'),
    
    # CV et compétences
    path('profile/upload-cv/', views.upload_cv, name='upload_cv'),
    path('profile/cvs/', views.get_cvs, name='get_cvs'),
    path('profile/cvs/<int:cv_id>/', views.delete_cv, name='delete_cv'),
    
    # Préférences d'emploi
    path('profile/job-preferences/', views.update_job_preferences, name='update_job_preferences'),
    
    # Candidats
    path('candidats/', views.get_candidats, name='get_candidats'),
    path('candidats/<int:candidat_id>/disponibilite/', views.update_candidat_disponibilite, name='update_candidat_disponibilite'),
    
    # Entreprises
    path('entreprises/', views.EntrepriseListView.as_view(), name='entreprise-list'),
    path('entreprises/<int:pk>/', views.EntrepriseDetailView.as_view(), name='entreprise-detail'),
]
