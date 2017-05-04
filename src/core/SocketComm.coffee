Promise  = require('bluebird')
socketIO = require('socket.io')
logger   = require('logger')

SDKVersionChecker = require('SDKVersionChecker')

module.exports =
class Socket
  constructor: (@routes) ->
    @versionChecker = new SDKVersionChecker()

  wire: (http) ->

    io = socketIO(http)
    io.use((socket, next) =>
      if not @versionChecker.checkSDKVersion(socket.handshake.query.sdkVersion)
        next(new Error("Invalid SDK Version, should be #{@versionChecker.serverVersion} minimum"))
      else
        next()
    )

    io.on('connection', (socket, next) =>
      # Error handler
      socket.on('error',  (err) ->
        logger.config.log('error', err.stack)
      )

      # Disconnect
      socket.on('disconnect', ->
      )

      # Wire GET and POST requests
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
