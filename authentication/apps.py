from django.apps import AppConfig


class AuthenticationConfig(AppConfig):
    default_auto_field = 'django.db.models.BigAutoField'
    name = 'authentication'
	
from manage import INSTALLED_APPS  	
INSTALLED_APPS += ['authentication',]  	
