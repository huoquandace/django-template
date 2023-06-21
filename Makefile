# chocolate
# @"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "[System.Net.ServicePointManager]::SecurityProtocol = 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))" && SET "PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin"
# make
# choco install make

MANAGE_FILE:=manage
SERVER_PORT:=80
ROOT_LINK:=https://raw.githubusercontent.com/huoquandace/django-template/main

# Push
.PHONY: push
push:
	git add .
	git commit -m up
	git push

# All
.PHONY: all
all:
	python $(MANAGE_FILE).py makemigrations
	python $(MANAGE_FILE).py migrate
	python $(MANAGE_FILE).py shell -c "from django.contrib.auth import get_user_model; \
		get_user_model().objects.filter(username='admin').exists() or \
		get_user_model().objects.create_superuser('admin', 'admin@admin.com', 'admin')"
	python $(MANAGE_FILE).py runserver $(SERVER_PORT)

# Runserver
.PHONY: server
server:
	python $(MANAGE_FILE).py runserver $(SERVER_PORT)

# Create superuser
.PHONY: admin
admin:
	python $(MANAGE_FILE).py shell -c "from django.contrib.auth import get_user_model; \
		get_user_model().objects.filter(username='admin').exists() or \
		get_user_model().objects.create_superuser('admin', 'admin@admin.com', 'admin')"

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

.PHONY: init
init:
	curl -s -o manage.py $(ROOT_LINK)/base/manage.py
	curl -s -o requirements.txt $(ROOT_LINK)/base/requirements.txt
	curl -s -o .gitignore $(ROOT_LINK)/base/.gitignore
	pip install -r requirements.txt
	
	mkdir apps\authentication
	curl -s -o apps\authentication\__init__.py $(ROOT_LINK)/authentication/__init__.py
	mkdir apps\authentication\migrations
	curl -s -o apps\authentication\migrations/__init__.py $(ROOT_LINK)/authentication/migrations/__init__.py
	curl -s -o apps\authentication\migrations/.gitignore $(ROOT_LINK)/authentication/migrations/.gitignore
	curl -s -o apps\authentication\admin.py $(ROOT_LINK)/authentication/admin.py
	curl -s -o apps\authentication\apps.py $(ROOT_LINK)/authentication/apps.py
	curl -s -o apps\authentication\models.py $(ROOT_LINK)/authentication/models.py
	curl -s -o apps\authentication\urls.py $(ROOT_LINK)/authentication/urls.py
	curl -s -o apps\authentication\views.py $(ROOT_LINK)/authentication/views.py
	mkdir templates\authentication
	curl -s -o templates\authentication\index.html $(ROOT_LINK)/authentication/templates/index.html

	python $(MANAGE_FILE).py makemigrations
	python $(MANAGE_FILE).py migrate
	python $(MANAGE_FILE).py shell -c "from django.contrib.auth import get_user_model; \
		get_user_model().objects.filter(username='admin').exists() or \
		get_user_model().objects.create_superuser('admin', 'admin@admin.com', 'admin')"
	python $(MANAGE_FILE).py runserver $(SERVER_PORT)

	django-admin makemessages --all --ignore=env
	django-admin compilemessages --ignore=env