#!/bin/bash

CURR_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )";
[ -d "$CURR_DIR" ] || { echo "FATAL: no current dir (maybe running in zsh?)";  exit 1; }

# shellcheck source=./common.sh
source "$CURR_DIR/common.sh";

# Note: Setting MSYS_NO_PATHCONV to avoid bash error on windows10
# https://forums.docker.com/t/weird-error-under-git-bash-msys-solved/9210
export MSYS_NO_PATHCONV=1

section "Configure Application"
PASS=$(echo $(kubectl get secret cluster1-superuser -n cass-operator -o yaml | grep -m1 -Po 'password: \K.*') | base64 -d && echo "")
cat kube/05-configMap.yaml | sed "s/superuserpassword/$PASS/" - > configMap.yaml
info_exec "Create namespace my-app" "kubectl create ns my-app"
info_exec "Create configMap" "kubectl -n my-app apply -f configMap.yaml"

# section "App setup"
# info_exec "Build the sample-app" "docker build app/ -f app/Dockerfile -t sample-app:local"
# info_exec "Load the sample-app image into the cluster" "k3d image import -c alfa sample-app:local"
# info_exec "Create a new 'alfa' namespace" "kubectl create namespace alfa"
# info_exec "Check the pods" "kubectl get pods --all-namespaces"

# section "The End"
# info_exec "Delete the Cluster" "k3d cluster delete alfa"

```shell script
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-test-registry
  labels:
    app: nginx-test-registry
spec:
  replicas: 1
  selector:
    matchLabels:
      app: nginx-test-registry
  template:
    metadata:
      labels:
        app: nginx-test-registry
    spec:
      containers:
      - name: nginx-test-registry
        image: registry.localhost:5000/nginx:latest
        ports:
        - containerPort: 80
EOF
