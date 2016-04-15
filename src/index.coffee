Promise    = require('bluebird')

Operations = require('./operations')
Database   = require('./database')
Routes     = require('./routes')
REST       = require('./rest')

module.exports = 
  class WeaverServer
  
    constructor: (url) ->
      @database = new Database(url)
      @plugins  = []

    addPlugin: (plugin) ->
      @plugins.push(plugin)

    setConnector: (connector) ->
      @connector = connector
      @connector.init().then(

        # resolved
        =>
          @operations = new Operations(@database, @connector)
          @routes     = new Routes(@operations)
          @rest       = new REST(@operations)

          Promise.resolve()

        # rejected
        (error) ->
          Promise.reject(error)
      )

    wire: (app, http) ->  
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
        plugin.setDatabase(@database) if plugin.setDatabase?
        plugin.wire(app, http)

      # Wire connector