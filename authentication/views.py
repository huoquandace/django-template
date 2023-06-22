from django.shortcuts import render, HttpResponse, redirect 
from django.urls import path, include, URLPattern, URLResolver, reverse_lazy, reverse
from django import forms
from django.views import generic
from django.contrib.auth import get_user_model, backends
from django.contrib.auth.views import *
from django.contrib.auth.mixins import *
from django.contrib.auth.forms import *
from django.core import exceptions
from django.utils.translation import gettext_lazy as _

from authentication.models import Profile

inc_path = path('authentication/', include('authentication.urls'))


class AuthModelBackend(backends.ModelBackend):
    def user_can_authenticate(self, user):
        return True

class AuthIndexView(generic.TemplateView):
    template_name = 'authentication/index.html'
    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        urlconf = __import__('apps.authentication.urls', {}, {}, [''])
        def list_urls(lis, acc=None):
            acc = [] if acc is None else acc
            if not lis: return None
            l = lis[0]
            if isinstance(l, URLPattern): yield acc + [str(l.pattern)]
            elif isinstance(l, URLResolver): yield from list_urls(l.url_patterns, acc + [str(l.pattern)])
            yield from list_urls(lis[1:], acc)
        url_list = []
        for p in list_urls(urlconf.urlpatterns, ['']):
            url_list.append(''.join(p)) 
        context['url_list'] = url_list
        return context
    
class AuthLoginView(LoginView):
    class AuthForm(AuthenticationForm):
        error_messages = { 'invalid_login': _('Invalid login'), 'inactive': _('Inactive'), }
        def confirm_login_allowed(self, user):
            if not user.is_active: raise exceptions.ValidationError(_('User inactive'), code='inactive')
    authentication_form = AuthForm
    template_name = 'authentication/login.html'
    login_url = reverse_lazy('authentication:login')
    next_page = reverse_lazy('authentication:index')
    redirect_authenticated_user = True # If it is false, authenticated_user is still access to login

class AuthLogoutView(LogoutView):
    # template_name = 'authentication/logged_out.html'
    next_page = reverse_lazy('authentication:login') # if not default render to template

class AuthPasswordChangeView(LoginRequiredMixin, PasswordChangeView):
    template_name = 'authentication/password_change_form.html'
    success_url = reverse_lazy('authentication:password_change_done')

class AuthPasswordChangeDoneView(LoginRequiredMixin, PasswordChangeDoneView):
    template_name = 'authentication/password_change_done.html'

class AuthPasswordResetView(PasswordResetView):
    template_name = 'authentication/password_reset_form.html'
    success_url = reverse_lazy('authentication:password_reset_done')
    from_email = 'system@sys.com'
    email_template_name = 'authentication/password_reset_email.html'
    subject_template_name = 'authentication/password_reset_subject.txt'

class AuthPasswordResetDoneView(PasswordResetDoneView):
    template_name = 'authentication/password_reset_done.html'

class AuthPasswordResetConfirmView(PasswordResetConfirmView):
    template_name = 'authentication/password_reset_confirm.html'
    success_url = reverse_lazy('authentication:password_reset_complete')

class AuthPasswordResetCompleteView(PasswordResetCompleteView):
    template_name = 'authentication/password_reset_complete.html'

class AuthRegisterView(generic.FormView):
    class RegisterForm(UserCreationForm):
        class Meta:
            model = get_user_model()
            fields = ('username', 'email')
            field_classes = {'username': UsernameField}
            widgets = {'email': forms.EmailInput(attrs={'required': True})}
    template_name = 'authentication/register.html'
    form_class = RegisterForm
    def form_valid(self, form):
        new_user = get_user_model().objects.create_user(
            username = form.cleaned_data['username'],
            password = form.cleaned_data['password1'],
            email = form.cleaned_data['email'],
        )
        url = f"{reverse('authentication:register_done')}?username={new_user.username}"
        return redirect(url)

class AuthRegisterDoneView(generic.TemplateView):
    template_name = 'authentication/register_done.html'
    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        context['username'] = self.request.GET.get('username')
        return context
    
class AuthProfileView(LoginRequiredMixin, generic.TemplateView):
    template_name = 'authentication/profile.html'
