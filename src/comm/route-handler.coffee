class RouteHandler

  constructor: (@name) ->
    @getRoutes  = []
    @postRoutes = []
    @bus        = require('event-bus').get(@name)

  GET: (route) ->
    @getRoutes.push(route)
    
  POST: (route) ->
    @postRoutes.push(route)
    
  handleGet: (route, req, res) ->
    @bus.emit(route, req, res)


Registry = require('registry')
module.exports = new Registry(RouteHandler)