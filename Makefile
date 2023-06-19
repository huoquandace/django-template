# chocolate
# @"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "[System.Net.ServicePointManager]::SecurityProtocol = 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))" && SET "PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin"
# make
# choco install make

MANAGE_FILE:=manage
SETTINGS_FILE:=settings
URLS_FILE:=urls
WSGI_FILE:=wsgi
SERVER_PORT:=80

start:
	@echo import os, sys> $(MANAGE_FILE).py
	@echo if __name__ == '__main__':>> $(MANAGE_FILE).py
	@echo 	os.environ.setdefault('DJANGO_SETTINGS_MODULE', '$(SETTINGS_FILE)')>> $(MANAGE_FILE).py
	@echo 	try: from django.core.management import execute_from_command_line>> $(MANAGE_FILE).py
	@echo 	except ImportError as exc: raise ImportError("Forget venv?") from exc>> $(MANAGE_FILE).py
	@echo 	execute_from_command_line(sys.argv)>> $(MANAGE_FILE).py

	@echo import os> $(WSGI_FILE).py
	@echo from django.core.wsgi import get_wsgi_application>> $(WSGI_FILE).py
	@echo os.environ.setdefault('DJANGO_SETTINGS_MODULE', '$(SETTINGS_FILE)')>> $(WSGI_FILE).py
	@echo application = get_wsgi_application()>> $(WSGI_FILE).py

	@echo from django.conf import settings> $(URLS_FILE).py
	@echo from django.conf.urls.static import static>> $(URLS_FILE).py
	@echo from django.contrib import admin>> $(URLS_FILE).py
	@echo from django.urls import path, include>> $(URLS_FILE).py
	@echo from django.conf.urls.i18n import i18n_patterns>> $(URLS_FILE).py
	@echo.>> $(URLS_FILE).py
	@echo urlpatterns = [>> $(URLS_FILE).py
	@echo 	path('admin/', admin.site.urls),>> $(URLS_FILE).py
	@echo 	path('i18n/', include('django.conf.urls.i18n')),>> $(URLS_FILE).py
	@echo ]>> $(URLS_FILE).py
	@echo.>> $(URLS_FILE).py
	@echo urlpatterns += i18n_patterns (>> $(URLS_FILE).py
	@echo. 	>> $(URLS_FILE).py
	@echo 	# prefix_default_language=False>> $(URLS_FILE).py
	@echo )>> $(URLS_FILE).py
	@echo urlpatterns += static(settings.STATIC_URL, document_root=settings.STATIC_ROOT)>> $(URLS_FILE).py
	@echo urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)>> $(URLS_FILE).py

	@echo import os, sys> $(SETTINGS_FILE).py
	@echo from pathlib import Path>> $(SETTINGS_FILE).py
	@echo from django.utils.translation import gettext_lazy as _>> $(SETTINGS_FILE).py
	@echo.>> $(SETTINGS_FILE).py
	@echo BASE_DIR = Path(__file__).resolve().parent>> $(SETTINGS_FILE).py
	@echo BASE_FILE_NAME = os.path.basename(__file__).split('.')[0]>> $(SETTINGS_FILE).py
	@echo.>> $(SETTINGS_FILE).py
	@echo ROOT_URLCONF = '$(URLS_FILE)'>> $(SETTINGS_FILE).py
	@echo WSGI_APPLICATION = '$(WSGI_FILE).application'>> $(SETTINGS_FILE).py
	@echo.>> $(SETTINGS_FILE).py
	@echo DEBUG = True>> $(SETTINGS_FILE).py
	@echo ALLOWED_HOSTS = []>> $(SETTINGS_FILE).py
	@echo SECRET_KEY = 'django-insecure-secret-key'>> $(SETTINGS_FILE).py
	@echo DEFAULT_AUTO_FIELD = 'django.db.models.BigAutoField'>> $(SETTINGS_FILE).py
	@echo.>> $(SETTINGS_FILE).py
	@echo try: open('__init__.py','r')>> $(SETTINGS_FILE).py
	@echo except IOError: open('__init__.py', 'w+')>> $(SETTINGS_FILE).py
	@echo.>> $(SETTINGS_FILE).py
	@echo APPS_FOLDER = 'apps'>> $(SETTINGS_FILE).py
	@echo APPS_PATH = BASE_DIR / APPS_FOLDER>> $(SETTINGS_FILE).py
	@echo if not os.path.exists(APPS_PATH): os.mkdir(APPS_FOLDER)>> $(SETTINGS_FILE).py
	@echo sys.path.insert(0, os.path.join(BASE_DIR, APPS_FOLDER))>> $(SETTINGS_FILE).py
	@echo.>> $(SETTINGS_FILE).py
	@echo if not os.path.exists(BASE_DIR/'static'): os.mkdir('static')>> $(SETTINGS_FILE).py
	@echo STATIC_URL = 'static/'>> $(SETTINGS_FILE).py
	@echo STATICFILES_DIRS = [os.path.join(BASE_DIR, 'static'),]>> $(SETTINGS_FILE).py
	@echo if not os.path.exists(BASE_DIR/'uploads'): os.mkdir('uploads')>> $(SETTINGS_FILE).py
	@echo MEDIA_URL = '/uploads/'>> $(SETTINGS_FILE).py
	@echo MEDIA_ROOT = os.path.join(BASE_DIR, 'uploads')>> $(SETTINGS_FILE).py
	@echo.>> $(SETTINGS_FILE).py
	@echo EMAIL_BACKEND = 'django.core.mail.backends.console.EmailBackend'>> $(SETTINGS_FILE).py
	@echo EMAIL_BACKEND = "django.core.mail.backends.filebased.EmailBackend">> $(SETTINGS_FILE).py
	@echo EMAIL_FILE_PATH = BASE_DIR / 'emails'>> $(SETTINGS_FILE).py
	@echo if not os.path.exists(BASE_DIR/'emails'): os.mkdir('emails')>> $(SETTINGS_FILE).py
	@echo.>> $(SETTINGS_FILE).py
	@echo USE_TZ = True>> $(SETTINGS_FILE).py
	@echo USE_L10N = True>> $(SETTINGS_FILE).py
	@echo TIME_ZONE = 'UTC'>> $(SETTINGS_FILE).py
	@echo.>> $(SETTINGS_FILE).py
	@echo USE_I18N = True>> $(SETTINGS_FILE).py
	@echo LANGUAGE_CODE = 'en'>> $(SETTINGS_FILE).py
	@echo LOCALE_PATHS = [BASE_DIR / 'locale/',]>> $(SETTINGS_FILE).py
	@echo LANGUAGES = (>> $(SETTINGS_FILE).py
	@echo 	('en', _('English')),>> $(SETTINGS_FILE).py
	@echo 	('vi', _('Vietnamese')),>> $(SETTINGS_FILE).py
	@echo 	('ja', _('Japanese')),>> $(SETTINGS_FILE).py
	@echo )>> $(SETTINGS_FILE).py
	@echo if not os.path.exists(BASE_DIR / 'locale'): os.mkdir('locale')>> $(SETTINGS_FILE).py
	@echo for lang in LANGUAGES:>> $(SETTINGS_FILE).py
	@echo 	if not os.path.exists(BASE_DIR / 'locale' / lang[0]): os.mkdir(BASE_DIR / 'locale' / lang[0])>> $(SETTINGS_FILE).py
	@echo 	if not os.path.exists(BASE_DIR / 'locale' / lang[0] / 'LC_MESSAGES'): os.mkdir(BASE_DIR / 'locale' / lang[0] / 'LC_MESSAGES')>> $(SETTINGS_FILE).py
	@echo.>> $(SETTINGS_FILE).py
	@echo INSTALLED_APPS = [>> $(SETTINGS_FILE).py
	@echo 	'django.contrib.admin',>> $(SETTINGS_FILE).py
	@echo 	'django.contrib.auth',>> $(SETTINGS_FILE).py
	@echo 	'django.contrib.contenttypes',>> $(SETTINGS_FILE).py
	@echo 	'django.contrib.sessions',>> $(SETTINGS_FILE).py
	@echo 	'django.contrib.messages',>> $(SETTINGS_FILE).py
	@echo 	'django.contrib.staticfiles',>> $(SETTINGS_FILE).py
	@echo ]>> $(SETTINGS_FILE).py
	@echo.>> $(SETTINGS_FILE).py
	@echo MIDDLEWARE = [>> $(SETTINGS_FILE).py
	@echo 	'django.middleware.security.SecurityMiddleware',>> $(SETTINGS_FILE).py
	@echo 	'django.contrib.sessions.middleware.SessionMiddleware',>> $(SETTINGS_FILE).py
	@echo 	'django.middleware.locale.LocaleMiddleware',    # Language Middleware>> $(SETTINGS_FILE).py
	@echo 	'django.middleware.common.CommonMiddleware',>> $(SETTINGS_FILE).py
	@echo 	'django.middleware.csrf.CsrfViewMiddleware',>> $(SETTINGS_FILE).py
	@echo 	'django.contrib.auth.middleware.AuthenticationMiddleware',>> $(SETTINGS_FILE).py
	@echo 	'django.contrib.messages.middleware.MessageMiddleware',>> $(SETTINGS_FILE).py
	@echo 	'django.middleware.clickjacking.XFrameOptionsMiddleware',>> $(SETTINGS_FILE).py
	@echo ]>> $(SETTINGS_FILE).py
	@echo.>> $(SETTINGS_FILE).py
	@echo if not os.path.exists(BASE_DIR / 'templates'): os.mkdir('templates')>> $(SETTINGS_FILE).py
	@echo TEMPLATES = [>> $(SETTINGS_FILE).py
	@echo 	{>> $(SETTINGS_FILE).py
	@echo 		'BACKEND': 'django.template.backends.django.DjangoTemplates',>> $(SETTINGS_FILE).py
	@echo 		'DIRS': [os.path.join(BASE_DIR, 'templates')],>> $(SETTINGS_FILE).py
	@echo 		'APP_DIRS': True,>> $(SETTINGS_FILE).py
	@echo 		'OPTIONS': {>> $(SETTINGS_FILE).py
	@echo 			'context_processors': [>> $(SETTINGS_FILE).py
	@echo 				'django.template.context_processors.debug',>> $(SETTINGS_FILE).py
	@echo 				'django.template.context_processors.request',>> $(SETTINGS_FILE).py
	@echo 				'django.contrib.auth.context_processors.auth',>> $(SETTINGS_FILE).py
	@echo 				'django.contrib.messages.context_processors.messages',>> $(SETTINGS_FILE).py
	@echo 			],>> $(SETTINGS_FILE).py
	@echo 		},>> $(SETTINGS_FILE).py
	@echo 	},>> $(SETTINGS_FILE).py
	@echo ]>> $(SETTINGS_FILE).py
	@echo.>> $(SETTINGS_FILE).py
	@echo DATABASES = {>> $(SETTINGS_FILE).py
	@echo 	'default': {>> $(SETTINGS_FILE).py
	@echo 		'ENGINE': 'django.db.backends.sqlite3',>> $(SETTINGS_FILE).py
	@echo 		'NAME': BASE_DIR / 'db.sqlite3',>> $(SETTINGS_FILE).py
	@echo 	}>> $(SETTINGS_FILE).py
	@echo }>> $(SETTINGS_FILE).py
	@echo.>> $(SETTINGS_FILE).py
	@echo AUTH_PASSWORD_VALIDATORS = [>> $(SETTINGS_FILE).py
	@echo 	{'NAME': 'django.contrib.auth.password_validation.UserAttributeSimilarityValidator',},>> $(SETTINGS_FILE).py
	@echo 	{'NAME': 'django.contrib.auth.password_validation.MinimumLengthValidator',},>> $(SETTINGS_FILE).py
	@echo 	{'NAME': 'django.contrib.auth.password_validation.CommonPasswordValidator',},>> $(SETTINGS_FILE).py
	@echo 	{'NAME': 'django.contrib.auth.password_validation.NumericPasswordValidator',},>> $(SETTINGS_FILE).py
	@echo ]>> $(SETTINGS_FILE).py

# All
.PHONY: all
all:
	python $(MANAGE_FILE).py makemigrations
	python $(MANAGE_FILE).py migrate
	python $(MANAGE_FILE).py shell -c "from django.contrib.auth.models import User; \
		User.objects.filter(username='admin').exists() or \
		User.objects.create_superuser('admin', 'admin@admin.com', 'admin')"
	python $(MANAGE_FILE).py runserver $(SERVER_PORT)

# Create env
.PHONY: env
env:
	pip install -r requirements.txt

# Runserver
.PHONY: server
server:
	python $(MANAGE_FILE).py runserver $(SERVER_PORT)

# Create superuser
.PHONY: admin
admin:
	python $(MANAGE_FILE).py shell -c "from django.contrib.auth.models import User; \
	User.objects.filter(username='admin').exists() or \
	User.objects.create_superuser('admin', 'admin@example.com', 'admin')"

# Create new app
ifeq (app,$(firstword $(MAKECMDGOALS)))
  ARGS := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
  $(eval $(ARGS):;@:)
endif
.PHONY: app
app:
	mkdir apps\$(ARGS)
	django-admin startapp $(ARGS) apps\$(ARGS)
	@echo.>> apps\$(ARGS)\apps.py	
	@echo from $(MANAGE_FILE) import INSTALLED_APPS  >> apps\$(ARGS)\apps.py	
	@echo INSTALLED_APPS += ['$(ARGS)',]  >> apps\$(ARGS)\apps.py	

	@echo *.py > apps\$(ARGS)\migrations\.gitignore
	@echo !__init__.py >> apps\$(ARGS)\migrations\.gitignore

	@echo from django.apps import apps > apps\$(ARGS)\admin.py
	@echo from django.contrib import admin >> apps\$(ARGS)\admin.py
	@echo from django.contrib.admin.sites import AlreadyRegistered >> apps\$(ARGS)\admin.py
	@echo. >> apps\$(ARGS)\admin.py
	@echo for model in apps.get_app_config('$(ARGS)').get_models(): >> apps\$(ARGS)\admin.py
	@echo 	try: admin.site.register(model) >> apps\$(ARGS)\admin.py
	@echo 	except AlreadyRegistered: pass >> apps\$(ARGS)\admin.py

	@echo from django.urls import path >> apps\$(ARGS)\urls.py
	@echo from .views import * >> apps\$(ARGS)\urls.py
	@echo. >> apps\$(ARGS)\urls.py
	@echo urlpatterns = [ >> apps\$(ARGS)\urls.py
	@echo. >> apps\$(ARGS)\urls.py
	@echo ] >> apps\$(ARGS)\urls.py

	@echo from django.shortcuts import render, HttpResponse > apps\$(ARGS)\views.py
	@echo from django.urls import path, include >> apps\$(ARGS)\views.py
	@echo.  >> apps\$(ARGS)\views.py
	@echo inc_path = path('$(ARGS)/', include('$(ARGS).urls')) >> apps\$(ARGS)\views.py
	@echo. >> apps\$(ARGS)\views.py
# Push
.PHONY: git
git:
	git add .
	git commit -m up
	git push

.PHONY: ignore
ignore:
	@echo __pycache__ > .gitignore

.PHONY: message
message:
	django-admin makemessages --all --ignore=env

.PHONY: lang
lang:
	django-admin compilemessages --ignore=env