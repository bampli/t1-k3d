#!/bin/bash

CURR_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )";
[ -d "$CURR_DIR" ] || { echo "FATAL: no current dir (maybe running in zsh?)";  exit 1; }

# shellcheck source=./common.sh
source "$CURR_DIR/common.sh";

# Note: Setting MSYS_NO_PATHCONV to avoid bash error on windows10
# https://forums.docker.com/t/weird-error-under-git-bash-msys-solved/9210
export MSYS_NO_PATHCONV=1

section "Create a Cluster"
# info "Cluster Name: alfa"
# info "--api-port 6550: expose the Kubernetes API on localhost:6550 (via loadbalancer)"
# info "--servers 1: create 1 server node"
# info "--agents 3: create 3 agent nodes"
# info "--port 8080:80@loadbalancer: map localhost:8080 to port 80 on the loadbalancer (used for ingress)"
# info "--volume /tmp/src:/src@all: mount the local directory /tmp/src to /src in all nodes (used for code)"
# info "--wait: wait for all server nodes to be up before returning"
info_exec "Create a cluster" "k3d cluster create alfa --api-port 6550 --servers 1 --agents 2 --port 8080:80@loadbalancer --volume $(pwd)/db:/src@all --wait"

section "Access the Cluster"
info_exec "List cluster" "k3d cluster list"
info_exec "Update default kubeconfig" "k3d kubeconfig merge alfa --merge-default-kubeconfig --switch-context"
info_exec "Check nodes" "kubectl get nodes"

section "Local Registry"
info_exec "Volume creation" "docker volume create local_registry"
info_exec "Start registry.localhost" "docker container run -d --name registry.localhost -v local_registry:/var/lib/registry --restart always -p 5000:5000 registry:2"
info_exec "Network connection" "docker network connect k3d-alfa registry.localhost"

section "Cassandra"
info_exec "Create namespace cass-operator" "kubectl create ns cass-operator"
info_exec "Create storage class" "kubectl -n cass-operator apply -f kube/02-storageclass-kind.yaml"
info_exec "Configure cass-operator" "kubectl -n cass-operator apply -f kube/03-install-cass-operator-v1.3.yaml"
info_exec "Wait 5s ..." "sleep 5"
info_exec "Start single-node Cassandra cluster" "kubectl -n cass-operator apply -f kube/04-cassandra-cluster-1nodes.yaml"

# section "The End"
# info_exec "Delete the Cluster" "k3d cluster delete alfa"
