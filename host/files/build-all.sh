#!/bin/bash
set -e

root="$(pwd)/workshop"
rm -rf "$root"
git clone https://github.com/tgross/devopsdays-workshop "$root"

cd "${root}/image-base"
docker build -t="workshop-py" .

cd "${root}/student"
docker build -t="student" .
