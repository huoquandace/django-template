# chocolate
# @"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "[System.Net.ServicePointManager]::SecurityProtocol = 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))" && SET "PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin"
# make
# choco install make

MANAGE_FILE:=manage
SERVER_PORT:=80

# All
.PHONY: all
all:
	python $(MANAGE_FILE).py makemigrations
	python $(MANAGE_FILE).py migrate
	python $(MANAGE_FILE).py shell -c "from django.contrib.auth.models import get_user_model; \
		get_user_model().objects.filter(username='admin').exists() or \
		get_user_model().objects.create_superuser('admin', 'admin@admin.com', 'admin')"
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

# manage
.PHONY: manage
manage:
	@echo import os, sys> $(MANAGE_FILE).py
	@echo from importlib.machinery import SourceFileLoader>> $(MANAGE_FILE).py
	@echo from pathlib import Path>> $(MANAGE_FILE).py
	@echo from django.utils.translation import gettext_lazy as _>> $(MANAGE_FILE).py
	@echo.>> $(MANAGE_FILE).py
	@echo SECRET_KEY = 'django-insecure-secret-key'>> $(MANAGE_FILE).py
	@echo BASE_DIR = Path(__file__).resolve().parent>> $(MANAGE_FILE).py
	@echo BASE_FILE_NAME = os.path.basename(__file__).split('.')[0]>> $(MANAGE_FILE).py
	@echo.>> $(MANAGE_FILE).py
	@echo try: open('__init__.py','r')>> $(MANAGE_FILE).py
	@echo except IOError: open('__init__.py', 'w+')>> $(MANAGE_FILE).py
	@echo.>> $(MANAGE_FILE).py
	@echo if __name__ == '__main__':>> $(MANAGE_FILE).py
	@echo 	os.environ.setdefault('DJANGO_SETTINGS_MODULE', BASE_FILE_NAME)>> $(MANAGE_FILE).py
	@echo 	try: from django.core.management import execute_from_command_line>> $(MANAGE_FILE).py
	@echo 	except ImportError as exc: raise ImportError("Forget venv?") from exc>> $(MANAGE_FILE).py
	@echo 	execute_from_command_line(sys.argv)>> $(MANAGE_FILE).py
	@echo.>> $(MANAGE_FILE).py
	@echo DEBUG = True>> $(MANAGE_FILE).py
	@echo ALLOWED_HOSTS = []>> $(MANAGE_FILE).py
	@echo.>> $(MANAGE_FILE).py
	@echo ROOT_URLCONF = BASE_FILE_NAME>> $(MANAGE_FILE).py
	@echo WSGI_APPLICATION = BASE_FILE_NAME + '.application'>> $(MANAGE_FILE).py
	@echo.>> $(MANAGE_FILE).py
	@echo DEFAULT_AUTO_FIELD = 'django.db.models.BigAutoField'>> $(MANAGE_FILE).py
	@echo.>> $(MANAGE_FILE).py
	@echo # Static and media>> $(MANAGE_FILE).py
	@echo if not os.path.exists(BASE_DIR/'static'): os.mkdir('static')>> $(MANAGE_FILE).py
	@echo STATIC_URL = 'static/'>> $(MANAGE_FILE).py
	@echo STATICFILES_DIRS = [os.path.join(BASE_DIR, 'static'),]>> $(MANAGE_FILE).py
	@echo if not os.path.exists(BASE_DIR/'uploads'): os.mkdir('uploads')>> $(MANAGE_FILE).py
	@echo MEDIA_URL = '/uploads/'>> $(MANAGE_FILE).py
	@echo MEDIA_ROOT = os.path.join(BASE_DIR, 'uploads')>> $(MANAGE_FILE).py
	@echo.>> $(MANAGE_FILE).py
	@echo # Email configs>> $(MANAGE_FILE).py
	@echo EMAIL_BACKEND = 'django.core.mail.backends.console.EmailBackend'>> $(MANAGE_FILE).py
	@echo EMAIL_BACKEND = "django.core.mail.backends.filebased.EmailBackend">> $(MANAGE_FILE).py
	@echo EMAIL_FILE_PATH = BASE_DIR / 'emails'>> $(MANAGE_FILE).py
	@echo if not os.path.exists(BASE_DIR/'emails'): os.mkdir('emails')>> $(MANAGE_FILE).py
	@echo.>> $(MANAGE_FILE).py
	@echo # Time configs>> $(MANAGE_FILE).py
	@echo USE_TZ = True>> $(MANAGE_FILE).py
	@echo USE_L10N = True>> $(MANAGE_FILE).py
	@echo TIME_ZONE = 'UTC'>> $(MANAGE_FILE).py
	@echo.>> $(MANAGE_FILE).py
	@echo # Language configs>> $(MANAGE_FILE).py
	@echo USE_I18N = True>> $(MANAGE_FILE).py
	@echo LANGUAGE_CODE = 'en'>> $(MANAGE_FILE).py
	@echo LOCALE_PATHS = [BASE_DIR / 'locale/',]>> $(MANAGE_FILE).py
	@echo LANGUAGES = (>> $(MANAGE_FILE).py
	@echo 	('en', _('English')),>> $(MANAGE_FILE).py
	@echo 	('vi', _('Vietnamese')),>> $(MANAGE_FILE).py
	@echo 	('ja', _('Japanese')),>> $(MANAGE_FILE).py
	@echo )>> $(MANAGE_FILE).py
	@echo if not os.path.exists(BASE_DIR / 'locale'): os.mkdir('locale')>> $(MANAGE_FILE).py
	@echo for lang in LANGUAGES:>> $(MANAGE_FILE).py
	@echo 	if not os.path.exists(BASE_DIR / 'locale' / lang[0]): os.mkdir(BASE_DIR / 'locale' / lang[0])>> $(MANAGE_FILE).py
	@echo 	if not os.path.exists(BASE_DIR / 'locale' / lang[0] / 'LC_MESSAGES'): os.mkdir(BASE_DIR / 'locale' / lang[0] / 'LC_MESSAGES')>> $(MANAGE_FILE).py
	@echo.>> $(MANAGE_FILE).py
	@echo INSTALLED_APPS = [>> $(MANAGE_FILE).py
	@echo 	'django.contrib.admin',>> $(MANAGE_FILE).py
	@echo 	'django.contrib.auth',>> $(MANAGE_FILE).py
	@echo 	'django.contrib.contenttypes',>> $(MANAGE_FILE).py
	@echo 	'django.contrib.sessions',>> $(MANAGE_FILE).py
	@echo 	'django.contrib.messages',>> $(MANAGE_FILE).py
	@echo 	'django.contrib.staticfiles',>> $(MANAGE_FILE).py
	@echo ]>> $(MANAGE_FILE).py
	@echo.>> $(MANAGE_FILE).py
	@echo MIDDLEWARE = [>> $(MANAGE_FILE).py
	@echo 	'django.middleware.security.SecurityMiddleware',>> $(MANAGE_FILE).py
	@echo 	'django.contrib.sessions.middleware.SessionMiddleware',>> $(MANAGE_FILE).py
	@echo 	'django.middleware.locale.LocaleMiddleware',    # Language Middleware>> $(MANAGE_FILE).py
	@echo 	'django.middleware.common.CommonMiddleware',>> $(MANAGE_FILE).py
	@echo 	'django.middleware.csrf.CsrfViewMiddleware',>> $(MANAGE_FILE).py
	@echo 	'django.contrib.auth.middleware.AuthenticationMiddleware',>> $(MANAGE_FILE).py
	@echo 	'django.contrib.messages.middleware.MessageMiddleware',>> $(MANAGE_FILE).py
	@echo 	'django.middleware.clickjacking.XFrameOptionsMiddleware',>> $(MANAGE_FILE).py
	@echo ]>> $(MANAGE_FILE).py
	@echo.>> $(MANAGE_FILE).py
	@echo TEMPLATES = [>> $(MANAGE_FILE).py
	@echo 	{>> $(MANAGE_FILE).py
	@echo 		'BACKEND': 'django.template.backends.django.DjangoTemplates',>> $(MANAGE_FILE).py
	@echo 		'DIRS': [os.path.join(BASE_DIR, 'templates')],>> $(MANAGE_FILE).py
	@echo 		'APP_DIRS': True,>> $(MANAGE_FILE).py
	@echo 		'OPTIONS': {>> $(MANAGE_FILE).py
	@echo 			'context_processors': [>> $(MANAGE_FILE).py
	@echo 				'django.template.context_processors.debug',>> $(MANAGE_FILE).py
	@echo 				'django.template.context_processors.request',>> $(MANAGE_FILE).py
	@echo 				'django.contrib.auth.context_processors.auth',>> $(MANAGE_FILE).py
	@echo 				'django.contrib.messages.context_processors.messages',>> $(MANAGE_FILE).py
	@echo 			],>> $(MANAGE_FILE).py
	@echo 		},>> $(MANAGE_FILE).py
	@echo 	},>> $(MANAGE_FILE).py
	@echo ]>> $(MANAGE_FILE).py
	@echo.>> $(MANAGE_FILE).py
	@echo DATABASES = {>> $(MANAGE_FILE).py
	@echo 	'default': {>> $(MANAGE_FILE).py
	@echo 		'ENGINE': 'django.db.backends.sqlite3',>> $(MANAGE_FILE).py
	@echo 		'NAME': BASE_DIR / 'db.sqlite3',>> $(MANAGE_FILE).py
	@echo 	}>> $(MANAGE_FILE).py
	@echo }>> $(MANAGE_FILE).py
	@echo.>> $(MANAGE_FILE).py
	@echo AUTH_PASSWORD_VALIDATORS = [>> $(MANAGE_FILE).py
	@echo 	{'NAME': 'django.contrib.auth.password_validation.UserAttributeSimilarityValidator',},>> $(MANAGE_FILE).py
	@echo 	{'NAME': 'django.contrib.auth.password_validation.MinimumLengthValidator',},>> $(MANAGE_FILE).py
	@echo 	{'NAME': 'django.contrib.auth.password_validation.CommonPasswordValidator',},>> $(MANAGE_FILE).py
	@echo 	{'NAME': 'django.contrib.auth.password_validation.NumericPasswordValidator',},>> $(MANAGE_FILE).py
	@echo ]>> $(MANAGE_FILE).py
	@echo.>> $(MANAGE_FILE).py
	@echo ### Import App>> $(MANAGE_FILE).py
	@echo APPS_FOLDER = 'apps'>> $(MANAGE_FILE).py
	@echo APPS_PATH = BASE_DIR / APPS_FOLDER>> $(MANAGE_FILE).py
	@echo if not os.path.exists(APPS_PATH): os.mkdir(APPS_FOLDER)>> $(MANAGE_FILE).py
	@echo sys.path.insert(0, os.path.join(BASE_DIR, APPS_FOLDER))>> $(MANAGE_FILE).py
	@echo.>> $(MANAGE_FILE).py
	@echo apps_dir = os.listdir(APPS_PATH)>> $(MANAGE_FILE).py
	@echo for file in apps_dir:>> $(MANAGE_FILE).py
	@echo 	dir= os.path.join(APPS_PATH, file)>> $(MANAGE_FILE).py
	@echo 	if os.path.isdir(dir):>> $(MANAGE_FILE).py
	@echo 		try: __import__(dir.split('\\')[-1] + '.apps', fromlist='__all__')>> $(MANAGE_FILE).py
	@echo 		except ImportError: pass>> $(MANAGE_FILE).py
	@echo.>> $(MANAGE_FILE).py
	@echo # Wsgi configs>> $(MANAGE_FILE).py
	@echo from django.core.wsgi import get_wsgi_application>> $(MANAGE_FILE).py
	@echo os.environ.setdefault('DJANGO_SETTINGS_MODULE', BASE_FILE_NAME)>> $(MANAGE_FILE).py
	@echo application = get_wsgi_application()>> $(MANAGE_FILE).py
	@echo.>> $(MANAGE_FILE).py
	@echo # Urls>> $(MANAGE_FILE).py
	@echo from django.conf import settings>> $(MANAGE_FILE).py
	@echo from django.conf.urls.static import static>> $(MANAGE_FILE).py
	@echo from django.contrib import admin>> $(MANAGE_FILE).py
	@echo from django.urls import path, include>> $(MANAGE_FILE).py
	@echo from django.conf.urls.i18n import i18n_patterns>> $(MANAGE_FILE).py
	@echo.>> $(MANAGE_FILE).py
	@echo urlpatterns = [>> $(MANAGE_FILE).py
	@echo 	path('admin/', admin.site.urls),>> $(MANAGE_FILE).py
	@echo 	path('i18n/', include('django.conf.urls.i18n')),>> $(MANAGE_FILE).py
	@echo ]>> $(MANAGE_FILE).py
	@echo.>> $(MANAGE_FILE).py
	@echo for file in apps_dir:>> $(MANAGE_FILE).py
	@echo 	dir= os.path.join(APPS_PATH, file) >> $(MANAGE_FILE).py
	@echo 	full_path = os.path.join(dir, 'views.py')>> $(MANAGE_FILE).py
	@echo 	foo = SourceFileLoader('views.py', full_path).load_module()>> $(MANAGE_FILE).py
	@echo 	urlpatterns += i18n_patterns(foo.inc_path,)>> $(MANAGE_FILE).py
	@echo.>> $(MANAGE_FILE).py
	@echo # urlpatterns += i18n_patterns (>> $(MANAGE_FILE).py
	@echo 	# prefix_default_language=False>> $(MANAGE_FILE).py
	@echo # )>> $(MANAGE_FILE).py
	@echo urlpatterns += static(settings.STATIC_URL, document_root=settings.STATIC_ROOT)>> $(MANAGE_FILE).py
	@echo urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)>> $(MANAGE_FILE).py

.PHONY: message
message:
	django-admin makemessages --all --ignore=env

.PHONY: lang
lang:
	django-admin compilemessages --ignore=env