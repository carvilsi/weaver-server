Database = require('./database')
Routes   = require('./routes')

module.exports = 
  class WeaverServer
  
    constructor: (url) ->
      @database = new Database(url)
      @routes   = new Routes(@database)
      @plugins  = []

    addPlugin: (plugin) ->
      @plugins.push(plugin)
    
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