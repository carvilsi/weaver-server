require("./test-suite")()
sinon           = require('sinon')
WeaverServer    = require('./../src/index')
express         = require('express')
pjson           = require('../package.json')
Sdk = require('weaver-sdk')
# sdk             = require('../node_modules/weaver-sdk/dist/weaver-sdk.full.js')

# runner  = require('./../src/run')

io   = require('socket.io-client')
app  = require('express')()
http = require('http').Server(app)

weaver = null

beforeEach ->
  app.all('*', (req, res, next) ->
    res.header('Access-Control-Allow-Origin', '*');
    res.header('Access-Control-Allow-Methods', 'PUT, GET, POST, DELETE, OPTIONS');
    res.header('Access-Control-Allow-Headers', 'Content-Type');
    next()
  )

  # app.engine('html', mustacheExpress())

  # app.set('view engine', 'html')

  # Index page
  # app.get('/', (req, res) ->
  #   res.render('../html/index.html', {server : pjson.version})
  # )

  # Static serving
  # app.use('/img', express.static('img'));
  app.use('/sdk', express.static('node_modules/weaver-sdk/dist'));

  getWithDefault = (env, defaultValue) ->
    if env? then env else defaultValue

  port =        getWithDefault(process.env.PORT,          9487)
  logDebug =    getWithDefault(process.env.LOG_DEBUG,     'false') == 'true'
  wipeEnabled = getWithDefault(process.env.WIPE_ENABLED,  'true')  == 'true'
  graphPrefix = getWithDefault(process.env.GRAPH_PREFIX,  'http://weaverplatform.com/test#')
  redisHost =   getWithDefault(process.env.REDIS_HOST,    'localhost')
  redisPort =   getWithDefault(process.env.REDIS_PORT,    '6379')

  # Options
  opts =
    wipeEnabled: wipeEnabled
    ignoreLog: true
    weaverServiceIp: 'localhost'
    weaverServicePort: 9474

  # Authentication options
  opts.writeToken = writeToken if writeToken?
  opts.readToken = readToken if readToken?

  # Init
  weaver = new WeaverServer(redisPort, redisHost, opts)
  
  @sdk = new Sdk()
  @sdk.connect('localhost:9487')

  # Connect
  weaver.connect().then(->

    weaver.wire(app, http)

    # Launch
    server = http.listen(port, ->

      top       = '┌─────────────────────────────────────────────────┐'
      title     = '│ Weaver Server BETA                       '
      endTitle  =                                                  ' │'
      rdyCnn    = '│ Using weaver-service at:         '
      endRdyCnn =                                                  ' │'
      ready     = '│ Ready to serve clients on port:            '
      endReady  =                                                  ' │'
      bottom    = '└─────────────────────────────────────────────────┘'

      spaces = ''
      spaces += ' ' while (spaces.length + rdyCnn.length + 1 + opts.weaverServiceIp.length + opts.weaverServicePort.length  < 40)
      # spaces += ' ' while (spaces.length + pjson.version.length + 1 + title.length + endTitle.length +  < 40)
      splash = top + '\n' + title + spaces + 'v' + pjson.version + endTitle + '\n' + ready + port + endReady + '\n' + rdyCnn + opts.weaverServiceIp + ':' + opts.weaverServicePort + endRdyCnn + '\n' + bottom
      console.log(splash .green)
    )
  )
  

describe 'SDK', ->
  
  it 'Should creates an entity', (done) ->
    # console.log @sdk
    # @sdk.node({name:'Thoshiiiio'},'toshio').then((res, err) =>
    #   if err
    #     console.log err
    #   else
    #     console.log res
    # )
    
    weaver.connect().then(->
      connection = io.connect('http://localhost:9487')
      connection.emit("create", {id:'one'}, (response) ->
        connection.emit("read", {id :'one', opts: {'eagerness: 1'}}, (response) ->
          console.log response
          expect(JSON.parse(response[0])).to.have.property('id');
          done()
        )
      )
    )
    
  it 'Should creates an entity with attributes', (done) ->
    weaver.connect().then(->
      connection = io.connect('http://localhost:9487')
      connection.emit("create", {id:'two',attributes:[{key:'Name',value:'The Number 2'}, {key:'isNumber',value:true}]}, (response) ->
        connection.emit("read", {id :'two', opts: {'eagerness: 1'}}, (response) ->
          console.log response
          expect(JSON.parse(response[0])).to.have.property('id');
          done()
        )
      )
    )
    