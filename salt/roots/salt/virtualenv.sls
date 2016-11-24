include:
  - deps
  - python3

venv:
  cmd.run:
    - name: python3 -m venv {{ pillar['project']['home'] }}/{{ pillar['project']['venv'] }}
    - runas: {{ pillar['project']['user'] }}
    - unless: ls {{ pillar['project']['home'] }}/{{ pillar['project']['venv'] }}
    - makedirs: True
    - require:
      - sls: python3

install-requirements:
  cmd.run:
    - name: {{ pillar['project']['home'] }}/{{ pillar['project']['venv'] }}/bin/python -m pip install --upgrade psycopg2 python-memcached
    - require:
      - sls: deps
