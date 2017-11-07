Promise      = require('bluebird')
Weaver       = require('weaver-sdk')
Error        = Weaver.LegacyError
WeaverError  = Weaver.Error

module.exports =
class HTTP
  constructor: (@routes) ->

  # Transforms application.version to /application/version
  transform: (route) ->
    '/' + route.replace('.', '/')

  wire: (app) ->
    # Wire GET requests
    (handler for name, handler of @routes).forEach((routeHandler) =>
      routeHandler.getRoutes.forEach((route) =>
        app.get(@transform(route), (req, res) =>

          req.payload = req.query['payload']

          try
            req.payload = JSON.parse(req.payload or "{}")
          catch error
            res.status(400).send(Error(WeaverError.INVALID_JSON, "Invalid json: #{error}"))
            return

          res.success = (data) ->
            res.status(200).send(data)

           res.fail = (error) ->
             res.status(503).send(error)

           routeHandler.handleRequest(route, req, res)
        )
      )

      routeHandler.postRoutes.forEach((route) =>
        app.post(@transform(route), (req, res) =>
          req.payload = req.body

          res.success = (data) ->
            res.status(200).send(data)

          res.fail = (error) ->
            res.status(503).send(error)

          routeHandler.handleRequest(route, req, res)
        )
      )
    )
