var request = require('supertest');
var app = require('../main.js');
 
describe('GET /', function() {
    it('respond with This is a production system', function(done) {
          request(app).get('/').expect('This is a production system', done);
            });
});
