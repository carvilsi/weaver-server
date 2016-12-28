Promise    = require('bluebird')
bodyParser = require('body-parser')   # POST requests
socketIO   = require('socket.io')

Connector  = require('./graph/index')
Operations = require('./operations')
Database   = require('./database')
Routes     = require('./routes')
REST       = require('./rest')
logger     = require('./logger')


module.exports =
  class WeaverServer

    constructor: (@opts) ->
      @database   = new Database(@opts.redisPort, @opts.redisHost)
      @connector  = new Connector(@opts)
      @operations = new Operations(@database, @connector, @opts)
      @routes     = new Routes(@operations, @opts)  # Accepting socket connections
      @rest       = new REST(@operations, @opts)    # Accepting rest calls

      @plugins   = []

    addPlugin: (plugin) ->
      @plugins.push(plugin)

    wire: (app, http) ->

      # For POST requests
      app.use(bodyParser.json({limit: '1000000mb'}))                        # Support json encoded bodies
      app.use(bodyParser.urlencoded({limit: '1000000mb', extended: true })) # Support encoded bodies

      # Connection test
      app.get('/connection', (req, res) ->
        res.status(204).send()
      )

      # Socket io
      io = socketIO(http)
      self = @
      io.on('connection', (socket) ->
        logger.log('debug', 'Socket connection initiated')
        self.routes.wire(socket)
      )

      # REST
      @rest.wire(app)

      # Enable plugins
      for plugin in @plugins
        plugin.setDatabase(@operations) if plugin.setDatabase?
        plugin.wire(app, http)