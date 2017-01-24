Promise     = require('bluebird')
Weaver       = require('weaver-sdk')
Error        = Weaver.LegacyError
WeaverError  = Weaver.Error

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

         req.payload = req.query['payload']
         req.payload = "{}" if not req.payload?

         try
           req.payload = JSON.parse(req.payload)
         catch error
           res.status(400).send(Error(WeaverError.INVALID_JSON, "Invalid json: #{error}"))
           return

         res.ok    = -> res.status(200).send()
         res.error = (error) -> res.status(503).send(error)
         @routeHandler.handleRequest(route, req, res)
       )
     )

     @routeHandler.postRoutes.forEach((route) =>
       app.post(@transform(route), (req, res) =>
         req.payload = req.body

         res.ok    = -> res.status(200).send()
         res.error = (error) -> res.status(503).send(error)
         @routeHandler.handleRequest(route, req, res)
       )
     )
