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

    io = socketIO(http,{pingTimeout : 1200000})
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
          socket.on(route, @handleEvent(route, routeHandler).bind(@)) # Receive plain data (backward compatibility)
          ss(socket).on(route, @handleStream(route, routeHandler).bind(@)) #Receive streams
        )
      )
    )

  handleRoute: (routeHandler, route, req, ack) ->

    req.payload.serverStart = Date.now()

    res =
      success: (data) ->
        ack(data)
      fail: (error) ->
        ack(error)

    routeHandler.handleRequest(route, req, res)

  handleStream: (route, routeHandler) -> (payload, ack) ->
    # Must always give a ack function from client
    return if not ack?

    req = { payload }

    @handleRoute(routeHandler, route, req, ack)

  handleEvent: (route, routeHandler) -> (payload, ack) ->
    # Must always give a ack function from client
    return if not ack?

    try
      req = { payload: JSON.parse(payload or "{}") }
    catch error
      ack("Invalid json payload")
      return

    @handleRoute(routeHandler, route, req, ack)
