pokud problémy s default browserem (objevuje se ff místo chrome):
  leafpad ~/.config/mimeapps.list
    chromium, firefox-esr -> google-chrome

leafpad ~/.bash_profile, nebo (pokud je .bash_profile prázdný) leafpad ~/.profile
  přidat: export DJANGO_READ_DOT_ENV_FILE=True
  kontrola: echo $DJANGO_READ_DOT_ENV_FILE    # True

# instalace postgres a uživatel podle linux uživatele
su
apt install postgresql-11 pgadmin3  # příp. pgadmin4
# geodjango - postgis: https://docs.djangoproject.com/en/dev/ref/contrib/gis/install/postgis/
apt install postgis postgresql-server-dev-11
pg_lsclusters

leafpad /etc/postgresql/11/main/pg_hba.conf, local/all/postgres=md5, local/all/all=peer
su - postgres   # předem: su
psql         ## 5432, default, nebo -U postgres -p 5432
\password    ## heslo U=postgres např. pro pgadmin  ## Fractal, postgres nove
create role <debian_user> login createdb;     ## možná už tuto roli mám
  ## ...password '<db_password>' - ale při peer autentikaci na hesle nezáleží, toto můžu vynechat
\q
exit  # -> <debian_user>
přihlásit se lze: ~$: psql -p <pg_port> -d <nějaká_db>     ## -d postgres
\password                    ##  - ale při peer autentikaci na hesle nezáleží, toto můžu vynechat
# doporučuje se v dokumentaci djanga pro rychlejší přístup k datům
ALTER ROLE mirek SET client_encoding TO 'utf8';
ALTER ROLE mirek SET default_transaction_isolation TO 'read committed';
ALTER ROLE mirek SET timezone TO 'UTC';

pgadmin: Přidat server, localhost-11, p=5432, U=postgres, pwd=..

nový projekt na github, Affero, readme, bez .gitignore
git clone git@github.com:zvolsky/openstreettraffic_web.git
přejmenovat na openstreettraffic_web1

python3 -m venv ve_openstreettraffic/
. ve_openstreettraffic/bin/activate
pip install --upgrade pip setuptools wheel

pip install cookiecutter
cookiecutter https://github.com/pydanny/cookiecutter-django
  # předpokládám, že většinu lze přegenerovat později a převzít adresáře aplikací
                                            # se stejným zadáním generuje jen různá secret key
  re-download: yes
  openstreettraffic_web                     # vyskytuje se v popisných textech (<title>,..), komentářích a dokumentaci
  openstreettraffic_web                     # slug: jméno pro vytvořené adresáře a databázi
  open source data about public transport   # v readme a dokumentaci
  Mirek Zvolský                             # ADMINS, contributors, licence, dokumentace
  zitranavylet.cz                           # ALLOWED_HOSTS, DEAFULT_FROM_EMAIL, také v contrib/sites/migrations
  zvolsky@seznam.cz                         # ADMINS
  0.1.0                                     # <project>/__init__.py
  1  # MIT                                  # LICENSE, README.rst
  Europe/Prague                             # jen base.py: TIME_ZONE
  n  # windows: provoz v prostředí MS Windows   # ovlivňuje jen connectstring do postgres databáze (DATABASES)
  y  # pycharm: přednastavení pro pycharm   # .gitignore ; navíc vytvoří adresáře: .idea/, docs/pycharm/
  n  # docker: kontejnerová instalace (y?)  # .gitignore, DATABASES connectstring, INTERNAL_IPS, verze/volání psycopg2,
                                            # chybí utility/ soubory install... a requirements...
                                            # navíc: compose/, .envs/, .dockerignore, local|production.yml, merge_production_dotenvs_in_dotenv.py
  1  # postgresql verze, default nebo aktuální (1 = 10.5)  # locate bin/postgres ; /usr/lib/postgresql/11/bin/postgres -V     # asi neovlivňuje vůbec nic (na linuxu)
  2  # gulp: y                              # templates/base.html: .min.css místo .css , liší se pytest.ini
                                            # navíc: gulpfile.js, package.json
       # nepodporuje docker a gulp současně, gulp konfigurace se případně musí do docker-compose zadat ručně
  n  # bootstrap compilation                # y: chybí <link> na bootstrap templates/base.html, místo něj @import bootstrapu ve static/sass/project.scss, text navíc v README.rst
  y  # compressor: django komprimace statických souborů    # y: https://django-compressor.readthedocs.io/en/latest/ , konfigurace + ..compress.. v templatách
  n  # celery: náročnější úlohy běžící mimo režim request/response
                                            # y: INSTALLED_APPS a další settings, README.rst, .gitignore, .pylintrc
                                            # navíc: <project>/taskapp/
  y  # mailhog: emulace mailů na vývojovém stroji
                                            # y: README.rst, .gitignore
       # změní default EMAIL_BACKEND na django.core.mail.backends.smtp.EmailBackend místo .console.EmailBackend, vyžaduje instalovat mailhog na port 8025
                                            # ALE: v diff to vidím jen --, nikoli ++ (?); popis spuštění viz README.rst
  y  # sentry: reportování chyb             # y: raven v INSTALLED_APPS a MIDDLEWARE + další nastavení ; volání Sentry() v config/wsgi.py ; README.rst
  y  # whitenoise: nezávislé poskytování static souborů
                                            # y: přidaný MIDDLEWARE ; nastavení: STATICFILE_STORAGE (a náhrada STATIC_URL), změna DEFAULT_FILE_STORAGE, MEDIA_URL
					    # WARNING: y|n vždy míří na AWS/S3
  n  # heroku: instalace na heroku (n: při instalaci na vlastní infrastrukturu)
                                            # y: .gitignore, README.rst ; navíc: .envs/, Procfile, runtime.txt, requirements.txt, merge_production_dotenvs_in_dotenv.py
  y  # travis ci: continuous integration    # y: jen přidá .travis.yml
  y  # keep_local_envs_in_vcs               # y=default, ale zdá se, že nemá vůbec vliv
  n  # debug                                # n=default, ale zdá se, že nemá vůbec vliv

 smazat: LICENSE
 opravit v README.rst: license MIT -> Affero
 přesunout vše včetně hidden do openstreettraffic_web1/
 přejmenovat openstreettraffic_web1/ openstreettraffic_web/

do requirements/base.txt dopsat:
  django-smoke-tests==1.0.1
  django-countries==
  pyuca==
pip install -r requirements/local.txt

cd openstreettraffic_web/
git add .
git commit -m "initial"
git push

config/settings/base.py  # zkontrolujeme:
DATABASES = {'default': env.db('DATABASE_URL')}                             # zkontrolujeme (default=.. - lze ponechat)
DATABASES['default']['ENGINE'] = 'django.contrib.gis.db.backends.postgis'   # přidáme

leafpad .env   # vytvořím nový soubor
  DATABASE_URL=postgres:///postgres
  # CELERY_BROKER_URL=amqp://  # optional: amqp://guest:guest@localhost:5672//

./manage.py dbshell             # viz .env výše, jinak: ConnectionDoesNotExist nebo database "xxxx" does not exist
  v nouzi: psql -d postgres
select current_user;            # mirek
select current_database();      # postgres
create database openstreettraffic;
exit;

leafpad .env   # upravíme: DATABASE_URL=postgres:///openstreettraffic
  # viz: https://www.peterbe.com/plog/connecting-with-psycopg2-without-a-username-and-password
  # pokud jinak: postgres://<user>:<db_password>@127.0.0.1:5432/openstreettraffic", spec.znaky v hesle vyžadují %HH encoding
# kontrola:
./manage.py dbshell
select current_database();      # openstreettraffic

# pozn.: vytvořit databázi lze i jakkoli jinak, např. pod uživatelem postgres:
  su - postgres   # předem: su
  createdb -p <pg_port> openstreetways   # <db_name> == openstreetways
  psql: GRANT ALL PRIVILEGES ON DATABASE openstreetways TO mirek;
  nebo: createdb -U postgres -O owner  ...apod.

su - postgres   # předem: su
psql openstreettraffic
CREATE EXTENSION postgis;
CREATE EXTENSION unaccent;   # .objects.filter(name__unaccent="México") nebo ...(name__unaccent__startswith="Jerem")
  pozn.: lze také udělat podle stackoverflow.com/questions/31382675/how-can-i-activate-the-unaccent-extension-on-an-already-existing-model

./manage.py migrate            ## ověřím v pgadmin, že vznikly tabulky
./manage.py createsuperuser
  <debian_user>
  <debian_user_mail>
  <dj_password>                ## keepassx: Network, django openstreetways superuser local
  <dj_password>

  # zde je problém při docker: gaierror at accounts/login [Errno -2] Name or service not known ; možná vyžaduje kontejner mailhog?
zjednodušeně lze leafpad config/settings/local.py: EMAIL_BACKEND = env('DJANGO_EMAIL_BACKEND', default='django.core.mail.backends.console.EmailBackend')
lépe instalovat mailhog a: code config/settings/base.py: EMAIL_BACKEND = env('DJANGO_EMAIL_BACKEND', default='django.core.mail.backends.smtp.EmailBackend')
# lokální odchytávání mailů (podle: http://cookiecutter-django.readthedocs.io/en/latest/deveoping-locally.html)
# z https://github.com/mailhog/MailHog/releases stáhnout
#  MailHog_linux_amd64 do (git) rootu openstreettraffic_web/, přejmenovat na: mailhog
chmod +x mailhog
./mailhog  # nyní jsou přijaté maily na localhost:8025

# při předchozích nastaveních mailu odzkoušet
./manage.py runserver
localhost:8000/admin   # zkusit se přihlásit
  POZOR: ConnectionRefusedError při SignIn/SignUp znamená nespuštěný mailhog
localhost:8000  # zobrazí se pydanny/cookiecutter prostředí
  SignIn        # vygeneruje se confirm email pro potvrzení email adresy uživatele
# udělal jsem si ještě uživatele myum / myum@seznam.cz s heslem keepassx: Network, django openstreetways superuser local

coverage run -m pytest
coverage html
xdg-open htmlcov/index.html

sudo npm install -g npm
npm install
npm audit fix   # ale stejně neopravilo vulnerabilities
npm audit fix --force  # opraví se, ale ... včetně "breaking changes"
  ale pokud nyní neprojde v "npm run dev" gulp, musím jít zpět: npm install --save-dev gulp@3.9.1

instalovat do Chrome LiveReload  # podle doporučení: https://cookiecutter-django.readthedocs.io/en/latest/live-reloading-and-sass-compilation.html
přejmenovat static/sass/*.scss soubory na *.sass a změnit v nich syntaxi na sass
v gulpfile.js všechny výskyty "scss" změnit na "sass"
spustit: "npm run dev" a zkontrolovat, že se správně aktualizují soubory v static/css/

github.com/mailhog/MailHog/, download latest release, MailHog_linux_amd64 - přímo do django rootu
přejmenovat na: MailHog
chmod +x MailHog
./MailHog  # startuje SMTP na :1025 a HTTP na :8025

./manage.py startapp openstreettraffic
přidat do config/settings/base.py, LOCAL_APPS
models.py + migrate
admin.py