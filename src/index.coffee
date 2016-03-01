routes = require('./routes')

module.exports = 
  redis: (url) ->
    routes.redis(url)
    
  wire: (app, http) ->  
    # Connection test
    app.get('/connection', (req, res) ->
      res.status(204).send()
    )
  
    # Socket io
    io = require('socket.io')(http)
    io.on('connection', (socket) ->
      routes.wire(socket)
    )