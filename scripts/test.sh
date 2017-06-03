#!/bin/sh
ssh prod@ch.ilawyer.vn <<EOF
sudo docker exec 133e18e9d894 /bin/bash -c 'cd /opt/production; git checkout master; git pull; npm install; cd /opt/production; node_modules/mocha/bin/mocha /opt/production/test/test.js'
EOF
