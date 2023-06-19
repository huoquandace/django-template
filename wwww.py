from django.db import models
from django.contrib import auth
from django.utils import timezone
from django.utils.translation import gettext_lazy as _


class User(auth.models.AbstractBaseUser, auth.models.PermissionsMixin):
    username = models.CharField(max_length=100, unique=True)
    first_name = models.CharField(max_length=100, blank=True)
    last_name = models.CharField(max_length=100, blank=True)
    email = models.EmailField(blank=True)
    is_staff = models.BooleanField(default=False,)
    is_active = models.BooleanField(default=True)
    date_joined = models.DateTimeField(default=timezone.now)

    objects = auth.models.UserManager()

    EMAIL_FIELD = 'email'
    USERNAME_FIELD = 'username'
    # REQUIRED_FIELDS = ['email']

    def __str__(self): return self.username


class Profile(models.Model):

    class Gender(models.TextChoices):
        MALE = 'Male', _('Male')
        FEMALE = 'Female', _('Female')
        UNKNOWN = 'Unknown', _('Unknown')

    user = models.OneToOneField(User, on_delete=models.CASCADE)
    gender = models.CharField(max_length=100, blank=True, choices=Gender.choices)
    phone = models.CharField(max_length=100, blank=True, null=True)
    age = models.IntegerField(blank=True, null=True)
    address = models.TextField(blank=True, null=True)
    birthday = models.DateField(max_length=10, blank=True, null=True)
    avatar = models.ImageField(default='images/avatar_default_male.jpg', upload_to='images')

    def __str__(self): return f"Profile of {self.user.username}"

    def save(self, *args, **kwargs):
        if self.gender == 'Female': self.avatar = 'images/avatar_default_female.jpg'
        return super().save(*args, **kwargs)
    
def create_user_profile(sender, instance, created, **kwargs):
	if created: Profile.objects.create(user=instance)

def save_user_profile(sender, instance, **kwargs):
	instance.profile.save()

models.signals.post_save.connect(create_user_profile, sender=User)
models.signals.post_save.connect(save_user_profile, sender=User)