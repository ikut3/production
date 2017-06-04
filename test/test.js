var request = require('supertest');
var app = require('../main.js');
 
describe('GET /', function() {
    it('respond with This is productions', function(done) {
          request(app).get('/').expect('This is productions', done);
            });
});
