require("./test-suite")()
sinon = require('sinon')
WeaverServer = require('./../src/index')

io   = require('socket.io-client')
app  = require('express')()
http = require('http').Server(app)

describe 'Authentication', ->
  
  serverPort = '9487'
  serverUrl = 'http://localhost:' + serverPort
  server = null
  mockConnector = null

  beforeEach ->
    server = new WeaverServer(6379, process.env.REDIS_HOST or "localhost", {wipeEnabled: true})
    
    mockConnector =  {}
    mockConnector.init = sinon.stub()
    mockConnector.init.onFirstCall().returns(Promise.resolve())


  it 'Should allow read if no tokens are set', (done) ->

    server.setConnector(mockConnector)
    server.connect().then(->
      server.wire(app, http)
      http.listen(serverPort, ->
        
        connection = io.connect(serverUrl)

        connection.emit('authenticate', '', (response) ->
          assert.isTrue(response.read)
          assert.isTrue(response.write)

          connection.emit("create", {id :'test', attributes: {name: 'test'}, relations: {}, type: 'root'}, (response) ->
            connection.emit("read", {id :'test', opts: {'eagerness: 1'}}, (response) ->
              expect(response).to.have.property('_META');
              done()
            )
          )

        )
      )
    )

    
  it 'Should allow write if no tokens are set', (done) ->
    
    server.setConnector(mockConnector)
    server.connect().then(->
      server.wire(app, http)
      http.listen(serverPort, ->
    
        connection = io.connect(serverUrl)
    
        connection.emit('authenticate', '', (response) ->
          assert.isTrue(response.read)
          assert.isTrue(response.write)
    
          connection.emit("create", {id :'test1', attributes: {name: 'test'}, relations: {}, type: 'root'}, (response) ->
            expect(response[0]).to.be.null
            done()
          )
        )
      )
    )

    
  it 'Should deny read if token is invalid', (done) ->

    server.opts['readToken']  = 'read'
    server.opts['writeToken'] = 'write'
    
    server.setConnector(mockConnector)
    server.connect().then(->
      server.wire(app, http)
      http.listen(serverPort, ->

        connection = io.connect(serverUrl)

        connection.emit('authenticate', 'notread', (response) ->
          assert.isFalse(response.read)
          assert.isFalse(response.write)

          connection.emit("read", {'id' :'test1', opts: {'eagerness: 1'}}, (response) ->
            assert.equal(response, 'unauthorized to read operations')
            done()
          )
        )
      )
    )

    
  it 'Should allow read if token is valid', (done) ->

    server.opts['readToken']  = 'read'
    server.opts['writeToken'] = 'write'

    server.setConnector(mockConnector)
    server.connect().then(->
      server.wire(app, http)
      http.listen(serverPort, ->

        connection = io.connect(serverUrl)

        connection.emit('authenticate', 'read', (response) ->
          assert.isTrue(response.read)
          assert.isFalse(response.write)

          connection.emit("read", {'id' :'test1', opts: {'eagerness: 1'}}, (response) ->
            expect(response).to.have.property('_META');
            done()
          )
        )
      )
    )

    
  it 'Should deny write if token is invalid', (done) ->

    server.opts['readToken']  = 'read'
    server.opts['writeToken'] = 'write'

    server.setConnector(mockConnector)
    server.connect().then(->
      server.wire(app, http)
      http.listen(serverPort, ->

        connection = io.connect(serverUrl)

        connection.emit('authenticate', 'notwrite', (response) ->
          assert.isFalse(response.read)
          assert.isFalse(response.write)

          connection.emit("create", {id :'test1', attributes: {name: 'test'}, relations: {}, type: 'root'}, (response) ->
            assert.equal(response, 'unauthorized to write operations')
            done()
          )
        )
      )
    )

    
  it 'Should allow write if token is valid', (done) ->

    server.opts['readToken']  = 'read'
    server.opts['writeToken'] = 'write'
    
    server.setConnector(mockConnector)
    server.connect().then(->
      server.wire(app, http)
      http.listen(serverPort, ->

        connection = io.connect(serverUrl)

        connection.emit('authenticate', 'write', (response) ->
          assert.isTrue(response.read)
          assert.isTrue(response.write)

          connection.emit("create", {id :'test1', attributes: {name: 'test'}, relations: {}, type: 'root'}, (response) ->
            expect(response[0]).to.be.null
            done()
          )
        )
      )
    )


  it 'Should allow read if token for write is valid', (done) ->

    server.opts['readToken']  = 'read'
    server.opts['writeToken'] = 'write'

    server.setConnector(mockConnector)
    server.connect().then(->
      server.wire(app, http)
      http.listen(serverPort, ->

        connection = io.connect(serverUrl)

        connection.emit('authenticate', 'write', (response) ->
          assert.isTrue(response.read)
          assert.isTrue(response.write)

          connection.emit("read", {'id' :'test1', opts: {'eagerness: 1'}}, (response) ->
            expect(response).to.have.property('_META');
            done()
          )
        )
      )
    )


  it 'Should deny write if token for read is valid', (done) ->

    server.opts['readToken']  = 'read'
    server.opts['writeToken'] = 'write'

    server.setConnector(mockConnector)
    server.connect().then(->
      server.wire(app, http)
      http.listen(serverPort, ->

        connection = io.connect(serverUrl)

        connection.emit('authenticate', 'read', (response) ->
          assert.isTrue(response.read)
          assert.isFalse(response.write)

          connection.emit("create", {id :'test1', attributes: {name: 'test'}, relations: {}, type: 'root'}, (response) ->
            assert.equal(response, 'unauthorized to write operations')
            done()
          )
        )
      )
    )

describe 'ExceptionHandling', ->

  serverPort = '9487'
  serverUrl = 'http://localhost:' + serverPort
  server = null
  mockConnector = null

  beforeEach ->
    server = new WeaverServer(6379, process.env.REDIS_HOST or "192.168.99.100", {wipeEnabled: true})

    mockConnector =  {}
    mockConnector.init = sinon.stub()
    mockConnector.init.onFirstCall().returns(Promise.resolve())


  it 'Should throw an exception when an attempt is made to retrieve a non-existent entity', (done) ->

    server.setConnector(mockConnector)
    server.connect().then(->
      server.wire(app, http)
      http.listen(serverPort, ->

        connection = io.connect(serverUrl)

        connection.emit('authenticate', '', (response) ->
          assert.isTrue(response.read)
          assert.isTrue(response.write)

          response = connection.emit("read", {id :'non-existent-entity', opts: {'eagerness: 1'}}, (res) ->
            expect(res.code).to.equal(404)
            expect(res.message).to.equal('Entity not found')
            done()
          )

        )
      )
    )