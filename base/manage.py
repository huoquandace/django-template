import os, sys
from importlib.machinery import SourceFileLoader
from pathlib import Path
from django.utils.translation import gettext_lazy as _

SECRET_KEY = 'django-insecure-secret-key'
BASE_DIR = Path(__file__).resolve().parent
BASE_FILE_NAME = os.path.basename(__file__).split('.')[0]

try: open('__init__.py','r')
except IOError: open('__init__.py', 'w+')

if __name__ == '__main__':
	os.environ.setdefault('DJANGO_SETTINGS_MODULE', BASE_FILE_NAME)
	try: from django.core.management import execute_from_command_line
	except ImportError as exc: raise ImportError("Forget venv?") from exc
	execute_from_command_line(sys.argv)

DEBUG = True
ALLOWED_HOSTS = []

ROOT_URLCONF = BASE_FILE_NAME
WSGI_APPLICATION = BASE_FILE_NAME + '.application'

DEFAULT_AUTO_FIELD = 'django.db.models.BigAutoField'

# Static and media
if not os.path.exists(BASE_DIR/'static'): os.mkdir('static')
STATIC_URL = 'static/'
STATICFILES_DIRS = [os.path.join(BASE_DIR, 'static'),]
if not os.path.exists(BASE_DIR/'uploads'): os.mkdir('uploads')
MEDIA_URL = '/uploads/'
MEDIA_ROOT = os.path.join(BASE_DIR, 'uploads')

# Email configs
EMAIL_BACKEND = 'django.core.mail.backends.console.EmailBackend'
EMAIL_BACKEND = "django.core.mail.backends.filebased.EmailBackend"
EMAIL_FILE_PATH = BASE_DIR / 'emails'
if not os.path.exists(BASE_DIR/'emails'): os.mkdir('emails')

# Time configs
USE_TZ = True
USE_L10N = True
TIME_ZONE = 'UTC'

# Language configs
USE_I18N = True
LANGUAGE_CODE = 'en'
LOCALE_PATHS = [BASE_DIR / 'locale/',]
LANGUAGES = (
	('en', _('English')),
	('vi', _('Vietnamese')),
	('ja', _('Japanese')),
)
if not os.path.exists(BASE_DIR / 'locale'): os.mkdir('locale')
for lang in LANGUAGES:
	if not os.path.exists(BASE_DIR / 'locale' / lang[0]): os.mkdir(BASE_DIR / 'locale' / lang[0])
	if not os.path.exists(BASE_DIR / 'locale' / lang[0] / 'LC_MESSAGES'): os.mkdir(BASE_DIR / 'locale' / lang[0] / 'LC_MESSAGES')

INSTALLED_APPS = [
	'django.contrib.admin',
	'django.contrib.auth',
	'django.contrib.contenttypes',
	'django.contrib.sessions',
	'django.contrib.messages',
	'django.contrib.staticfiles',
]

if os.path.exists(BASE_DIR / 'apps/authentication'): AUTH_USER_MODEL = 'authentication.User'

MIDDLEWARE = [
	'django.middleware.security.SecurityMiddleware',
	'django.contrib.sessions.middleware.SessionMiddleware',
	'django.middleware.locale.LocaleMiddleware',    # Language Middleware
	'django.middleware.common.CommonMiddleware',
	'django.middleware.csrf.CsrfViewMiddleware',
	'django.contrib.auth.middleware.AuthenticationMiddleware',
	'django.contrib.messages.middleware.MessageMiddleware',
	'django.middleware.clickjacking.XFrameOptionsMiddleware',
]

if not os.path.exists(BASE_DIR / 'templates'): os.mkdir('templates')

TEMPLATES = [
	{
		'BACKEND': 'django.template.backends.django.DjangoTemplates',
		'DIRS': [os.path.join(BASE_DIR, 'templates')],
		'APP_DIRS': True,
		'OPTIONS': {
			'context_processors': [
				'django.template.context_processors.debug',
				'django.template.context_processors.request',
				'django.contrib.auth.context_processors.auth',
				'django.contrib.messages.context_processors.messages',
			],
		},
	},
]

DATABASES = {
	'default': {
		'ENGINE': 'django.db.backends.sqlite3',
		'NAME': BASE_DIR / 'db.sqlite3',
	}
}

AUTH_PASSWORD_VALIDATORS = [
	{'NAME': 'django.contrib.auth.password_validation.UserAttributeSimilarityValidator',},
	{'NAME': 'django.contrib.auth.password_validation.MinimumLengthValidator',},
	{'NAME': 'django.contrib.auth.password_validation.CommonPasswordValidator',},
	{'NAME': 'django.contrib.auth.password_validation.NumericPasswordValidator',},
]

### Import App
APPS_FOLDER = 'apps'
APPS_PATH = BASE_DIR / APPS_FOLDER
if not os.path.exists(APPS_PATH): os.mkdir(APPS_FOLDER)
sys.path.insert(0, os.path.join(BASE_DIR, APPS_FOLDER))
for file in os.listdir(APPS_PATH):
	if os.path.isdir(os.path.join(APPS_PATH, file)):
		try: __import__(file + '.apps', fromlist='__all__')
		except ImportError: pass

# Wsgi configs
from django.core.wsgi import get_wsgi_application
os.environ.setdefault('DJANGO_SETTINGS_MODULE', BASE_FILE_NAME)
application = get_wsgi_application()

# Urls
from django.conf import settings
from django.conf.urls.static import static
from django.contrib import admin
from django.urls import path, include
from django.conf.urls.i18n import i18n_patterns

urlpatterns = [
	path('admin/', admin.site.urls),
	path('i18n/', include('django.conf.urls.i18n')),
]

for file in os.listdir(APPS_PATH):
	try:
		foo = SourceFileLoader('views.py', os.path.join(os.path.join(APPS_PATH, file), 'views.py')).load_module()
		urlpatterns += i18n_patterns(foo.inc_path,)
	except: pass

# urlpatterns += i18n_patterns (
	# prefix_default_language=False
# )
urlpatterns += static(settings.STATIC_URL, document_root=settings.STATIC_ROOT)
urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)
