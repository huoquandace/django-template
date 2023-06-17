MANAGE_FILE:=main
SERVER_PORT:=80

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
	echo from $(MANAGE_FILE) import INSTALLED_APPS > apps\$(ARGS)\settings.py
	echo. >> apps\$(ARGS)\settings.py
	echo INSTALLED_APPS += ['$(ARGS)',] >> apps\$(ARGS)\settings.py

# Push
.PHONY: git
git:
	git add .
	git commit -m up
	git push