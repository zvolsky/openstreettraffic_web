nový projekt na github, Affero, readme, bez .gitignore
git clone git@github.com:zvolsky/openstreettraffic_web.git
přejmenovat na openstreettraffic_web1

python3 -m venv ve_openstreettraffic/
. ve_openstreettraffic/bin/activate
pip install --upgrade pip setuptools wheel

pip install cookiecutter
cookiecutter https://github.com/pydanny/cookiecutter-django
  # předpokládám, že většinu lze přegenerovat později a převzít adresáře aplikací
  re-download: yes
  project: openstreettraffic_web
  slug: openstreettraffic_web
  description: open data about public transport
  autor: Mirek Zvolský
  domain: zitranavylet.cz
  email: zvolsky@seznam.cz
  version: 0.1.0
  license: 1-MIT
  timezone: Europe/Prague
  windows: n
  pycharm: y
  docker: n
  postgres: 1-10.5
  js_task_runner: 2-gulp
  custom_bootstrap: n
  django-compressor: y
  celery: n
  mailhog: y
  sentry: y
  whitenoice: y
  heroku: n
  travisci: n
  envs_in_vcs: y
  debug: n
 smazat: LICENSE
 opravit v README.rst: license MIT -> Affero
 přesunout vše včetně hidden do openstreettraffic_web1/
 přejmenovat openstreettraffic_web1/ openstreettraffic_web/

cd openstreettraffic_web/
git add .
git commit -m "initial"
git push

pip install -r requirements/local.txt

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
přejmenovat na MailHog
chmod +x MailHog
./MailHog  # startuje SMTP na :1025 a HTTP na :8025
