Promise = require('bluebird')

module.exports =
class HTTP 
  constructor: (@routeHandler) ->
    
  # Transforms application.version to /application/version
  transform: (route) ->
    '/' + route.replace('.', '/')

  wire: (app) ->
     # Wire GET requests
     @routeHandler.allRoutes().forEach((route) =>
       app.get(@transform(route), (req, res) =>

         req.payload = req.query['payload']
         req.payload = "{}" if not req.payload?

         res.ok    = -> res.status(200).send()
         res.error = (error) -> res.status(503).send(error)
         @routeHandler.handleRequest(route, req, res)
       )
     )
