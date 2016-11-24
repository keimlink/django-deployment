include:
  - virtualenv

user-bashrc:
  file.blockreplace:
    - name: {{ pillar['project']['home'] }}/.bashrc
    - marker_start: "# START managed configuration -DO-NOT-EDIT-"
    - marker_end: "# END managed configuration"
    - content: |
        export LC_ALL=en_US.UTF-8
        export LANG=en_US.UTF-8
        export LANGUAGE=en_US.UTF-8
        source {{ pillar['project']['home'] }}/{{ pillar['project']['venv'] }}/bin/activate
    - template: jinja
    - append_if_not_found: True
    - require:
      - sls: virtualenv
