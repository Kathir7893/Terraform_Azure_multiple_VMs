#!/bin/bash
# This script installs Elasticsearcbh with docker & checks the health using curl

#sudo apt install docker.io
sudo docker pull docker.elastic.co/elasticsearch/elasticsearch:7.9.0
sudo docker run -d -p 9200:9200 -p 9300:9300 -e "discovery.type=single-node" docker.elastic.co/elasticsearch/elasticsearch:7.9.0

sleep 30
curl -X GET "localhost:9200/_cat/nodes?v&pretty"
curl -X GET "localhost:9200/_cluster/health"

