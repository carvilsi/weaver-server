ERROR = require('error')

class RouteHandler

  constructor: (@name) ->
    @getRoutes  = []
    @postRoutes = []
    @bus        = require('event-bus').get(@name)

  GET: (route) ->
    @getRoutes.push(route)
    
  POST: (route) ->
    @postRoutes.push(route)
    
  allRoutes: ->
    @getRoutes.concat(@postRoutes)
    
  handleGet: (route, req, res) ->
    
    # Test payload
    try
      req.payload = JSON.parse(req.payload)
    catch error
      res.send(ERROR('invalid json payload', req.payload))
      return
    
    @bus.emit(route, req, res)


Registry = require('registry')
module.exports = new Registry(RouteHandler)