from django.shortcuts import render, HttpResponse 
from django.urls import path, include, URLPattern, URLResolver
from django.views import generic

inc_path = path('authentication/', include('authentication.urls')) 
 

class Index(generic.TemplateView):
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