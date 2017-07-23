from functools import lru_cache
import os

import bottle
from bottle import route, run, template
import json5
import requests


# ----------------------------------------
# HTTP routes: fetch the avatar URL from GitHub

@lru_cache(maxsize=1)
@route('/')
def user():
    req = requests.get(
        'https://api.github.com/users/{}'.format(app.config['name']),
        headers={'Authorization': 'token {}'.format(app.config['token'])})
    data = req.json()
    avatar_url = data['avatar_url']
    return template("""<div><h2>{{name}}</h2>
                       <div><img src={{url}} height="150", width="150"/>
                       </div></div>""",
                    url=avatar_url, name=app.config['name'])


# ----------------------------------------
# configure and run the server
# note we're getting the values from environment now rather
# than from a file

app = bottle.default_app()
app.config.load_dict({
    "name": os.environ['ACCOUNT'],
    "token": os.environ['OAUTH_TOKEN'],
    "host": os.environ.get('NOMAD_IP_HTTP', 'localhost'),
    "port": os.environ.get('NOMAD_PORT_HTTP', 8080)
    })

run(host=app.config['host'], port=app.config['port'])
