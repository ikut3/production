#!/bin/sh
ssh prod@ch.ilawyer.vn <<EOF
ssh root@localhost -p 2210 
echo "Testing code from Staging Branch"
cd /opt/production
git checkout production && git pull
npm install
cd /opt/production/node_modules/mocha
./bin/mocha /opt/prod/production/test/test.js
EOF
