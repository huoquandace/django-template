from django.urls import path 
from .views import * 


app_name = 'authentication'

urlpatterns = [ 
    path('', AuthIndexView.as_view(), name='index'),
    path('login/', AuthLoginView.as_view(), name='login'),
    path('logout/', AuthLogoutView.as_view(), name='logout'),
    path('password_change/', AuthPasswordChangeView.as_view(), name='password_change'),
    path('password_change/done/', AuthPasswordChangeDoneView.as_view(), name='password_change_done'),
    path('password_reset/', AuthPasswordResetView.as_view(), name='password_reset'),
    path('password_reset/done/', AuthPasswordResetDoneView.as_view(), name='password_reset_done'),
    path('reset/<uidb64>/<token>/', AuthPasswordResetConfirmView.as_view(), name='password_reset_confirm'),
    path('reset/done/', AuthPasswordResetCompleteView.as_view(), name='password_reset_complete'),
    path('register/', AuthRegisterView.as_view(), name='register'),
    path('register/done/', AuthRegisterDoneView.as_view(), name='register_done'),
    path('profile/', AuthProfileView.as_view(), name='profile'),
] 
