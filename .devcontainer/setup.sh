#!/usr/bin/env bash
set -e

echo "Inatall base packages..."
microdnf install -y bash jq curl tar gzip gnupg openssl ca-certificates

echo "Install IBM Cloud CLI..."
curl -fsSL https://clis.cloud.ibm.com/install/linux | sh
ibmcloud plugin install kubernetes-service
ibmcloud plugin install container-service
ibmcloud plugin install container-registry

echo "Install kubectl..."

KUBECTL_VERSION=$(curl -s -L https://dl.k8s.io/release/stable.txt)

if [ -z "$KUBECTL_VERSION" ]; then
  echo "Error to get kubectl"
  exit 1
fi

echo "Version kubectl $KUBECTL_VERSION"
curl -LO "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl"
install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
rm kubectl



echo "Install helm..."
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod +x get_helm.sh
./get_helm.sh --no-sudo
rm get_helm.sh

echo "Done"
