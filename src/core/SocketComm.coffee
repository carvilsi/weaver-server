Promise  = require('bluebird')
socketIO = require('socket.io')
logger   = require('logger')
PubSub   = require('pubsub-js')
ss       = require('socket.io-stream')

ClientVersionChecker = require('ClientVersionChecker')

module.exports =
class Socket
  constructor: (@routes) ->
    @versionChecker = new ClientVersionChecker()

  wire: (http) ->

    io = socketIO(http)
    io.use((socket, next) =>
      if not @versionChecker.isValidSDKVersion(socket.handshake.query.sdkVersion)
        next(new Error("Invalid SDK Version '#{socket.handshake.query.sdkVersion}'"))
      else if not @versionChecker.serverSatisfies(socket.handshake.query.requiredServerVersion)
        next(new Error("Server version #{@versionChecker.serverVersion} does not satisfy '#{socket.handshake.query.requiredServerVersion}'"))
      else
      @versionChecker.connectorSatisfies(socket.handshake.query.requiredConnectorVersion).then((checkResult) =>
        if !checkResult
          next(new Error("Connector version #{@versionChecker.lastKnownConnectorVersion} does not satisfy '#{socket.handshake.query.requiredConnectorVersion}'"))
        else
          next()
      )
    )

    PubSub.subscribe("socket.shout", (msg, data) ->
      io.emit("socket.shout", data)
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
          ss(socket).on(route, (payload, ack) =>
            # Must always give a ack function from client
            return if not ack?

            try
              if payload.type isnt "STREAM"
                req = { payload: JSON.parse(payload or "{}") }
              else
                req = { payload }
              req.payload.serverStart = Date.now()
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
