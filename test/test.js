var request = require('supertest');
var app = require('../main.js');
 
describe('GET /', function() {
    it('respond with This is production', function(done) {
          request(app).get('/').expect('This is production', done);
            });
});
