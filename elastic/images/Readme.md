### Commands to download the images

## Export tar images

```bash
podman pull docker.elastic.co/elasticsearch/elasticsearch:9.0.3
podman save -o elasticsearch.tar docker.elastic.co/elasticsearch/elasticsearch:9.0.3
podman load -i elastic/images/elasticsearch.tar

podman pull docker.elastic.co/kibana/kibana:9.0.3
podman save docker.elastic.co/kibana/kibana:9.0.3 -o kibana.tar
podman load -i elastic/images/kibana.tar

podman pull docker.elastic.co/eck/eck-operator:3.0.0
podman save docker.elastic.co/eck/eck-operator:3.0.0 -o eck-operator.tar
podman load -i elastic/images/eck-operator.tar
```