# -*- mode: Python -*-

#docker_compose("./docker-compose.yml")

# default_registry(
#     'localhost:8888',
#     host_from_cluster='registry:8888'
# )

# docker_build('nginx-image', './web',
#     live_update=[
#         sync('./web/nginx.conf', '/etc/nginx/nginx.conf'),
#         sync('./web/index.html', '/usr/share/nginx/html/index.html')
# ])

# k8s_yaml('./web/kubernetes.yaml')

####
allow_k8s_contexts('k3d-alfa')

docker_build('t1-image', './app',
    live_update=[
        sync('./app', '/app'),
        run('cd /app && pip install -r requirements.txt',
            trigger='./app/requirements.txt')
])

k8s_yaml('./configMap.yaml')

k8s_yaml('./app/kubernetes.yaml')

k8s_resource('t1',
            port_forwards=[
                        5000,  # app
                        5555,  # debugger
            ])

# k8s_yaml(['./kube/02-storageclass-kind.yaml',
#         './kube/03-install-cass-operator-v1.3.yaml',
#         './kube/04-cassandra-cluster-1nodes.yaml',
#         './kube/05-configMap.yaml',
#         './kube/06-backend.yaml'])


#############

        # k8s_yaml(['./nosql/node-deployment.yaml',
#         './nosql/kube_graph-networkpolicy.yaml',
#         './nosql/seed-claim0-persistentvolumeclaim.yaml',
#         './nosql/seed-deployment.yaml',
#         './nosql/seed-service.yaml'])