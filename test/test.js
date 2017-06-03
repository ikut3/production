var request = require('supertest').agent(app.listen());
var app = require('../main.js');
 
describe('GET /', function() {
    it('respond with hello world', function(done) {
          request(app).get('/').expect('hello world', done);
            });
});
