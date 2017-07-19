#!/bin/bash
set -e

root="$(pwd)/workshop"
rm -rf "$root"
git clone https://github.com/tgross/devopsdays-workshop "$root"

cd "${root}/image-base"
docker build -t="workshop-py" .

cd "${root}/student"
docker build -t="student" .

cd "${root}/exercise03"
docker build -t="workshop-nginx" .

# cd "${root}/exercise04"
# docker build -t="workshop-nginx-cp" .
# docker build -t="workshop-py-cp" .
