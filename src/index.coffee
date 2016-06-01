Promise    = require('bluebird')      
bodyParser = require('body-parser')   # POST requests


Operations = require('./operations')
Database   = require('./database')
Routes     = require('./routes')
REST       = require('./rest')

module.exports = 
  class WeaverServer
  
    constructor: (port, host, @opts) ->
      @database = new Database(port, host)
      @plugins  = []
      
    connect: ->
      @database.connect()

    addPlugin: (plugin) ->
      @plugins.push(plugin)

    setConnector: (connector) ->
      @connector = connector
      @connector.init().then(

        # resolved
        =>
          @operations = new Operations(@database, @connector, @opts)
          @routes     = new Routes(@operations)  # Accepting socket connections
          @rest       = new REST(@operations)    # Accepting rest calls

          Promise.resolve()

        # rejected
        (error) ->
          Promise.reject(error)
      )

    wire: (app, http) ->

      # For POST requests
      app.use(bodyParser.json({limit: '1000000mb'})) # Support json encoded bodies
      app.use(bodyParser.urlencoded({limit: '1000000mb', extended: true })) # Support encoded bodies
            
      # Connection test
      app.get('/connection', (req, res) ->
        res.status(204).send()
      )
    
      # Socket io
      io = require('socket.io')(http)
      self = @
      io.on('connection', (socket) ->
        self.routes.wire(socket)
      )
      
      # REST
      @rest.wire(app)
      
      # Loop through plugins
      for plugin in @plugins
        plugin.setDatabase(@operations) if plugin.setDatabase?
        plugin.wire(app, http)

      # Wire connector
