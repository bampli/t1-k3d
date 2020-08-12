import os
import flask
import json

# for remote debugging
import ptvsd
ptvsd.enable_attach(address=('0.0.0.0', 5678))

import mysql.connector

import cassandra
from cassandra.cluster import Cluster, GraphExecutionProfile, EXEC_PROFILE_GRAPH_DEFAULT
from cassandra.graph import GraphOptions, GraphProtocol, graph_graphson3_row_factory

class DBManager:
    def __init__(self, database='example', host="db", user="root", password_file=None):
        pf = open(password_file, 'r')
        self.connection = mysql.connector.connect(
            user=user, 
            password=pf.read(),
            host=host,
            database=database,
            auth_plugin='mysql_native_password'
        )
        pf.close()
        self.cursor = self.connection.cursor()
    
    def populate_db(self):
        self.cursor.execute('DROP TABLE IF EXISTS blog')
        self.cursor.execute('CREATE TABLE blog (id INT AUTO_INCREMENT PRIMARY KEY, title VARCHAR(255))')
        self.cursor.executemany('INSERT INTO blog (id, title) VALUES (%s, %s);', [(i, 'Blog post #%d'% i) for i in range (1,5)])
        self.connection.commit()
    
    def query_titles(self):
        self.cursor.execute('SELECT title FROM blog')
        rec = []
        for c in self.cursor:
            rec.append(c[0])
        return rec

server = flask.Flask(__name__)
conn = None

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

    # rec = session.execute_graph("g.V().count()", execution_profile='core')
    rec = session.execute_graph("g.V().has('Sensor', 'sensor_name', '104115939'). \
        project('name', 'latitude', 'longitude'). \
            by('sensor_name'). \
            by('latitude'). \
            by('longitude').fold()",
        execution_profile='core')

    result = []
    for c in rec:
        result.append(c)

    return flask.jsonify({"response": result})

@server.route('/blogs')
def listBlog():
    global conn
    if not conn:
        conn = DBManager(password_file='/run/secrets/db-password')
        conn.populate_db()
    rec = conn.query_titles()

    result = []
    for c in rec:
        result.append(c)

    return flask.jsonify({"response": result})

@server.route('/')
def hello():
    return flask.jsonify({"response": "Hello from Jose&Tilt!"})

# for remote debuging use FALSE
if __name__ == '__main__':
    server.run(debug=False, host='0.0.0.0', port=5000)
