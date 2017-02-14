require("./../test-suite")
supertest = require('supertest')
should    = require('should')
config    = require('./../../config/default')
pckjson   = require('./../../package.json')

weaverServer = supertest.agent("http://localhost:#{config.server.port}")

describe 'Weaver Application rest-API test', ->
  
  it 'should get the weaver-server version', ->
    weaverServer
    .get('/application/version')
    .expect("Content-type",/text/)
    .expect(200)
    .then((res, err) ->
      res.status.should.equal(200)
      res.text.should.equal(pckjson.version)
    )