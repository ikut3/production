/* This is a test 2 */

var express = require('express');
var app = express();
var dotenv = require('dotenv');
var util = require('./utils');
var mongoose = require('mongoose');
var StatsD = require('node-dogstatsd').StatsD;
var dogstatsd = new StatsD();
dogstatsd.increment('page.views')
module.exports = app;
dotenv.load();
/**
 * Require databse configuration depending on environment
 */
var conf = {
  development: {
    servers: [[process.env.DATABASE_DEV_IP, process.env.DATABASE_DEV_PORT]],
    database: process.env.DATABASE_NAME,
    user: '',
    password: '',
    replicaSet: null,
  },
  production: {
    servers: [[process.env.DATABASE_IP, process.env.DATABASE_PORT]],
    database: process.env.DATABASE_NAME,
    user: process.env.DATABASE_USER,
    password: process.env.DATABASE_PASSWORD,
    replicaSet: null,
  }
};
var options = {};

var connectionString = util.createConnectionString(conf['development']);


if (conf.replicaSet) {
  options.replset = conf.replicaSet;
}

mongoose.connect(connectionString, options);


app.get('/', function (req, res) {
  res.send('hello myfriend');
});

app.get('/health', function (req, res) {
  res.send('All good');
});

app.listen(process.env.PORT, 'localhost', function () {
  console.log('Example app listening on port 3000!');
});
