MANAGE_FILE:=main.py
SERVER_PORT:=80

# All
.PHONY: all
all:
	python $(MANAGE_FILE) makemigrations
	python $(MANAGE_FILE) migrate
	python $(MANAGE_FILE) shell -c "from django.contrib.auth.models import User; \
		User.objects.filter(username='admin').exists() or \
		User.objects.create_superuser('admin', 'admin@example.com', 'admin')"
	python $(MANAGE_FILE) runserver $(SERVER_PORT)

# Create env
.PHONY: env
env:
	pip install -r requirements.txt

# Runserver
.PHONY: server
server:
	python $(MANAGE_FILE) runserver $(SERVER_PORT)

# Create superuser
.PHONY: admin
admin:
	python $(MANAGE_FILE) shell -c "from django.contrib.auth.models import User; \
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
	echo from configs.settings import INSTALLED_APPS > apps\$(ARGS)\settings.py
	echo. >> apps\$(ARGS)\settings.py
	echo INSTALLED_APPS += ['$(ARGS)',] >> apps\$(ARGS)\settings.py

# Push
.PHONY: git
git:
	git add .
	git commit -m up
	git push