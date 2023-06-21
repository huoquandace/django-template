from django.urls import path 
from .views import * 
 
urlpatterns = [ 
    path('', AuthIndexView.as_view()),
    path('login', AuthLoginView.as_view()),
] 
