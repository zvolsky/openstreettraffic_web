from django.contrib import admin

from .models import Carrier, Website


admin.site.register(Carrier)   # , CarrierAdmin
admin.site.register(Website)
