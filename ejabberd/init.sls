{% from "ejabberd/map.jinja" import ejabberd with context %}
ejabberd_package:
  pkg.installed:
    - pkgs:
      - {{ ejabberd.package | json }}
    - watch_in:
      - service: ejabberd_service

{% if ejabberd.get('extra_packages') %}
  pkg.installed:
    - pkgs: {{ ejabberd.extra_packages | json }}
{% endif %}

{{ ejabberd.config.base }}/{{ ejabberd.config.filename }}:
  file.managed:
    - template: jinja
    - source: salt://ejabberd/files/ejabberd.yml
    - backup: minion
    - watch_in:
      - service: ejabberd_service
    - require:
      - pkg: ejabberd_package

ejabberd_service:
  service.running:
    - name: ejabberd
    - watch:
      - file: {{ ejabberd.config.base }}/{{ ejabberd.config.filename }}
      - pkg: ejabberd_packages
    - require:
      - pkg: ejabberd_packages
{% if ejabberd.get('service_persistent', True) %}
    - enable: True
{% endif %}
{% if 'enable_service_control' in ejabberd and ejabberd.enable_service_control == false %}
    # never run this state
    - onlyif:
      - /bin/false
{% endif %}
