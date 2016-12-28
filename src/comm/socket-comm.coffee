Promise  = require('bluebird')
socketIO = require('socket.io')

module.exports =
  class Socket
    constructor: (@routeHandler) ->

    wire: (http) ->

      io = socketIO(http)
      io.on('connection', (socket) =>

        # Error handler
        socket.on('error',  (err) ->
          console.log(err)
          #logger.log('error', err.stack)
        )

        # Disconnect
        socket.on('disconnect', ->
        )

        # Wire GET requests
        @routeHandler.getRoutes.forEach((route) =>
          socket.on(route, (payload, ack) =>
            # Must always give a ack function from client
            return if not ack?
              
            # Payload object must never be undefined
            payload = {} if not payload?
            
            # Prepare standard arguments matching http
            req = payload
            res =
              send: ack
              render: -> ack('unavailable')
            
            @routeHandler.handleGet(route, req, res)
          )
        )
      )