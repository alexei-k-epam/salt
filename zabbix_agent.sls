{% if salt['grains.get']('os') == "CentOS" -%}

Install Zabbix 3 repo:
   cmd.run:
    - name: rpm -i http://repo.zabbix.com/zabbix/3.0/rhel/6/x86_64/zabbix-release-3.0-1.el6.noarch.rpm

Install zabbix_agent:
  pkg.installed:
    - name: zabbix-agent

Install zabbix_proxy:
  pkg.installed:
    - name: zabbix-proxy-sqlite3

/etc/zabbix/zabbix_proxy.conf:
  file.managed:
    - source: salt://templates/zabbix_proxy.conf.jinja
    - template: jinja
    - user: root
    - group: root
    - mode: 644
    - require:
      - pkg: Install zabbix_proxy

/etc/zabbix/zabbix_agent.conf:
  file.managed:
    - source: salt://templates/zabbix_agent.conf.jinja
    - template: jinja
    - user: root
    - group: root
    - mode: 644
    - require:
      - pkg: Install zabbix_agent

zabbix-proxy:
  service.running:
    - reload: False
    - enable: True


zabbix-agent:
  service.running:
    - reload: False
    - enable: True
    - require:
      - iptables: Ipables 10050
    - watch:
      - iptables: Ipables 10050

Ipables 10050:
  iptables.insert:
    - table: filter
    - chain: INPUT
    - jump: ACCEPT
    - match: state
    - connstate: NEW
    - dport: 10050
    - proto: tcp
    - save: True
    - position: 1

{% endif -%}
