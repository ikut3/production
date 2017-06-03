#!/bin/sh
ssh prod@ch.ilawyer.vn <<EOF
cd /opt/prod/production
npm install
cd /opt/prod/production/node_modules/mocha/bin
./mocha /opt/prod/production/test/test.js
EOF
