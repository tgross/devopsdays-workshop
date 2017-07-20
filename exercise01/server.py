from functools import lru_cache
import bottle
from bottle import route, run, template
import json5
import requests

# ----------------------------------------
# HTTP routes

@route('/')
def index():
    avatar_url = get_avatar()
    return template("""<div><h2>{{name}}</h2>
                       <div><img src={{url}} height="200", width="200"/>
                       </div></div>""",
                    url=avatar_url, name=app.config['name'])

@route('/user')
def user():
    avatar_url = get_avatar()
    return { "user": app.config['name'], "url": avatar_url }


# ----------------------------------------
# data: fetch the avatar URL from GitHub

@lru_cache(maxsize=1)
def get_avatar():
    req = requests.get(
        'https://api.github.com/users/{}'.format(app.config['name']),
        headers={'Authorization:': 'token {}'.format(app.config['token'])})
    data = req.json()
    return data['avatar_url']


# ----------------------------------------
# configure and run the server

app = bottle.default_app()
with open('./config.json5', 'r') as f:
    cfg_file = f.read()
    app.config.load_dict(json5.loads(cfg_file))

run(host=app.config['host'], port=app.config['port'])
