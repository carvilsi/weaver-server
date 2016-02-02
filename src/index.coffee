module.exports = (app, http) ->
  
  # Connection test
  app.get('/connection', (req, res) ->
    res.status(204).send()
  )

  # Socket io
  io = require('socket.io')(http)
  io.on('connection', (socket) ->
    require('./routes').wire(socket)
  )