require("./../test-suite")
supertest = require('supertest')
should    = require('should')
config    = require('./../config/test')
img       = require('./data/imgBufferData')
fs        = require('fs')
request = require('request')
path = require('path')

weaverServer = supertest.agent("http://#{config.server.ip}:#{config.server.port}")
file = ''

describe 'WeaverFile rest-API test', ->

  # it 'should wipe the entire SYSTEM', ->
  #   weaverServer
  #   .post('/wipe')
  #   .type('json')
  #   .send('{"target":"$SYSTEM"}')
  #   .expect(200)
  #   .then((res) ->
  #     res.status.should.equal(200)
  #     res.text.should.equal('OK')
  #   )


  it 'should create a new file with a new file', ->
    this.timeout(8000)
    weaverServer
    .post('/upload')
    .type('json')
    .field('fileName','icon.png')
    .field('target','area51')
    .field('authToken','eyJhbGciOiJSUzI1NiJ9.eyIkaW50X3Blcm1zIjpbImRlbGV0ZV9hcHBsaWNhdGlvbiIsInJlYWRfYXBwbGljYXRpb24iLCJjcmVhdGVfcm9sZSIsImRlbGV0ZV9yb2xlIiwiY3JlYXRlX3Blcm1pc3Npb24iLCJjcmVhdGVfYXBwbGljYXRpb24iLCJkZWxldGVfZGlyZWN0b3J5IiwiZGVsZXRlX3Blcm1pc3Npb24iLCJjcmVhdGVfZGlyZWN0b3J5IiwicmVhZF91c2VyIiwiY3JlYXRlX3VzZXIiLCJyZWFkX3Blcm1pc3Npb24iLCJkZWxldGVfdXNlciIsInJlYWRfcm9sZSIsInJlYWRfZGlyZWN0b3J5Il0sInN1YiI6Im9yZy5wYWM0ai5tb25nby5wcm9maWxlLk1vbmdvUHJvZmlsZSNwaG9lbml4IiwiJGludF9yb2xlcyI6WyJwaG9lbml4Il0sIl9pZCI6IjU4NzYwMTRjNDEwZGY4MDAwMWQ3NWNiYyIsImV4cCI6MTQ4NDQwNjAzOSwiaWF0IjoxNDg0MzE5NjM5fQ.SBoAFpFpyhwL_8tCokurVPOlLAfm1Mb4Bpvu-QBuSR1N9p94uXZZNr17jHHRNphO5peuEf7tahzQt5mmXZrczOlDiPrVA9ayvf-Ki4bNTqYpMMvrx0Ew1ovF3IxMSYS7Xz0xP7dzem6JR8BF-xmxA3gfO1eNmfTBDlg5uBbFaMaWNhNJfjCHLB69ykCSz6-WkDGj7lo6X3FjCOzZACNrepr8qAPMaJfnxXALCq75TmhSx_Hu8QlwcGnh8lFbZXQI2BnJJgKtM8YAFJeH9jbm82ZTsat-MH4kPn0ERCVmPsUt4c10BksLxxpBSV6FlnySncCP3EsiFuWdNnvhrY9MPw')
    .attach('file',path.join(__dirname,'./../../icon.png'))
    .expect(200)
    .then((res) ->
      file = res.text
      res.text.should.containEql('-icon.png')
    )


  # it 'should retrieve a file by fileName', ->
  #   weaverServer
  #   .get('/file/download?payload={"fileName":"' + file + '","target":"area51","authToken":"eyJhbGciOiJSUzI1NiJ9.eyIkaW50X3Blcm1©"}')
  #   .expect(200)
  #   .then((res) ->
  #     json = JSON.stringify(res.body)
  #     dataJson = JSON.parse(json)
  #     dataJson.data.should.eql(img.data)
  #   )
  #
  #
  # it 'should fails retrieving a file, because the file does not exits on server', ->
  #   weaverServer
  #   .get('/file/download?payload={"fileName":"foo.bar","target":"area51","authToken":"eyJhbGciOiJSUzI1NiJ9.eyIkaW50X3Blcm1©"}')
  #   .expect(503)
  #   .then((res) ->
  #     error = JSON.parse(res.text)
  #     if res.error
  #       error.code.should.equal('NoSuchKey')
  #   )
  #
  #
  # it 'should fails retrieving a file, because the project does not exits on server', ->
  #   weaverServer
  #   .get('/file/download?payload={"fileName":"' + file + '","target":"area56","authToken":"eyJhbGciOiJSUzI1NiJ9.eyIkaW50X3Blcm1©"}')
  #   .expect(503)
  #   .then((res, err) ->
  #     error = JSON.parse(res.text)
  #     if res.error
  #       error.code.should.equal('NoSuchBucket')
  #   )
  #
  # it 'should retrieve a file by ID', ->
  #   fileId = "#{file}".split('-')[0]
  #   weaverServer
  #   .get('/file/downloadByID?payload={"id":"' + fileId + '","target":"area51","authToken":"eyJhbGciOiJSUzI1NiJ9.eyIkaW50X3Blcm1©"}')
  #   .expect(200)
  #   .then((res) ->
  #     json = JSON.stringify(res.body)
  #     dataJson = JSON.parse(json)
  #     dataJson.data.should.eql(img.data)
  #   )
  #
  #
  # it 'should fails retrieving a file by ID, because there is no file matching this ID', ->
  #   weaverServer
  #   .get('/file/downloadByID?payload={"id":"555","target":"area51","authToken":"eyJhbGciOiJSUzI1NiJ9.eyIkaW50X3Blcm1©"}')
  #   .expect(503)
  #   .then((res) ->
  #     error = JSON.parse(res.text)
  #     if res.error
  #       error.code.should.equal(603)
  #   )
  #
  #
  # it 'should deletes a file by name', ->
  #   weaverServer
  #   .post('/file/delete')
  #   .type('json')
  #   .send('{"fileName":"' + file + '","target":"area51","authToken":"eyJhbGciOiJSUzI1NiJ9.eyIkaW50X3Blcm1©"}')
  #   .expect(200)
  #
  #
  # it 'should deletes a file by id', ->
  #   weaverServer
  #   .post('/upload')
  #   .type('json')
  #   .field('fileName','icon.png')
  #   .field('target','area51')
  #   .field('authToken','eyJhbGciOiJSUzI1NiJ9.eyIkaW50X3Blcm1zIjpbImRlbGV0ZV9hcHBsaWNhdGlvbiIsInJlYWRfYXBwbGljYXRpb24iLCJjcmVhdGVfcm9sZSIsImRlbGV0ZV9yb2xlIiwiY3JlYXRlX3Blcm1pc3Npb24iLCJjcmVhdGVfYXBwbGljYXRpb24iLCJkZWxldGVfZGlyZWN0b3J5IiwiZGVsZXRlX3Blcm1pc3Npb24iLCJjcmVhdGVfZGlyZWN0b3J5IiwicmVhZF91c2VyIiwiY3JlYXRlX3VzZXIiLCJyZWFkX3Blcm1pc3Npb24iLCJkZWxldGVfdXNlciIsInJlYWRfcm9sZSIsInJlYWRfZGlyZWN0b3J5Il0sInN1YiI6Im9yZy5wYWM0ai5tb25nby5wcm9maWxlLk1vbmdvUHJvZmlsZSNwaG9lbml4IiwiJGludF9yb2xlcyI6WyJwaG9lbml4Il0sIl9pZCI6IjU4NzYwMTRjNDEwZGY4MDAwMWQ3NWNiYyIsImV4cCI6MTQ4NDQwNjAzOSwiaWF0IjoxNDg0MzE5NjM5fQ.SBoAFpFpyhwL_8tCokurVPOlLAfm1Mb4Bpvu-QBuSR1N9p94uXZZNr17jHHRNphO5peuEf7tahzQt5mmXZrczOlDiPrVA9ayvf-Ki4bNTqYpMMvrx0Ew1ovF3IxMSYS7Xz0xP7dzem6JR8BF-xmxA3gfO1eNmfTBDlg5uBbFaMaWNhNJfjCHLB69ykCSz6-WkDGj7lo6X3FjCOzZACNrepr8qAPMaJfnxXALCq75TmhSx_Hu8QlwcGnh8lFbZXQI2BnJJgKtM8YAFJeH9jbm82ZTsat-MH4kPn0ERCVmPsUt4c10BksLxxpBSV6FlnySncCP3EsiFuWdNnvhrY9MPw')
  #   .attach('file',path.join(__dirname,'./../../icon.png'))
  #   .expect(200)
  #   .then((res) ->
  #     file = res.text
  #     res.text.should.containEql('-icon.png')
  #     fileId = "#{file}".split('-')[0]
  #     weaverServer
  #     .post('/file/deleteByID')
  #     .type('json')
  #     .send('{"id":"' + fileId + '","target":"area51","authToken":"eyJhbGciOiJSUzI1NiJ9.eyIkaW50X3Blcm1©"}')
  #     .expect(200)
  #   )
  #
  #
  # it 'should fails trying to delete a file because the project does not exists', ->
  #   weaverServer
  #   .post('/file/delete')
  #   .type('json')
  #   .send('{"fileName":"' + file + '","target":"area56","authToken":"eyJhbGciOiJSUzI1NiJ9.eyIkaW50X3Blcm1©"}')
  #   .expect(503)
  #   .then((res) ->
  #     error = JSON.parse(res.text)
  #     if res.error
  #       error.code.should.equal(603)
  #   )
  #
  #
  # it 'should fails trying to delete a file by ID because the project does not exists', ->
  #   weaverServer
  #   .post('/file/deleteByID')
  #   .type('json')
  #   .send('{"id":"' + file + '","target":"area56","authToken":"eyJhbGciOiJSUzI1NiJ9.eyIkaW50X3Blcm1©"}')
  #   .expect(503)
  #   .then((res) ->
  #     error = JSON.parse(res.text)
  #     if res.error
  #       error.code.should.equal(603)
  #   )
