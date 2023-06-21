from django.urls import path 
from .views import * 


app_name = 'authentication'

urlpatterns = [ 
    path('', AuthIndexView.as_view(), name='index'),
    path('login', AuthLoginView.as_view(), name='login'),
    path('logout', AuthLogoutView.as_view(), name='logout'),
] 
