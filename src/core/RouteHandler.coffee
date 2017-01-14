class RouteHandler

  constructor: (@name) ->
    @getRoutes  = []
    @postRoutes = []
    @bus        = require('EventBus').get(@name)

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
      console.log(error)
      return

  handleRequest: (route, req, res) ->
    
    if route
      @bus.emit(route, req, res)
      .then((response)->
        response = "OK" if not response?
        res.send(response)
      )
      .catch((e) ->
        res.error(e)
      )
      
    else
      @bus.emit(route, req, res)


Registry = require('registry')
module.exports = new Registry(RouteHandler)
