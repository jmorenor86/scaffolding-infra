#!/bin/bash

export AIRGAPPED=true
export EXIST_LOGIN_OCP=true
export OCP_HOST="CHANGE_ME"
export OCP_USER="CHANGE_ME"
export OCP_PASSWORD="CHANGE_ME"
export ES_NAMESPACE="elastic"
export STORAGECLASS="ibmc-block-gold"
export ES_CLUSTER="wxd"
export ES_STORAGE="50Gi"
export ES_VERSION="9.0.3"
export ES_NODES="3"
export ES_CONTAINER_NAME="elasticsearch"
export ES_CONTAINER_REQUEST_MEMORY="8Gi"
export ES_CONTAINER_REQUEST_CPU="2"
export ES_CONTAINER_LIMIT_MEMORY="8Gi"
export ES_CONTAINER_LIMIT_CPU="8"
export ES_ECK_CRDS="template/airgapped/crds.yaml"
export ES_ECK_OPERATOR="template/airgapped/operator.yaml"
export LICENSE_FILE="license/license.json"



# Login into OpenShift cluster
if [ "$EXIST_LOGIN_OCP" = "false" ]; then
  oc login "$OCP_HOST" --insecure-skip-tls-verify --username="$OCP_USER" --password="$OCP_PASSWORD"
fi



# Check and create namespace if not exists
if ! oc get namespace "$ES_NAMESPACE" &>/dev/null; then
  oc create namespace "$ES_NAMESPACE"
fi

# Create ECK CRDs
oc apply -f "$ES_ECK_CRDS"

# Deploy the ECK operator
oc apply -f "$ES_ECK_OPERATOR"

# Render Elasticsearch template and create Elasticsearch cluster
if [ "$AIRGAPPED" = "true" ]; then
  echo "Using airgapped configuration..."
  cat <<EOF > template/airgapped/render/elastic-cluster.yml
$(envsubst < template/airgapped/elastic-cluster.sh.j2)
EOF

  oc apply -f template/airgapped/render/elastic-cluster.yml
else
  echo "Using standard (non-airgapped) configuration..."
  cat <<EOF > template/elastic-cluster.yml
$(envsubst < template/elastic-cluster.sh.j2)
EOF

  oc apply -f template/elastic-cluster.yml
fi

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

if [ "$AIRGAPPED" = "true" ]; then
  echo "Using airgapped configuration for Kibana..."
  mkdir -p template/airgapped/render/

  cat <<EOF > template/airgapped/render/kibana.yml
$(envsubst < template/kibana-instance.sh.j2)
EOF

  oc apply -f template/airgapped/render/kibana.yml
else
  echo "Using standard (non-airgapped) configuration for Kibana..."

  cat <<EOF > template/kibana.yml
$(envsubst < template/kibana-instance.sh.j2)
EOF

  oc apply -f template/kibana.yml
fi

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
cp "$LICENSE_FILE" template/license.json
if ! oc get secret eck-license -n elastic-system &>/dev/null; then
  oc create secret generic eck-license --from-file=template/airgapped/license.json -n elastic-system
fi

# Label the secret
oc label secret eck-license "license.k8s.elastic.co/scope"=operator -n elastic-system

# Obtain Elasticsearch password
ES_PASSWORD=$(oc get secret -n "$ES_NAMESPACE" "$ES_CLUSTER-es-elastic-user" -o=jsonpath='{.data.elastic}' | base64 -d)

# Obtain Kibana IP
KIBANA_IP=$(oc get service -n "$ES_NAMESPACE" "$ES_CLUSTER-kb-http" -o jsonpath='{.spec.clusterIP}')

# Render and create routes
cat <<EOF > template/airgapped/route-kibana.yml
$(envsubst < template/route-kibana.j2)
EOF
oc apply -f template/airgapped/route-kibana.yml -n "$ES_NAMESPACE"

cat <<EOF > template/airgapped/route-elastic.yml
$(envsubst < template/route-elastic.j2)
EOF
oc apply -f template/airgapped/route-elastic.yml -n "$ES_NAMESPACE"

# Obtain routes
ROUTES=$(oc get routes -n "$ES_NAMESPACE")

# Output result
OUTPUT_CONTENT="The routes are: $ROUTES and the password is: $ES_PASSWORD"
echo "$OUTPUT_CONTENT" > template/airgapped/output_content.txt

# Print password
echo "Elasticsearch password: $ES_PASSWORD"
echo "Kibana routes: $ROUTES"
