apache2:
  pkg:
    - installed
  service.running:
    - enable: True
    - watch:
      - file: /etc/apache2/sites-available/django.conf

libapache2-mod-wsgi:
  pkg.installed:
    - require:
      - pkg: apache2

/etc/apache2/sites-available/django.conf:
  file.managed:
    - user: root
    - group: root
    - mode: 644
    - source: salt://apache/django.conf
    - template: jinja
    - require:
      - pkg: apache2

/etc/apache2/sites-enabled/000-default.conf:
  file.symlink:
    - user: root
    - group: root
    - mode: 644
    - target: /etc/apache2/sites-available/django.conf
    - force: True
    - require:
      - pkg: apache2
