#!/bin/bash

export OCP_HOST="CHANGE_ME"
export OCP_USER="CHANGE_ME"
export OCP_PASSWORD="CHANGE_ME"
export ES_NAMESPACE="elastic"
export STORAGECLASS="ocs-storagecluster-ceph-rbd"
export ES_CLUSTER="wxd"
export ES_STORAGE="50Gi"
export ES_VERSION="8.11.1"
export ES_NODES="3"
export ES_CONTAINER_NAME="elasticsearch"
export ES_CONTAINER_REQUEST_MEMORY="8Gi"
export ES_CONTAINER_REQUEST_CPU="2"
export ES_CONTAINER_LIMIT_MEMORY="8Gi"
export ES_CONTAINER_LIMIT_CPU="8"
export ES_ECK_CRDS="https://download.elastic.co/downloads/eck/2.9.0/crds.yaml"
export ES_ECK_OPERATOR="https://download.elastic.co/downloads/eck/2.9.0/operator.yaml"
export LICENSE_FILE="/Users/john/Documents/scaffolding-infra/elastic/license/license.json"


# Login into OpenShift cluster
oc login "$OCP_HOST" --insecure-skip-tls-verify --username="$OCP_USER" --password="$OCP_PASSWORD"

# Check and create namespace if not exists
if ! oc get namespace "$ES_NAMESPACE" &>/dev/null; then
  oc create namespace "$ES_NAMESPACE"
fi

# Create ECK CRDs
oc apply -f "$ES_ECK_CRDS"

# Deploy the ECK operator
oc apply -f "$ES_ECK_OPERATOR"

# Render Elasticsearch template and create Elasticsearch cluster
cat <<EOF > /tmp/elastic-cluster.yml
$(envsubst < template/elastic-cluster.sh.j2)
EOF
oc apply -f /tmp/elastic-cluster.yml

# Monitor Elasticsearch health
for i in {1..15}; do
  ES_HEALTH=$(oc get elasticsearch -n "$ES_NAMESPACE" "$ES_CLUSTER" -o jsonpath='{.status.health}' 2>/dev/null)
  if [[ "$ES_HEALTH" == "green" ]]; then
    echo "Elasticsearch is healthy."
    break
  fi
  echo "trying elastic...."
  sleep 30
done

# Render and create Kibana instance
cat <<EOF > /tmp/kibana.yml
$(envsubst < template/kibana-instance.sh.j2)
EOF
oc apply -f /tmp/kibana.yml

# Monitor Kibana health
for i in {1..15}; do
  KIBANA_HEALTH=$(oc get kibana -n "$ES_NAMESPACE" "$ES_CLUSTER" -o jsonpath='{.status.health}' 2>/dev/null)
  if [[ "$KIBANA_HEALTH" == "green" ]]; then
    echo "Kibana is healthy."
    break
  fi
  echo "trying kibana...."
  sleep 30
done

# Copy license file and create secret
cp "$LICENSE_FILE" /tmp/license.json
if ! oc get secret eck-license -n elastic-system &>/dev/null; then
  oc create secret generic eck-license --from-file=/tmp/license.json -n elastic-system
fi

# Label the secret
oc label secret eck-license "license.k8s.elastic.co/scope"=operator -n elastic-system

# Obtain Elasticsearch password
ES_PASSWORD=$(oc get secret -n "$ES_NAMESPACE" "$ES_CLUSTER-es-elastic-user" -o=jsonpath='{.data.elastic}' | base64 -d)

# Obtain Kibana IP
KIBANA_IP=$(oc get service -n "$ES_NAMESPACE" "$ES_CLUSTER-kb-http" -o jsonpath='{.spec.clusterIP}')

# Render and create routes
cat <<EOF > /tmp/route-kibana.yml
$(envsubst < template/route-kibana.j2)
EOF
oc apply -f /tmp/route-kibana.yml -n "$ES_NAMESPACE"

cat <<EOF > /tmp/route-elastic.yml
$(envsubst < template/route-elastic.j2)
EOF
oc apply -f /tmp/route-elastic.yml -n "$ES_NAMESPACE"

# Obtain routes
ROUTES=$(oc get routes -n "$ES_NAMESPACE")

# Output result
OUTPUT_CONTENT="The routes are: $ROUTES and the password is: $ES_PASSWORD"
echo "$OUTPUT_CONTENT" > /tmp/output_content.txt

# Print password
echo "Elasticsearch password: $ES_PASSWORD"
echo "Kibana routes: $ROUTES"
