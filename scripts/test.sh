#!/bin/sh
ssh prod@ch.ilawyer.vn <<EOF
ssh root@localhost -p 2210 
echo "Testing code from Production Branch"
cd /opt/production
git checkout master && git pull
sh /nodejs/bin/npm install
cd /opt/production/node_modules/mocha
./bin/mocha /opt//production/test/test.js
EOF
