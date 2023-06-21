from django.shortcuts import render, HttpResponse 
from django.urls import path, include, URLPattern, URLResolver, reverse_lazy
from django.views import generic
from django.contrib.auth.views import *
from django.contrib.auth.mixins import *
from django.contrib.auth.forms import *
from django.core import exceptions
from django.utils.translation import gettext_lazy as _

inc_path = path('authentication/', include('authentication.urls')) 
 

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