from rest_framework import generics, status
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework.authtoken.models import Token
from django.contrib.auth import authenticate
from django.contrib.auth.models import User
from django.contrib.auth import logout
from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
from django.utils.decorators import method_decorator
from django.views.decorators.csrf import csrf_exempt
import json
from .models import User, Entreprise
from .serializers import UserSerializer, UserRegistrationSerializer, UserLoginSerializer, EntrepriseSerializer
from jobs.models import Offre
from jobs.serializers import OffreSerializer

class UserRegistrationView(generics.CreateAPIView):
    queryset = User.objects.all()
    serializer_class = UserRegistrationSerializer

    def create(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        if serializer.is_valid():
            user = serializer.save()
            token, created = Token.objects.get_or_create(user=user)
            return Response({
                'message': 'Utilisateur créé avec succès',
                'user': UserSerializer(user).data,
                'token': token.key
            }, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

class UserLoginView(generics.GenericAPIView):
    serializer_class = UserLoginSerializer

    def post(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        if serializer.is_valid():
            user = serializer.validated_data['user']
            token, created = Token.objects.get_or_create(user=user)
            return Response({
                'token': token.key,
                'user': UserSerializer(user).data,
                'user_type': user.user_type,
                'message': 'Connexion réussie'
            }, status=status.HTTP_200_OK)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

@api_view(['GET'])
@permission_classes([IsAuthenticated])
def get_candidats(request):
    """
    Récupère la liste des candidats disponibles
    """
    try:
        # Récupérer tous les utilisateurs de type 'candidat'
        candidats = User.objects.filter(user_type='candidat', is_active=True)
        
        # Filtrer par disponibilité si spécifié
        disponible = request.query_params.get('disponible')
        if disponible is not None:
            disponible_bool = disponible.lower() == 'true'
            candidats = candidats.filter(disponible=disponible_bool)
        
        # Sérialiser les données
        candidats_data = []
        for candidat in candidats:
            candidats_data.append({
                'id': candidat.id,
                'nom': candidat.last_name or '',
                'prenom': candidat.first_name or '',
                'email': candidat.email,
                'telephone': candidat.phone or '',
                'localisation': candidat.localisation or '',
                'domaine_etude': candidat.domaine_etude or '',
                'niveau_etude': candidat.niveau_etude or '',
                'annee_diplome': candidat.annee_diplome or 0,
                'universite': candidat.universite or '',
                'competences': candidat.competences or [],
                'experiences': candidat.experiences or [],
                'cv_path': candidat.cv_path or '',
                'lettre_motivation_path': candidat.lettre_motivation_path or '',
                'date_inscription': candidat.date_joined.isoformat(),
                'is_actif': candidat.is_active,
                'disponible': candidat.disponible,
                'preferences': candidat.preferences or {},
                'score_matching': candidat.score_matching or 0.0,
            })
        
        return Response({
            'results': candidats_data,
            'count': len(candidats_data)
        }, status=status.HTTP_200_OK)
        
    except Exception as e:
        print(f"❌ Erreur lors de la récupération des candidats: {e}")
        return Response({
            'error': 'Erreur lors de la récupération des candidats',
            'details': str(e)
        }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

@api_view(['PUT'])
@permission_classes([IsAuthenticated])
def update_candidat_disponibilite(request, candidat_id):
    """
    Met à jour la disponibilité d'un candidat
    """
    try:
        # Vérifier que l'utilisateur est le candidat lui-même
        if request.user.id != candidat_id:
            return Response({
                'error': 'Vous ne pouvez modifier que votre propre disponibilité'
            }, status=status.HTTP_403_FORBIDDEN)
        
        # Récupérer le candidat
        try:
            candidat = User.objects.get(id=candidat_id, user_type='candidat')
        except User.DoesNotExist:
            return Response({
                'error': 'Candidat non trouvé'
            }, status=status.HTTP_404_NOT_FOUND)
        
        # Mettre à jour la disponibilité
        disponible = request.data.get('disponible')
        if disponible is not None:
            candidat.disponible = disponible
            candidat.save()
            
            return Response({
                'message': 'Disponibilité mise à jour avec succès',
                'disponible': candidat.disponible
            }, status=status.HTTP_200_OK)
        else:
            return Response({
                'error': 'Paramètre "disponible" requis'
            }, status=status.HTTP_400_BAD_REQUEST)
            
    except Exception as e:
        print(f"❌ Erreur lors de la mise à jour de la disponibilité: {e}")
        return Response({
            'error': 'Erreur lors de la mise à jour de la disponibilité',
            'details': str(e)
        }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

# Fonctions manquantes pour la compatibilité avec les URLs existantes
@csrf_exempt
def register(request):
    if request.method == 'POST':
        try:
            data = json.loads(request.body)
            serializer = UserRegistrationSerializer(data=data)
            if serializer.is_valid():
                user = serializer.save()
                return JsonResponse({
                    'message': 'Utilisateur créé avec succès',
                    'user': UserSerializer(user).data
                }, status=201)
            return JsonResponse(serializer.errors, status=400)
        except Exception as e:
            return JsonResponse({'error': str(e)}, status=500)
    return JsonResponse({'error': 'Method not allowed'}, status=405)

@csrf_exempt
def login_view(request):
    if request.method == 'POST':
        try:
            data = json.loads(request.body)
            serializer = UserLoginSerializer(data=data)
            if serializer.is_valid():
                user = serializer.validated_data['user']
                token, created = Token.objects.get_or_create(user=user)
                return JsonResponse({
                    'token': token.key,
                    'user': UserSerializer(user).data,
                    'user_type': user.user_type,
                    'message': 'Connexion réussie'
                })
            return JsonResponse(serializer.errors, status=400)
        except Exception as e:
            return JsonResponse({'error': str(e)}, status=500)
    return JsonResponse({'error': 'Method not allowed'}, status=405)

@csrf_exempt
def logout_view(request):
    if request.method == 'POST':
        try:
            logout(request)
            return JsonResponse({'message': 'Déconnexion réussie'})
        except Exception as e:
            return JsonResponse({'error': str(e)}, status=500)
    return JsonResponse({'error': 'Method not allowed'}, status=405)

@api_view(['GET'])
@permission_classes([IsAuthenticated])
def user_profile(request):
    user_data = UserSerializer(request.user).data
    
    # Si c'est un candidat, essayer de récupérer son profil
    profile_data = None
    if request.user.user_type == 'candidat':
        try:
            from .models import CandidateProfile
            profile = CandidateProfile.objects.get(user=request.user)
            profile_data = {
                'id': profile.id,
                'bio': profile.bio,
                'location': profile.location,
                'skills': profile.skills,
                'cv_file': f"data:application/pdf;base64,{profile.cv_file_base64}" if profile.cv_file_base64 else None,
                'profile_photo': f"data:image/jpeg;base64,{profile.profile_photo_base64}" if profile.profile_photo_base64 else None,
                'completion_percentage': profile.completion_percentage,
                # Préférences d'emploi
                'preferred_job_type': profile.preferred_job_type,
                'experience_level': profile.experience_level,
                'salary_range_min': profile.salary_range_min,
                'salary_range_max': profile.salary_range_max,
                'preferred_work_location': profile.preferred_work_location,
                'remote_work': profile.remote_work,
                'preferred_industries': profile.preferred_industries,
            }
        except CandidateProfile.DoesNotExist:
            pass
    
    print(f"🔍 Profil retourné pour {request.user.username}:")
    print(f"  - preferred_job_type: {profile_data.get('preferred_job_type') if profile_data else 'None'}")
    print(f"  - experience_level: {profile_data.get('experience_level') if profile_data else 'None'}")
    print(f"  - preferred_work_location: {profile_data.get('preferred_work_location') if profile_data else 'None'}")
    print(f"  - remote_work: {profile_data.get('remote_work') if profile_data else 'None'}")
    
    return Response({
        'user': user_data,
        'profile': profile_data
    })

@api_view(['POST'])
@permission_classes([IsAuthenticated])
def change_password(request):
    # TODO: Implémenter le changement de mot de passe
    return Response({'message': 'Fonctionnalité en cours de développement'})

@api_view(['POST'])
@permission_classes([IsAuthenticated])
def upload_profile_photo(request):
    try:
        if 'photo' not in request.FILES:
            return Response({'message': 'Aucune photo fournie'}, status=400)
        
        photo = request.FILES['photo']
        
        # Créer ou récupérer le profil candidat
        from .models import CandidateProfile
        profile, created = CandidateProfile.objects.get_or_create(user=request.user)
        
        # Lire l'image et la convertir en base64
        import base64
        photo_data = photo.read()
        photo_base64 = base64.b64encode(photo_data).decode('utf-8')
        
        # Sauvegarder en base64 dans un champ texte
        profile.profile_photo_base64 = photo_base64
        profile.save()
        
        return Response({
            'message': 'Photo de profil mise à jour avec succès',
            'photo_url': f"data:image/jpeg;base64,{photo_base64}"
        })
    except Exception as e:
        return Response({'message': f'Erreur: {str(e)}'}, status=400)

@api_view(['POST', 'PUT'])
@permission_classes([IsAuthenticated])
def update_user_info(request):
    try:
        user = request.user
        data = request.data
        
        # Mettre à jour les champs fournis
        if 'first_name' in data:
            user.first_name = data['first_name']
        if 'last_name' in data:
            user.last_name = data['last_name']
        if 'phone' in data:
            user.phone = data['phone']
        
        user.save()
        
        return Response({
            'message': 'Informations utilisateur mises à jour avec succès',
            'user': UserSerializer(user).data
        })
    except Exception as e:
        return Response({'message': f'Erreur: {str(e)}'}, status=400)

@api_view(['POST', 'PUT'])
@permission_classes([IsAuthenticated])
def update_candidate_profile(request):
    try:
        user = request.user
        data = request.data
        
        # Créer ou récupérer le profil candidat
        from .models import CandidateProfile
        profile, created = CandidateProfile.objects.get_or_create(user=user)
        
        # Mettre à jour les champs fournis
        if 'bio' in data:
            profile.bio = data['bio']
        if 'location' in data:
            profile.location = data['location']
        if 'skills' in data:
            profile.skills = data['skills']
        if 'job_title' in data:
            profile.job_title = data['job_title']
        if 'experience_years' in data:
            profile.experience_years = data['experience_years']
        if 'expected_salary' in data:
            profile.expected_salary = data['expected_salary']
        if 'contract_type' in data:
            profile.contract_type = data['contract_type']
        
        profile.save()
        
        return Response({
            'message': 'Profil candidat mis à jour avec succès',
            'profile': {
                'id': profile.id,
                'bio': profile.bio,
                'location': profile.location,
                'skills': profile.skills,
                'job_title': profile.job_title,
                'experience_years': profile.experience_years,
                'expected_salary': profile.expected_salary,
                'contract_type': profile.contract_type,
                'completion_percentage': profile.completion_percentage,
            }
        })
    except Exception as e:
        return Response({'message': f'Erreur: {str(e)}'}, status=400)

@api_view(['POST'])
@permission_classes([IsAuthenticated])
def upload_cv(request):
    try:
        if 'cv' not in request.FILES:
            return Response({'message': 'Aucun CV fourni'}, status=400)
        
        cv_file = request.FILES['cv']
        
        # Créer ou récupérer le profil candidat
        from .models import CandidateProfile
        profile, created = CandidateProfile.objects.get_or_create(user=request.user)
        
        # Lire le fichier et le convertir en base64
        import base64
        cv_data = cv_file.read()
        cv_base64 = base64.b64encode(cv_data).decode('utf-8')
        
        # Sauvegarder en base64 et le nom du fichier
        profile.cv_file_base64 = cv_base64
        profile.cv_file = cv_file  # Sauvegarder aussi le fichier pour récupérer le nom
        profile.save()
        
        return Response({
            'message': 'CV mis à jour avec succès',
            'cv_url': f"data:application/pdf;base64,{cv_base64}"
        })
    except Exception as e:
        return Response({'message': f'Erreur: {str(e)}'}, status=400)

@api_view(['GET'])
@permission_classes([IsAuthenticated])
def get_cvs(request):
    try:
        from .models import CandidateProfile
        profile, created = CandidateProfile.objects.get_or_create(user=request.user)
        
        cvs = []
        if profile.cv_file_base64:
            # Utiliser le nom du fichier original ou un nom par défaut
            cv_name = f'CV_{profile.user.username}.pdf'
            if profile.cv_file and profile.cv_file.name:
                # Prendre juste le nom du fichier sans le chemin
                original_name = profile.cv_file.name.split('/')[-1]
                if original_name and original_name != 'cv_files/':
                    cv_name = original_name
            
            cvs.append({
                'id': 1,
                'name': cv_name,
                'url': f"data:application/pdf;base64,{profile.cv_file_base64}",
                'upload_date': profile.updated_at.isoformat() if profile.updated_at else None
            })
        
        return Response({'cvs': cvs})
    except Exception as e:
        return Response({'message': f'Erreur: {str(e)}'}, status=400)

@api_view(['DELETE'])
@permission_classes([IsAuthenticated])
def delete_cv(request, cv_id):
    # TODO: Implémenter la suppression de CV
    return Response({'message': 'Fonctionnalité en cours de développement'})

@api_view(['POST', 'PUT'])
@permission_classes([IsAuthenticated])
def update_job_preferences(request):
    try:
        user = request.user
        data = request.data

        from .models import CandidateProfile
        profile, created = CandidateProfile.objects.get_or_create(user=user)

        # Mettre à jour les préférences d'emploi
        if 'preferred_job_type' in data:
            profile.preferred_job_type = data['preferred_job_type']
        if 'experience_level' in data:
            profile.experience_level = data['experience_level']
        if 'salary_range_min' in data:
            profile.salary_range_min = data['salary_range_min']
        if 'salary_range_max' in data:
            profile.salary_range_max = data['salary_range_max']
        if 'preferred_work_location' in data:
            profile.preferred_work_location = data['preferred_work_location']
        if 'remote_work' in data:
            profile.remote_work = data['remote_work']
        if 'preferred_industries' in data:
            profile.preferred_industries = data['preferred_industries']

        profile.save()

        return Response({
            'message': 'Préférences d\'emploi mises à jour avec succès',
            'preferences': {
                'preferred_job_type': profile.preferred_job_type,
                'experience_level': profile.experience_level,
                'salary_range_min': profile.salary_range_min,
                'salary_range_max': profile.salary_range_max,
                'preferred_work_location': profile.preferred_work_location,
                'remote_work': profile.remote_work,
                'preferred_industries': profile.preferred_industries,
            }
        })
    except Exception as e:
        return Response({'message': f'Erreur: {str(e)}'}, status=400)

@api_view(['POST', 'PUT'])
@permission_classes([IsAuthenticated])
def update_job_preferences(request):
    try:
        user = request.user
        data = request.data
        
        print(f"🔧 Mise à jour des préférences pour {user.username}")
        print(f"📊 Données reçues: {data}")

        from .models import CandidateProfile
        profile, created = CandidateProfile.objects.get_or_create(user=user)

        if 'preferred_job_type' in data:
            profile.preferred_job_type = data['preferred_job_type']
            print(f"✅ preferred_job_type: {data['preferred_job_type']}")
        if 'experience_level' in data:
            profile.experience_level = data['experience_level']
            print(f"✅ experience_level: {data['experience_level']}")
        if 'salary_range_min' in data:
            profile.salary_range_min = data['salary_range_min']
            print(f"✅ salary_range_min: {data['salary_range_min']}")
        if 'salary_range_max' in data:
            profile.salary_range_max = data['salary_range_max']
            print(f"✅ salary_range_max: {data['salary_range_max']}")
        if 'preferred_work_location' in data:
            profile.preferred_work_location = data['preferred_work_location']
            print(f"✅ preferred_work_location: {data['preferred_work_location']}")
        if 'remote_work' in data:
            profile.remote_work = data['remote_work']
            print(f"✅ remote_work: {data['remote_work']}")
        if 'preferred_industries' in data:
            profile.preferred_industries = data['preferred_industries']
            print(f"✅ preferred_industries: {data['preferred_industries']}")

        profile.save()
        print(f"💾 Profil sauvegardé avec succès")

        return Response({
            'message': 'Préférences d\'emploi mises à jour avec succès',
            'preferences': {
                'preferred_job_type': profile.preferred_job_type,
                'experience_level': profile.experience_level,
                'salary_range_min': profile.salary_range_min,
                'salary_range_max': profile.salary_range_max,
                'preferred_work_location': profile.preferred_work_location,
                'remote_work': profile.remote_work,
                'preferred_industries': profile.preferred_industries,
            }
        })
    except Exception as e:
        return Response({'message': f'Erreur: {str(e)}'}, status=400)

# Vue pour lister les entreprises
class EntrepriseListView(generics.ListAPIView):
    """Liste toutes les entreprises"""
    queryset = Entreprise.objects.all()
    serializer_class = EntrepriseSerializer
    permission_classes = [IsAuthenticated]

# Vue pour les détails d'une entreprise
class EntrepriseDetailView(generics.RetrieveAPIView):
    """Détails d'une entreprise"""
    queryset = Entreprise.objects.all()
    serializer_class = EntrepriseSerializer
    permission_classes = [IsAuthenticated]