logger = require('logger')

class RouteHandler

  constructor: (@bus) ->
    @getRoutes  = []
    @postRoutes = []

  GET: (route) ->
    @getRoutes.push(route)

  POST: (route) ->
    @postRoutes.push(route)

  allRoutes: ->
    @getRoutes.concat(@postRoutes)

  handleRequest: (route, req, res) ->
    # Init payload on empty
    req.payload = {} if not req.payload?

    # Adding authToken when it's provided on the headers
    if !req.payload.authToken? and req.headers? and req.headers['authtoken']?
      req.payload.authToken = req.headers['authtoken']

    logger.code.silly "Request: #{route}, payload: #{JSON.stringify(req.payload)}"

    @bus.emit(route, req).then((data)->
      logger.code.silly "Request: #{route}, payload: #{JSON.stringify(req.payload)}, 200 data: #{JSON.stringify(data)}"
      res.success(data or "200")
    )
    .catch((error) ->
      logger.code.silly "Request: #{route}, payload: #{JSON.stringify(req.payload)}, err: #{JSON.stringify(error)}"
      res.fail(error)
    )

module.exports = RouteHandler
