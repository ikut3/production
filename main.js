/* This is a test 2 */

var express = require('express');
var app = express();

var util = require('./utils');
var mongoose = require('mongoose');
var StatsD = require('node-dogstatsd').StatsD;
var dogstatsd = new StatsD();
dogstatsd.increment('page.views')
module.exports = app;
/**
 * Require databse configuration depending on environment
 */
var conf = {
  development: {
    servers: [['127.0.0.1', 27017]],
    database: 'db_name',
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
  res.send('hello world');
});

app.get('/health', function (req, res) {
  res.send('All good');
});

app.listen(3000, function () {
  console.log('Example app listening on port 3000!');
});
