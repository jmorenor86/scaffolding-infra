#!/bin/bash

JSON_FILE="vars/configuration.json"
YAML_FILE_OCP="vars/vars-ocp.yml"
YAML_FILE_ES="vars/vars-es.yml"
echo "Replace configuration values..."

es_namespace=$(jq -r '.es.es_namespace' "$JSON_FILE")
es_storageclass=$(jq -r '.es.es_storageclass' "$JSON_FILE")
es_storage=$(jq -r '.es.es_storage' "$JSON_FILE")
es_cluster=$(jq -r '.es.es_cluster' "$JSON_FILE")
es_version=$(jq -r '.es.es_version' "$JSON_FILE")
es_nodes=$(jq -r '.es.es_nodes' "$JSON_FILE")
es_container_name=$(jq -r '.es.es_container_name' "$JSON_FILE")
es_container_request_memory=$(jq -r '.es.es_container_request_memory' "$JSON_FILE")
es_container_request_cpu=$(jq -r '.es.es_container_request_cpu' "$JSON_FILE")
es_container_limit_memory=$(jq -r '.es.es_container_limit_memory' "$JSON_FILE")
es_container_limit_cpu=$(jq -r '.es.es_container_limit_cpu' "$JSON_FILE")

ocp_version=$(jq -r '.ocp.version' "$JSON_FILE")
ocp_host=$(jq -r '.ocp.host' "$JSON_FILE")
ocp_user=$(jq -r '.ocp.username' "$JSON_FILE")
ocp_password=$(jq -r '.ocp.password' "$JSON_FILE")


sed -i "s|^es_namespace:.*|es_namespace: $es_namespace|" "$YAML_FILE_ES"
sed -i "s|^es_storageclass:.*|es_storageclass: $es_storageclass|" "$YAML_FILE_ES"
sed -i "s|^es_storage:.*|es_storage: $es_storage|" "$YAML_FILE_ES"
sed -i "s|^es_cluster:.*|es_cluster: $es_cluster|" "$YAML_FILE_ES"
sed -i "s|^es_version:.*|es_version: $es_version|" "$YAML_FILE_ES"
sed -i "s|^es_nodes:.*|es_nodes: $es_nodes|" "$YAML_FILE_ES"
sed -i "s|^es_container_name:.*|es_container_name: $es_container_name|" "$YAML_FILE_ES"
sed -i "s|^es_container_request_memory:.*|es_container_request_memory: $es_container_request_memory|" "$YAML_FILE_ES"
sed -i "s|^es_container_request_cpu:.*|es_container_request_cpu: $es_container_request_cpu|" "$YAML_FILE_ES"
sed -i "s|^es_container_limit_memory:.*|es_container_limit_memory: $es_container_limit_memory|" "$YAML_FILE_ES"
sed -i "s|^es_container_limit_cpu:.*|es_container_limit_cpu: $es_container_limit_cpu|" "$YAML_FILE_ES"


sed -i "s|^ocp_version:.*|ocp_version: $ocp_version|" "$YAML_FILE_OCP"
sed -i "s|^ocp_host:.*|ocp_host: $ocp_host|" "$YAML_FILE_OCP"
sed -i "s|^ocp_user:.*|ocp_user: $ocp_user|" "$YAML_FILE_OCP"
sed -i "s|^ocp_password:.*|ocp_password: $ocp_password|" "$YAML_FILE_OCP"

echo "Replace values successfull."

echo "Install oc cli command"
PLAYBOOK_INSTALL="install-cli.yml"
ansible-playbook  "$PLAYBOOK_INSTALL"
echo "Installed oc cli command successfully"

echo "Install Watson discovery on OPC"
PLAYBOOK_INSTALL_ES="on-ocp.yml"
ansible-playbook  "$PLAYBOOK_INSTALL_ES"
echo "Installed oc cli command successfully"