# Default Volumes

## Default configurations

###Graphite default configuration

	opt/graphite/conf

###Graphite default storage

	opt/graphite/storage

###Elasticsearch default data path

	var/lib/elasticsearch

## Usage

	~$ cd default-volumes
	~$ sudo docker run -d \
		--name graphite \
		-p 80:80 -p 8125:8125/udp -p 8126:8126 \
		-v $PWD/opt/graphite/storage:/opt/graphite/storage \
		-v $PWD/opt/graphite/conf:/opt/graphite/conf \
		-v $PWD/var/lib/elasticsearch:/var/lib/elasticsearch \
		cooniur/grafana_graphite
