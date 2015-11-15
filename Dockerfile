FROM        ubuntu:14.04
MAINTAINER  kenwdelong
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
        && pip install Django==1.5 \
        && pip install pytz
        
RUN     npm install ini chokidar        

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
        && mkdir /opt/grafana \
        && wget https://grafanarel.s3.amazonaws.com/builds/grafana-2.1.3.linux-x64.tar.gz -O /src/grafana.tar.gz \
        && tar -xzf /src/grafana.tar.gz -C /opt/grafana --strip-components=1 \
        && rm /src/grafana.tar.gz

# ----------------- #
#   Configuration   #
# ----------------- #

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
        && cd /opt/graphite/webapp/graphite \
        && python manage.py syncdb --noinput

# Configure Grafana
ADD     ./grafana/custom.ini /opt/grafana/conf/custom.ini

# Add the default dashboards
RUN     mkdir /src/dashboards \
        && mkdir /src/dashboard-loader
ADD     ./grafana/dashboards/* /src/dashboards/
ADD     ./grafana/dashboard-loader/dashboard-loader.js /src/dashboard-loader/

# Configure nginx and supervisord
ADD     ./nginx/nginx.conf /etc/nginx/nginx.conf
ADD     ./supervisord/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

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
# VOLUME  ["/var/lib/elasticsearch", "/opt/graphite/storage/whisper", "/opt/graphite/storage/log", "/opt/graphite/conf", "/var/log/supervisor"]

# -------- #
#   Run!   #
# -------- #

CMD     ["/usr/bin/supervisord"]
