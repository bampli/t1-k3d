# t1

### Test1

## Containers

- **Web**: Nginx
- **App**: Flask
- **DB**: MySQL
- **NOSQL**: Datastax

## Get Started

- VSCode
- Remote Debugging: [MS ptvsd](https://github.com/Microsoft/ptvsd/)

Based on best practices for Python projects with Docker Compose, presented at DockerCon-2020.

- video: [Best Practices for Compose-managed Python Applications](https://docker.events.cube365.net/docker/dockercon/content/Videos/eWWPtj5dmHAmoYypc) by Anca Lordache - Docker Enginner.
- repository: [Demo resources for DockerCon](https://github.com/aiordache/demos/tree/master/dockercon2020-demo)

## Graph Traversal

###### query
```console
@server.route('/ver')
def gtest():

    graph_name = 'trees_prod'
    ep_graphson3 = GraphExecutionProfile(
        row_factory=graph_graphson3_row_factory,
        graph_options=GraphOptions(
            graph_protocol=GraphProtocol.GRAPHSON_3_0,
            graph_name=graph_name))

    cluster = Cluster(contact_points=['172.18.0.4'], execution_profiles={'core': ep_graphson3})

    session = cluster.connect()

    rec = session.execute_graph("g.V().has('Sensor', 'sensor_name', '104115939').
                project('name').
                by('sensor_name').fold()",
            execution_profile='core')

    result = []
    for c in rec:
        result.append(c)

    return flask.jsonify({"response": result})
```
###### response
```console
GET /ver
Server response
{"response":[[{"name":"104115939"}]]}
```
