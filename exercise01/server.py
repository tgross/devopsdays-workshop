from functools import lru_cache
import bottle
from bottle import route, run, template
import json5
import requests


# ----------------------------------------
# HTTP routes: fetch the avatar URL from GitHub

@route('/')
@lru_cache(maxsize=1)
def index():
    req = requests.get('https://api.github.com/users/{}'.format(app.config['name']))
    data = req.json()
    avatar_url = data['avatar_url']
    return template('<img src={{url}} />', url=avatar_url)


# ----------------------------------------
# configure and run the server

app = bottle.default_app()
with open('./config.json5', 'r') as f:
    cfg_file = f.read()
    app.config.load_dict(json5.loads(cfg_file))

run(host=app.config['host'], port=app.config['port'])
