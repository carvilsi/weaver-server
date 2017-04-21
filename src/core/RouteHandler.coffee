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

    @bus.emit(route, req).then((data)->
      res.success(data or "200")
    )
    .catch((error) ->
      res.fail(error)
    )

module.exports = RouteHandler
