FROM        ubuntu:14.04.1
MAINTAINER  cooniur
# ---------------- #
#   Installation   #
# ---------------- #

# Install all prerequisites
RUN     apt-get -y install software-properties-common \
        && add-apt-repository -y ppa:chris-lea/node.js \
        && apt-get -y update \
        && apt-get -y install python-django-tagging python-simplejson python-memcache python-ldap python-cairo python-pysqlite2 python-support \
            python-pip gunicorn supervisor nginx-light nodejs git wget curl openjdk-7-jre build-essential python-dev \
        && apt-get autoclean \
        && apt-get clean \
        && apt-get autoremove

RUN     pip install Twisted==11.1.0 \
        && pip install Django==1.5

# Install Elasticsearch
RUN     cd ~ && wget --quiet https://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-1.5.0.deb \
        && dpkg -i elasticsearch-1.5.0.deb \
        && rm elasticsearch-1.5.0.deb

# Checkout the stable branches of Graphite, Carbon and Whisper and install from there
# Install StatsD
RUN     mkdir -p /src \
        && git clone https://github.com/graphite-project/whisper.git /src/whisper \
        && cd /src/whisper \
        && git checkout 0.9.x \
        && python setup.py install \
        && git clone https://github.com/graphite-project/carbon.git /src/carbon \
        && cd /src/carbon \
        && git checkout 0.9.x \
        && python setup.py install \
        && git clone https://github.com/graphite-project/graphite-web.git /src/graphite-web \
        && cd /src/graphite-web \
        && git checkout 0.9.x \
        && python setup.py install \
        && git clone https://github.com/etsy/statsd.git /src/statsd \
        && cd /src/statsd \
        && git checkout v0.7.2 \
        && mkdir /src/grafana \
        && wget http://grafanarel.s3.amazonaws.com/grafana-1.9.1.tar.gz -O /src/grafana.tar.gz \
        && tar -xzf /src/grafana.tar.gz -C /src/grafana --strip-components=1 \
        && rm /src/grafana.tar.gz

# ----------------- #
#   Configuration   #
# ----------------- #

# Configure Elasticsearch
ADD     ./elasticsearch/run /usr/local/bin/run_elasticsearch
RUN     chown -R root:root /var/lib/elasticsearch \
        && mkdir -p /tmp/elasticsearch \
        && chown root:root /tmp/elasticsearch

# Confiure StatsD
ADD     ./statsd/config.js /src/statsd/config.js

# Configure Whisper, Carbon and Graphite-Web
ADD     ./graphite/initial_data.json /opt/graphite/webapp/graphite/initial_data.json
ADD     ./graphite/local_settings.py /opt/graphite/webapp/graphite/local_settings.py
ADD     ./graphite/carbon.conf /opt/graphite/conf/carbon.conf
ADD     ./graphite/storage-schemas.conf /opt/graphite/conf/storage-schemas.conf
ADD     ./graphite/storage-aggregation.conf /opt/graphite/conf/storage-aggregation.conf

RUN     mkdir -p /opt/graphite/storage/whisper \
        && touch /opt/graphite/storage/graphite.db /opt/graphite/storage/index \
        && chown -R root:root /opt/graphite/storage \
        && chmod 0775 /opt/graphite/storage /opt/graphite/storage/whisper \
        && chmod 0664 /opt/graphite/storage/graphite.db \
        && python /opt/graphite/webapp/graphite/manage.py syncdb --noinput

# Configure Grafana
ADD     ./grafana/config.js /src/grafana/config.js

# Add the default dashboards
ADD     ./grafana/dashboards/* /src/dashboards/

# Configure nginx and supervisord
ADD     ./nginx/nginx.conf /etc/nginx/nginx.conf
ADD     ./supervisord/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
ADD     ./supervisord/supervisord-start.sh /usr/bin/supervisord-start.sh

# ---------------- #
#   Expose Ports   #
# ---------------- #

# Grafana: 80
# StatsD UDP port: 8125
# StatsD Management port: 8126
EXPOSE  80
EXPOSE  8125/udp
EXPOSE  8126

# Elasticsearch data storage path: /var/lib/elasticsearch
# Graphite data storage path: /opt/graphite/storage/whipsper
# Graphite log path: /opt/graphite/storage/log
# Graphite conf path: /opt/graphite/conf
# Supervisor log path: /var/log/supervisor
VOLUME  ["/var/lib/elasticsearch", "/opt/graphite/storage/whisper", "/opt/graphite/storage/log", "/opt/graphite/conf", "/var/log/supervisor"]

# -------- #
#   Run!   #
# -------- #

CMD     ["/bin/sh", "/usr/bin/supervisord-start.sh"]
