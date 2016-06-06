require("./test-suite")()
fs = require('fs')
sinon = require('sinon')
Promise = require('bluebird')
WeaverServer = require('./../src/index')

describe 'Wipe', ->

  server = null

  beforeEach ->
    server = new WeaverServer(6379, process.env.REDIS_HOST or "192.168.99.100", {
      wipeEnabled: true
    })
    
    mockConnector =  {}
    mockConnector.init = sinon.stub()
    mockConnector.init.onFirstCall().returns(Promise.resolve())
    mockConnector.wipe = sinon.stub()
    mockConnector.wipe.onFirstCall().returns(Promise.resolve())

    server.setConnector(mockConnector)

  # for a description of the payload see
  # https://github.com/weaverplatform/weaverplatform/blob/master/weaver-sdk-payloads.md


  it 'Should wipe Redis', ->
    server.connect().then(->
      server.database.wipe().should.be.fulfilled
    )
