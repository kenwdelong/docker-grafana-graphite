StatsD + Graphite + Grafana
---------------------------

This image contains a sensible default configuration of StatsD, Graphite and Grafana. There are two ways
for using this image:


### Using the Docker Index ###

This image is based on [Kamon's repository on the Docker Index](https://index.docker.io/u/kamon/) and published under [Ken DeLong's repository]
(https://index.docker.io/u/kenwdelong/). All you need as a prerequisite is having Docker installed on your machine. 
The container exposes the following ports:

- `80`: the Grafana web interface.
- `8125`: the StatsD port.
- `8126`: the StatsD administrative port.

To start a container with this image you just need to run the following command:

```bash
docker run -d -p 80:80 -p 8125:8125/udp -p 8126:8126 --name grafana kenwdelong/grafana_graphite:latest
```

If you already have services running on your host that are using any of these ports, you may wish to map the container
ports to whatever you want by changing left side number in the `-p` parameters. Find more details about mapping ports
in the [Docker documentation](http://docs.docker.io/use/port_redirection/#port-redirection).

#### External Volumes ####
External volumes can be used to customize graphite configuration and store data out of the container.

- Graphite configuration: `/opt/graphite/conf`
- Graphite data: `/opt/graphite/storage/whisper`
- Supervisord log: `/var/log/supervisor`

### Building the image yourself ###

The Dockerfile and supporting configuration files are available in our [Github repository](https://github.com/kenwdelong/docker-grafana-graphite).
This comes specially handy if you want to change any of the StatsD, Graphite or Grafana settings, or simply if you want
to know how the image was built.


### Using the Dashboard ###

Once your container is running all you need to do is:
- open your browser pointing to the host/port you just published
- login with the default username (admin) and password (admin)
- configure a new datasource to point at the Graphite metric data (URL - http://localhost:8000) and replace the default Grafana test datasource for your graphs
- open your browser pointing to the host/port you just published and play with the dashboard at your wish...

We hope that you have a lot of fun with this image and that it serves it's
purpose of making your life easier. This should give you an idea of how the dashboard looks like when receiving data
from one of our toy applications:

![Kamon Dashboard](http://kamon.io/assets/img/kamon-statsd-grafana.png)
