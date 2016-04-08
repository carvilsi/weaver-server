Database = require('./database')
Routes   = require('./routes')
Operations   = require('./operations')

module.exports = 
  class WeaverServer
  
    constructor: (url) ->
      @database = new Database(url)
      @routes   = new Routes(@database)
      @plugins  = []
      @connector = null
      @operations = null

    addPlugin: (plugin) ->
      @plugins.push(plugin)

    setConnector: (connector) ->
      @connector = connector
      @connector.init().then(=>
        @operations = new Operations(@database, @connector)
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
      
      # Loop through plugins
      for plugin in @plugins
        plugin.setDatabase(@database) if plugin.setDatabase?
        plugin.wire(app, http)

      # Wire connector
