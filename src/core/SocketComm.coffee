Promise  = require('bluebird')
socketIO = require('socket.io')
logger   = require('logger')

module.exports =
class Socket
  constructor: (@routes) ->

  wire: (http) ->

    io = socketIO(http)
    io.on('connection', (socket) =>

      # Error handler
      socket.on('error',  (err) ->
        logger.config.log('error', err.stack)
      )

      # Disconnect
      socket.on('disconnect', ->
      )

      # Wire GET requests
      (handler for name, handler of @routes).forEach((routeHandler) =>
        routeHandler.allRoutes().forEach((route) =>
          socket.on(route, (payload, ack) =>
            # Must always give a ack function from client
            return if not ack?

            try
              req = { payload: JSON.parse(payload or "{}") }
            catch error
              ack("Invalid json payload")
              return

            res =
              success: (data) ->
                ack(data)
              fail: (error) ->
                ack(error)

            routeHandler.handleRequest(route, req, res)
          )
        )
      )
    )
