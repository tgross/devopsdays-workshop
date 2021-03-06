from functools import lru_cache
import bottle
from bottle import route, run, template
import consul
import json5
import requests

# ----------------------------------------
# service registration

SERVICE_NAME = 'workshop' # don't edit this!

def register_service():
    c = consul.Consul()
    service_id = '{}-{}'.format(SERVICE_NAME, app.config['name'])
    c.agent.service.register(name=SERVICE_NAME,
                             service_id=service_id,
                             address=app.config['host'],
                             port=app.config['port'])

def register_check():
    c = consul.Consul()
    url = 'http://{}:{}'.format(app.config['host'], app.config['port'])
    c.agent.check.register(name=app.config['name'],
                           check=consul.Check.http(url, '10s'))


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

app = bottle.default_app()
with open('./config.json5', 'r') as f:
    cfg_file = f.read()
    app.config.load_dict(json5.loads(cfg_file))

register_service()
#register_check()

run(host=app.config['host'], port=app.config['port'])
