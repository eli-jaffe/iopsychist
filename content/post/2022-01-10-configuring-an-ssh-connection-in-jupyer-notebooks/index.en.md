---
title: Configuring an SSH connection in Jupyter Notebooks
author: IOPsychist
date: '2022-01-10'
slug: configuring-an-ssh-connection-in-jupyter-notebooks
categories:
  - People Analytics
tags:
  - Jupyter
  - Python
  - Database
  - MySQL
  - tutorial
subtitle: ''
summary: ''
authors: []
lastmod: '2022-01-10T09:19:31-05:00'
featured: no
image:
  caption: ''
  focal_point: ''
  preview_only: no
projects: []
---


Sometimes, the database you want to connect a Jupyter Notebook to is  located behind an SSH tunnel. Using the files here, you can set establish the SSH connection and connect to the database all from within Python.

I have this set up such that both the config file and the connector methods are separate from the Python script you are working in. However, you can also copy the mypython_dbconnector.py file into a Jupyter Notebook and not worry about importing it. I like the separation to keep the ipynb file clean. *Note:* this code is adapted from https://practicaldatascience.co.uk/data-science/how-to-connect-to-mysql-via-an-ssh-tunnel-in-python


## Create the functions we will use

We need to define a few functions for easily connecting to the database. In this case, we are connecting to a MySQL database so we use the Python package `pymysql`. This can easily be changed to a different database if your needs require.

Create a file mypython_dbconnector.py with the following code:

```python

import pandas as pd
import matplotlib.pyplot as plt
import pymysql
import logging
import sshtunnel
from sshtunnel import SSHTunnelForwarder

import config


# define the functions we will be using

def open_ssh_tunnel(verbose=False):
    """Open an SSH tunnel and connect using a username and password.
    
    :param verbose: Set to True to show logging
    :return tunnel: Global SSH tunnel connection
    """
    
    if verbose:
        sshtunnel.DEFAULT_LOGLEVEL = logging.DEBUG
    
    global tunnel
    tunnel = SSHTunnelForwarder(
        (config.ssh_host, 22),
        ssh_username = config.ssh_username,
        ssh_password = config.ssh_password,
        remote_bind_address = ('127.0.0.1', 3306)
    )
    
    tunnel.start()
    
    
def mysql_connect():
    """Connect to a MySQL server using the SSH tunnel connection
    
    :return connection: Global MySQL database connection
    """
    
    global connection
    
    connection = pymysql.connect(
        host='127.0.0.1',
        user=config.database_username,
        password=config.database_password,
        database=config.database_name,
        port=tunnel.local_bind_port
    )
    

def run_query(sql):
    """Runs a given SQL query via the global database connection.
    
    :param sql: MySQL query
    :return: Pandas dataframe containing results
    """
    
    return pd.read_sql_query(sql, connection)


def mysql_disconnect():
    """Closes the MySQL database connection.
    """
    
    connection.close()
    
    
def close_ssh_tunnel():
    """Closes the SSH tunnel connection.
    """
    
    tunnel.close

```

<div class="warning" style="background-color:lightyellow">
<i>Note:</i> saving this file as dbconnector.py may interfere with other packages in your environment and lead to unexpected behaviors.
</div>


## Create the config file with our connection credentials

Next, we need to provide python with the credentials to connect. I like to define these in a separate file so that I can share the actual Jupyter notebook with my work and not have to worry about security. Enter your usernames and passwords in the file below and save it as `config.py`.

```python

# Standard TCP/IP

# may need to change this depending on your tunnel connection details
ssh_host = '128.122.34.205'
# port 22 by default

ssh_username = 'SSH_USERNAME'
ssh_password = 'SSH_PASSWORD'

database_name = 'YOUR_DATABASE_NAME'
localhost = '127.0.0.1'
# port 3306 by default

database_username = 'YOUR_USERNAME'
database_password = 'YOUR_PASSWORD'

```

## Connect to the database and get to work!

Finally, we are ready to connect and start working with our data. Make sure both the files we just created are in the same directory and then create a new Jupyter Notebook file in the same location.

```python

import pandas as pd
import matplotlib.pyplot as plt
import numpy as np

import mypython_dbconnector

```

We start with the imports we will be using for our work, along with importing our file `mypthon_dbconnector.py`. Now, all we need to do is call the functions we defined earlier. We then pass our sql query as a string to our `run_query()` command and save the return value to a dataframe. Rinse and repeat as necessary!

```python
# connect to ssh tunnel and to mysql db
mypython_dbconnector.open_ssh_tunnel()
mypython_dbconnector.mysql_connect()

# define query
query = '''
SELECT
    *
FROM
    table_name
'''

df = mypython_dbconnector.run_query(query)

# your data analysis here
# TODO

# close mysql connection and close ssh tunnel
mypython_dbconnector.mysql_disconnect()
mypython_dbconnector.close_ssh_tunnel()
```


Once you are connected to the database through the ssh tunnel, you can access it a you normally would. Be sure to disconnect from the database and close the SSH tunnel when you are done working with it. The full directory setup with example jupyter notebook can be found at https://github.com/eli-jaffe/ssh_mysql_connect.

