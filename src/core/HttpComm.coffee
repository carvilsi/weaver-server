  Promise      = require('bluebird')
  Weaver       = require('weaver-sdk')
  Error        = Weaver.LegacyError
  WeaverError  = Weaver.Error
  Busboy       = require('busboy')

  module.exports =
  class HTTP
    constructor: (@routes) ->

    # Transforms application.version to /application/version
    transform: (route) ->
      '/' + route.replace('.', '/')

    #Will either resolve multipart or json
    _resolvePayload: (req) ->
      new Promise((resolve, reject) ->
        if req.headers['content-type']? and req.headers['content-type'].indexOf('multipart/form-data') isnt -1
          payload = {}
          busboy = new Busboy({headers: req.headers})
          busboy.on('field', (fieldname, value) ->
            payload[fieldname] = value
          )
          busboy.on('file', (fieldname, file) ->
            return file.resume() if fieldname isnt 'file'
            payload[fieldname] = file
            resolve(payload)
          )
          req.pipe(busboy)
        else
          resolve(req.body)
      )


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
            @_resolvePayload(req).then((payload) =>
              req.payload = payload

              res.success = (data) ->
                res.status(200).send(data)

              res.fail = (error) ->
                res.status(503).send(error)

              routeHandler.handleRequest(route, req, res)
            ).catch((error) =>
              res.status(400).send(Error(WeaverError.INVALID_JSON, "Invalid json: #{error}"))
            )
          )
        )
      )
