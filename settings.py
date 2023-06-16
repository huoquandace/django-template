import os, sys
from pathlib import Path
from datetime import timedelta
from django.utils.translation import gettext_lazy as _

BASE_DIR = Path(__file__).resolve().parent

SECRET_KEY = 'django-insecure-415p1#a=bn7(r^)h0*^&55q@^su68tzmjnj^8xmv*+iy36c0f9'

DEBUG = True
ALLOWED_HOSTS = []

ROOT_URLCONF = 'urls'
WSGI_APPLICATION = 'settings.application'


DEFAULT_AUTO_FIELD = 'django.db.models.BigAutoField'

INSTALLED_APPS = [
    'django.contrib.admin',
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.messages',
    'django.contrib.staticfiles',
]

MIDDLEWARE = [
    'django.middleware.security.SecurityMiddleware',
    'django.contrib.sessions.middleware.SessionMiddleware',
    'django.middleware.common.CommonMiddleware',
    'django.middleware.csrf.CsrfViewMiddleware',
    'django.contrib.auth.middleware.AuthenticationMiddleware',
    'django.contrib.messages.middleware.MessageMiddleware',
    'django.middleware.clickjacking.XFrameOptionsMiddleware',
]

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
    {
        'NAME': 'django.contrib.auth.password_validation.UserAttributeSimilarityValidator',
    },
    {
        'NAME': 'django.contrib.auth.password_validation.MinimumLengthValidator',
    },
    {
        'NAME': 'django.contrib.auth.password_validation.CommonPasswordValidator',
    },
    {
        'NAME': 'django.contrib.auth.password_validation.NumericPasswordValidator',
    },
]

### Import App
APPS_FOLDER = 'apps'
APPS_PATH = BASE_DIR / APPS_FOLDER
if not os.path.exists(APPS_PATH): os.mkdir(APPS_FOLDER)
sys.path.insert(0, os.path.join(BASE_DIR, APPS_FOLDER))

apps_dir = os.listdir(APPS_PATH)
for file in apps_dir:
    dir= os.path.join(APPS_PATH, file)
    if os.path.isdir(dir):
        try: __import__(dir.split('\\')[-1] + '.settings', fromlist='__all__')
        except ImportError: pass

# Static and media
if not os.path.exists(BASE_DIR/'static'): os.mkdir('static')
STATIC_URL = 'static/'
STATICFILES_DIRS = [os.path.join(BASE_DIR, 'static'),]

if not os.path.exists(BASE_DIR/'media'): os.mkdir('media')
MEDIA_URL = '/media/'
MEDIA_ROOT = os.path.join(BASE_DIR, 'media')

# Email configs
EMAIL_BACKEND = 'django.core.mail.backends.console.EmailBackend'
# EMAIL_BACKEND = "django.core.mail.backends.filebased.EmailBackend"
# EMAIL_FILE_PATH = BASE_DIR / 'emails'
# if not os.path.exists(BASE_DIR/'emails'): os.mkdir('emails')

# Time configs
USE_TZ = True
USE_L10N = True
TIME_ZONE = 'UTC'

# Language configs
USE_I18N = True
LANGUAGE_CODE = 'en'
LOCALE_PATHS = [BASE_DIR / 'locale/',]
MIDDLEWARE += ['django.middleware.locale.LocaleMiddleware',]
LANGUAGES = (
    ('en', _('English')),
    ('vi', _('Vietnamese')),
    ('ja', _('Japanese')),
)

# Wsgi configs
from django.core.wsgi import get_wsgi_application
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'settings')
application = get_wsgi_application()
