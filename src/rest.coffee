Promise = require('bluebird')

# This is the main entry point of any new socket connection.
module.exports =
  
  class Routes
    constructor: (@operations) ->

    wire: (app) ->
      
      # CREATE
      app.get('/rest/create', (req, res) =>

        payload = JSON.parse(req.query.payload)        
        @operations.create(payload).then(

          ->
            res.sendStatus(200)

          (error) ->
            res.status(503).send(error)
        )
      )      
      
      # CREATE BULK
      app.get('/rest/create/bulk', (req, res) =>

        payload = JSON.parse(req.query.payload)        
        @operations.createBulk(payload).then(

          ->
            res.sendStatus(200)

          (error) ->
            res.status(503).send(error)
        )
      )

      # READ
      app.get('/rest/read', (req, res) =>

        payload = JSON.parse(req.query.payload)
        @operations.read(payload).then(

          (result) ->
            res.status(200).send(result)

          (error) ->
            res.status(503).send(error)
        )
      )


      # UPDATE
      app.get('/rest/update', (req, res) =>

        payload = JSON.parse(req.query.payload)
        @operations.update(payload).then(

          (result) ->
            res.status(200).send(result)

          (error) ->
            res.status(503).send(error)
        )
      )

      # REMOVE
      app.get('/rest/remove', (req, res) =>

        payload = JSON.parse(req.query.payload)
        @operations.destroyAttribute(payload).then(

          (result) ->
            res.status(200).send(result)

          (error) ->
            res.status(503).send(error)
        )
      )
      
      # LINK
      app.get('/rest/link', (req, res) =>

        payload = JSON.parse(req.query.payload)
        @operations.link(payload).then(

          (result) ->
            res.status(200).send(result)

          (error) ->
            res.status(503).send(error)
        )
      )


      # UNLINK
      app.get('/rest/unlink', (req, res) =>

        payload = JSON.parse(req.query.payload)
        @operations.unlink(payload).then(

          (result) ->
            res.status(200).send(result)

          (error) ->
            res.status(503).send(error)
        )
      )


      # DESTROY
      app.get('/rest/destroy', (req, res) =>

        payload = JSON.parse(req.query.payload)
        @operations.destroyEntity(payload).then(

          (result) ->
            res.status(200).send(result)

          (error) ->
            res.status(503).send(error)
        )
      )


      # POPULATE
      app.get('/rest/populate', (req, res) =>

        payload = JSON.parse(req.query.payload)
        @operations.populate(payload).then(

          (result) ->
            res.status(200).send(result)

          (error) ->
            res.status(503).send(error)
        )
      )


      # WIPE
      app.get('/rest/wipe', (req, res) =>

        @operations.wipe().then(

          (result) ->
            res.status(200).send(result)

          (error) ->
            res.status(503).send(error)
        )
      )




      # DUMP
      app.get('/rest/dump', (req, res) =>

        @operations.dump().then(

          (result) ->
            res.status(200).send(result)

          (error) ->
            res.status(503).send(error)
        )
      )

      # BOOTSTRAP
      app.get('/rest/bootstrap', (req, res) =>

        url = req.query.payload
        @operations.bootstrap(url).then(

          (result) ->
            res.status(200).send(result)

          (error) ->
            res.status(503).send(error)
        )
      )