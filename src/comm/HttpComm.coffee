Promise = require('bluebird')

module.exports =
class HTTP 
  constructor: (@routeHandler) ->
    
  # Transforms application.version to /application/version
  transform: (route) ->
    '/' + route.replace('.', '/')

  _wire: (routes, wire) ->
    routes.forEach((route) =>
      wire(@transform(route), (req, res) =>
        
        req.payload = req.query['payload']
        req.payload = "{}" if not req.payload?
        
        res.ok    = -> res.status(200).send()
        res.error = (error) -> res.status(503).send(error)
        @routeHandler.handleRequest(route, req, res)
      )
    )
    
  wire: (app) ->
    @_wire(@routeHandler.getRoutes, app.get)
    @_wire(@routeHandler.postRoutes, app.post)
