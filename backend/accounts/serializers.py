from rest_framework import serializers
from django.contrib.auth import authenticate
from django.contrib.auth.password_validation import validate_password
from .models import User, CandidateProfile, Entreprise


class UserRegistrationSerializer(serializers.ModelSerializer):
    """Serializer pour l'inscription des utilisateurs"""
    password = serializers.CharField(write_only=True, validators=[validate_password])
    password_confirm = serializers.CharField(write_only=True)
    
    # Champs supplémentaires pour les recruteurs
    company_name = serializers.CharField(required=False, allow_blank=True)
    company_sector = serializers.CharField(required=False, allow_blank=True)
    company_address = serializers.CharField(required=False, allow_blank=True)
    company_website = serializers.CharField(required=False, allow_blank=True)

    class Meta:
        model = User
        fields = ('username', 'email', 'phone', 'password', 'password_confirm', 'user_type',
                 'company_name', 'company_sector', 'company_address', 'company_website')
        extra_kwargs = {
            'password': {'write_only': True},
            'password_confirm': {'write_only': True},
        }

    def validate(self, attrs):
        if attrs['password'] != attrs['password_confirm']:
            raise serializers.ValidationError("Les mots de passe ne correspondent pas.")
        
        # Pour les recruteurs, vérifier que les champs entreprise sont fournis
        if attrs.get('user_type') == 'recruteur':
            if not attrs.get('company_name'):
                raise serializers.ValidationError("Le nom de l'entreprise est obligatoire pour les recruteurs.")
            if not attrs.get('company_sector'):
                raise serializers.ValidationError("Le secteur d'activité est obligatoire pour les recruteurs.")
            if not attrs.get('company_address'):
                raise serializers.ValidationError("L'adresse de l'entreprise est obligatoire pour les recruteurs.")
        
        return attrs

    def create(self, validated_data):
        # Extraire les données de l'entreprise
        company_data = {
            'company_name': validated_data.pop('company_name', ''),
            'company_sector': validated_data.pop('company_sector', ''),
            'company_address': validated_data.pop('company_address', ''),
            'company_website': validated_data.pop('company_website', ''),
        }
        
        validated_data.pop('password_confirm')
        user = User.objects.create_user(**validated_data)
        
        # Si c'est un recruteur, créer l'entreprise automatiquement
        if user.user_type == 'recruteur' and company_data['company_name']:
            entreprise = Entreprise.objects.create(
                administrateur=user,
                nom=company_data['company_name'],
                description=f"Entreprise {company_data['company_name']}",
                secteur_activite=company_data['company_sector'] or 'Autre',
                adresse=company_data['company_address'],
                site_web=company_data['company_website'],
                email=user.email,
                telephone=user.phone,
                is_verified=True,
                statut_validation='valide'
            )
            print(f"✅ Entreprise créée automatiquement: {entreprise.nom} pour {user.username}")
        
        return user


class UserLoginSerializer(serializers.Serializer):
    """Serializer pour la connexion des utilisateurs"""
    username = serializers.CharField()
    password = serializers.CharField()

    def validate(self, attrs):
        username = attrs.get('username')
        password = attrs.get('password')

        if username and password:
            # Essayer avec l'email, téléphone, ou username
            user = None
            if '@' in username:
                # Connexion par email - utiliser l'email comme username pour l'authentification
                user = authenticate(username=username, password=password)
            elif username.isdigit() or username.startswith('+'):
                # Connexion par téléphone
                try:
                    user_obj = User.objects.get(phone=username)
                    user = authenticate(username=user_obj.username, password=password)
                except User.DoesNotExist:
                    pass
            else:
                # Connexion par username
                user = authenticate(username=username, password=password)
            
            if not user:
                raise serializers.ValidationError('Identifiants invalides.')
            if not user.is_active:
                raise serializers.ValidationError('Ce compte est désactivé.')
            attrs['user'] = user
            return attrs
        else:
            raise serializers.ValidationError('Email/Téléphone/Username et password requis.')


class UserSerializer(serializers.ModelSerializer):
    """Serializer pour les informations utilisateur"""
    class Meta:
        model = User
        fields = ('id', 'username', 'first_name', 'last_name', 'email', 'phone', 'user_type', 'is_verified', 'date_joined')
        read_only_fields = ('id', 'date_joined')


class PasswordChangeSerializer(serializers.Serializer):
    """Serializer pour le changement de mot de passe"""
    old_password = serializers.CharField()
    new_password = serializers.CharField(validators=[validate_password])
    new_password_confirm = serializers.CharField()

    def validate(self, attrs):
        if attrs['new_password'] != attrs['new_password_confirm']:
            raise serializers.ValidationError("Les nouveaux mots de passe ne correspondent pas.")
        return attrs

    def validate_old_password(self, value):
        user = self.context['request'].user
        if not user.check_password(value):
            raise serializers.ValidationError("Ancien mot de passe incorrect.")
        return value


class CandidateProfileSerializer(serializers.ModelSerializer):
    """Serializer pour le profil candidat"""
    user = UserSerializer(read_only=True)
    completion_percentage = serializers.ReadOnlyField()
    
    class Meta:
        model = CandidateProfile
        fields = '__all__'
        read_only_fields = ('id', 'user', 'created_at', 'updated_at')


class EntrepriseSerializer(serializers.ModelSerializer):
    """Serializer pour les entreprises"""
    administrateur = UserSerializer(read_only=True)
    
    class Meta:
        model = Entreprise
        fields = '__all__'
        read_only_fields = ('id', 'administrateur', 'created_at', 'updated_at')
