from django.conf.global_settings import LANGUAGES
from django.contrib.gis.db import models
from django.utils.translation import gettext_lazy as _

from django_countries.fields import CountryField


'''
class UncertainDateField(models.CharField):
    def __init__(self):
        self.max_length = 8


class City(models.Model):
    name = models.CharField(max_length=120)
    country = CountryField()
    location = models.PointField()
    population = models.IntegerField()
'''

# carrier, as known to public
class Carrier(models.Model):
    abbreviation = models.CharField(max_length=8)
    name = models.CharField(max_length=100)      # most often used name
    residency = CountryField(blank=True, null=True)

    class Meta:
        verbose_name = _('carrier')
        verbose_name_plural = _('carriers')

    def __str__(self):
        return self.name


# organisation, as registered at the country institutions
#class Organisation(models.Model):


# website with content about public transportation
class Website(models.Model):
    url = models.URLField(_("URL (web address)"), max_length=128, db_index=True, unique=True)
    eshop = models.BooleanField(_("e-shop for tickets"), default=False)
    #organisation = models.ForeignKey(Organisation, _("organisation"), on_delete=models.SETNULL, blank=True, null=True)
    carrier = models.ForeignKey(Carrier, on_delete=models.SET_NULL, blank=True, null=True)
    language = models.CharField(_("main language"), max_length=7, choices=LANGUAGES)

    class Meta:
        verbose_name = _('web resource')
        verbose_name_plural = _('web resources')

    def __str__(self):
        return self.url


'''
# website with content about public transportation
class WebArticle(models.Model):
    website = models.ForeignKey(Website, _("organisation"), on_delete=models.SETNULL, blank=True, null=True)
'''
