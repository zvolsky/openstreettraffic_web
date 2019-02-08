import os
import socket


import geoip2.database
import requests


# from django.shortcuts import render

from django.conf import settings
#from django.http import HttpResponse
from django.shortcuts import render
from django.templatetags.static import static
from django.utils.safestring import mark_safe


IPIFY = 'https://api.ipify.org'
GEOROOT = (settings.STATIC_ROOT, 'my_ip/geoip')
GEODAT = os.path.join(*GEOROOT + ('GeoLite2-City/GeoLite2-City.mmdb',))
#ASNDAT = os.path.join(*GEOROOT + ('GeoLite2-ASN/GeoLite2-ASN.mmdb',))
    # geolite2 free downloadable databases
    # https://dev.maxmind.com/geoip/geoip2/geolite2/
    # updated on the first Tuesday of each month
GEOREADER = geoip2.database.Reader(GEODAT)
#ASNREADER = geoip2.database.Reader(ASNDAT)
MAPS = 'https://mapy.cz?x={long}&y={lat}&z=11'


def _geo_location(ip):
    try:
        geo = GEOREADER.city(ip)
        country = geo.country.name
        city = geo.city.name
    except geoip2.errors.AddressNotFoundError:
        geo = country = city = ''
    #try:
    #    asn = ASNREADER.asn(ip)
    #    org = asn.autonomous_system_organization
    #except geoip2.errors.AddressNotFoundError:
    #    org = ''
    place = ' '.join(filter(None, (country, city)))  # , org)))
    if geo and geo.location:
        mapurl = MAPS.format(lat=geo.location.latitude, long=geo.location.longitude)
        return mark_safe('<a href="{mapurl}">{place}</a>'.format(mapurl=mapurl, place=place))
    else:
        return place


def _get_client_ip(request):
    x_forwarded_for = request.META.get('HTTP_X_FORWARDED_FOR')
    if x_forwarded_for:
        ip = x_forwarded_for.split(',')[0]
    else:
        ip = request.META.get('REMOTE_ADDR')
    return ip


def index(request):
    '''
    # howto: temporary shut down the internet connection
    su
    route
    ifconfig
    ifconfig enp0s31f6 down
    ifconfig enp0s31f6 up
    '''

    ctx = {}

    ctx['rip'] = rip = _get_client_ip(request)

    try:
        ctx['pip'] = pip = requests.get(IPIFY).text
    except requests.ConnectionError:
        ctx['pip'] = pip = None

    ctx['rgeo'] = _geo_location(rip)
    ctx['pgeo'] = _geo_location(pip)

    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    try:
        s.connect(("8.8.8.8", 80))
        ctx['lip'] = s.getsockname()[0]
    except OSError:
        ctx['lip'] = None
    s.close()

    return render(request, 'my_ip/index.html', ctx)
    '''
    return HttpResponse("Request IP: {rip} {rgeo}<br>"
                        "Public IP: {pip} {pgeo}<br>"
                        "Local IP: {lip}".format(rip=rip, rgeo=rgeo, pip=pip, pgeo=pgeo, lip=lip) +
                        '<br><br><i>This product includes GeoLite2 data created by MaxMind, '
                        'available from <a href="https://www.maxmind.com">www.maxmind.com</a></i>')
    '''
