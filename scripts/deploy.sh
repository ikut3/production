#!/bin/sh

ssh prod@ch.ilawyer.vn <<EOF
  cd ~/production
  git pull
  npm install
  forever restartall
  exit
EOF
