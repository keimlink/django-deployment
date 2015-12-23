include:
  - deps
  - pip

virtualenv:
  pip.installed:
    - require:
      - sls: pip

venv:
  virtualenv.managed:
    - name: {{ pillar['project']['home'] }}/{{ pillar['project']['venv'] }}
    - use_wheel: True
    - user: {{ pillar['project']['user'] }}
    - requirements: salt://virtualenv/requirements.txt
    - require:
      - sls: deps
      - pip: virtualenv
