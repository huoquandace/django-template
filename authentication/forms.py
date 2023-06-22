from django import forms
from django.contrib.auth.forms import *
from django.core import exceptions
from django.utils.translation import gettext_lazy as _


class AuthForm(AuthenticationForm):
    error_messages = { 'invalid_login': _('Invalid login'), 'inactive': _('Inactive'), }
    def confirm_login_allowed(self, user):
        if not user.is_active: raise exceptions.ValidationError(_('User inactive'), code='inactive')