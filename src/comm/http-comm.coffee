Promise = require('bluebird')

module.exports =
class HTTP 
  constructor: (@routeHandler) ->
    
  # Transforms application.version to /application/version
  transform: (route) ->
    '/' + route.replace('.', '/')
    
  wire: (app) ->
    
    # Wire GET requests
    @routeHandler.getRoutes.forEach((route) =>
      app.get(@transform(route), (req, res) =>
        @routeHandler.handleGet(route, req, res)
      )
    )