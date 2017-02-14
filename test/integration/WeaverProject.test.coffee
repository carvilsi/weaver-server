require("./../test-suite")
supertest = require('supertest')
should    = require('should')
config    = require('./../../config/default')

weaverServer = supertest.agent("http://localhost:#{config.server.port}")

describe 'WeaverNode rest-API test', ->

  ###
   wipe
   
   curl --request POST \
    --url http://localhost:9487/wipe \
    --header 'cache-control: no-cache' \
    --header 'content-type: application/json' \
    --data '{"target":"$SYSTEM"}'
   
  ###

  it 'should wipe the entire SYSTEM', ->
    weaverServer
    .post('/wipe')
    .type('json')
    .send('{"target":"$SYSTEM"}')
    .expect(200)
    .then((res, error) ->
      res.status.should.equal(200)
      res.text.should.equal('OK')
    )
    
    
  it 'should create a new project', ->
    this.timeout(2000)
    weaverServer
    .post('/project/create')
    .type('json')
    .send('{"id":"zx5lindj0000y3xx7l4z10s1","target":"$SYSTEM"}')
    .expect(200)
    .then((res, err) ->
      res.status.should.equal(200)
      # res.text.should.equal('{"ready":0}')
    )
  
  
  
  it 'should checks if the new project is ready', ->
    ###
     This endpoint has some inconsistency sometimes the answering is
     '{"ready":false}' and others is '{"ready":true}'
    ###
  
    weaverServer
    .post('/project/ready')
    .type('json')
    .send('{"id":"zx5lindj0000y3xx7l4z10s1","target":"$SYSTEM"}')
    .expect(200)
    .then((res, err) ->
      res.status.should.equal(200)
      # res.text.should.equal('{"ready":false}')
    )
  
  # it 'should create a node', ->
  #   ###
  #    this endpoint is answering with empty array
  #   ###
  #   weaverServer
  #   .post('/write')
  #   .type('json')
  #   .send('{"operations":[{"action":"create-node","id":"ciz5imq7p0000quxxbk3z4eaq"}],"target":"$SYSTEM"}')
  #   .then((res, err) ->
  #     res.text.should.equal('[]')
  #   )
  
  it 'should list all the projects', ->
    weaverServer
    .get('/project')
    .expect(200)
    .then((res, err) ->
      res.text.should.equal('[{"id":"zx5lindj0000y3xx7l4z10s1","ports":{"minio":31003,"service":30460,"api":31173,"web":30013}}]')
    )
  #
  #
  it 'should deletes the project', ->
    weaverServer
    .post('/project/delete')
    .send('{"id":"zx5lindj0000y3xx7l4z10s1"}')
    .expect(200)
    
  #
  #
  it 'should wipe the entire SYSTEM', ->
    weaverServer
    .post('/wipe')
    .type('json')
    .send('{"target":"$SYSTEM"}')
    .expect(200)
    .then((res, error) ->
      res.status.should.equal(200)
      res.text.should.equal('OK')
    )
  

  