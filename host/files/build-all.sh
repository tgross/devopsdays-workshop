#!/bin/bash
set -e

root="$(pwd)/workshop"
rm -rf "$root"
git clone https://github.com/tgross/devopsdays-workshop "$root"

# make sure it's up to date too
cd "${root}"
git pull

cd "${root}/image-base"
docker build -t="workshop-py" .

cd "${root}/student"
docker build -t="student" .

cd "${root}/exercise03"
docker build -t="workshop-nginx" .

cd "${root}/exercise04/nginx"
docker build -t="workshop-nginx-cp" .

cd "${root}/exercise04/app"
docker build -t="workshop-py-cp" .


# clean up any orphan builds
docker image prune -f
