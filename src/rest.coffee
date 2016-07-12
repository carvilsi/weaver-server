Promise = require('bluebird')

logger    = require('./logger')

# This is the main entry point of any new socket connection.
module.exports =
  
  class Routes
    constructor: (@operations) ->

    wire: (app) ->
      
      # CREATE
      app.get('/rest/create', (req, res) =>

        payload = JSON.parse(req.query.payload)

        logger.log('debug', 'create event on rest, with payload:')
        logger.log('debug', payload)

        if not res?
          logger.log('error', 'no response')
          throw new Error('no response')   
          
          
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

        logger.log('debug', 'create/bulk event on rest, with payload:')
        logger.log('debug', payload)

        if not res?
          logger.log('error', 'no response')
          throw new Error('no response')


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

        logger.log('debug', 'read event on rest, with payload:')
        logger.log('debug', payload)

        if not res?
          logger.log('error', 'no response')
          throw new Error('no response')


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

        logger.log('debug', 'update event on rest, with payload:')
        logger.log('debug', payload)

        if not res?
          logger.log('error', 'no response')
          throw new Error('no response')


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

        logger.log('debug', 'remove event on rest, with payload:')
        logger.log('debug', payload)

        if not res?
          logger.log('error', 'no response')
          throw new Error('no response')


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

        logger.log('debug', 'link event on rest, with payload:')
        logger.log('debug', payload)

        if not res?
          logger.log('error', 'no response')
          throw new Error('no response')


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

        logger.log('debug', 'unlink event on rest, with payload:')
        logger.log('debug', payload)

        if not res?
          logger.log('error', 'no response')
          throw new Error('no response')


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

        logger.log('debug', 'destroy event on rest, with payload:')
        logger.log('debug', payload)

        if not res?
          logger.log('error', 'no response')
          throw new Error('no response')


        @operations.destroyEntity(payload).then(

          (result) ->
            res.status(200).send(result)

          (error) ->
            res.status(503).send(error)
        )
      )


      # POPULATE
      app.get('/rest/nativeQuery', (req, res) =>

        payload = JSON.parse(req.query.payload)

        logger.log('debug', 'nativeQuery event on rest, with payload:')
        logger.log('debug', payload)

        if not res?
          logger.log('error', 'no response')
          throw new Error('no response')


        @operations.nativeQuery(payload).then(

          (result) ->
            res.status(200).send(result)

          (error) ->
            logger.log('error', error)
            res.status(503).send(error)
        )
      )


      # POPULATE
      app.get('/rest/queryFromView', (req, res) =>

        payload = JSON.parse(req.query.payload)

        logger.log('debug', 'queryFromView event on rest, with payload:')
        logger.log('debug', payload)

        if not res?
          logger.log('error', 'no response')
          throw new Error('no response')


        @operations.queryFromView(payload).then(

          (result) ->
            res.status(200).send(result)

          (error) ->
            logger.log('error', error)
            res.status(503).send(error)
        )
      )


      # POPULATE
      app.get('/rest/queryFromFilters', (req, res) =>

        payload = JSON.parse(req.query.payload)

        logger.log('debug', 'queryFromFilters event on rest, with payload:')
        logger.log('debug', payload)

        if not res?
          logger.log('error', 'no response')
          throw new Error('no response')


        @operations.queryFromFilters(payload).then(

          (result) ->
            res.status(200).send(result)

          (error) ->
            res.status(503).send(error)
        )
      )


      # WIPE
      app.get('/rest/wipe', (req, res) =>



        logger.log('debug', 'wipe event on rest')


        if not res?
          logger.log('error', 'no response')
          throw new Error('no response')



        @operations.wipe().then(

          (result) ->
            res.status(200).send(result)

          (error) ->
            res.status(503).send(error)
        )
      )




      # DUMP
      app.get('/rest/dump', (req, res) =>



        logger.log('debug', 'dump event on rest')


        if not res?
          logger.log('error', 'no response')
          throw new Error('no response')



        @operations.dump().then(

          (result) ->
            res.status(200).send(result)

          (error) ->
            res.status(503).send(error)
        )
      )

      # BOOTSTRAP
      app.get('/rest/bootstrapFromJson', (req, res) =>

        payload = req.query.payload

        logger.log('debug', 'bootstrapFromJson event on rest, with payload:')
        logger.log('debug', payload)

        if not res?
          logger.log('error', 'no response')
          throw new Error('no response')


        @operations.bootstrapFromJson(payload).then(

          (result) ->
            res.status(200).send(result)

          (error) ->
            res.status(503).send(error)
        )
      )

      # BOOTSTRAP
      app.get('/rest/bootstrapFromUrl', (req, res) =>

        payload = req.query.payload

        logger.log('debug', 'bootstrapFromUrl event on rest, with payload:')
        logger.log('debug', payload)

        if not res?
          logger.log('error', 'no response')
          throw new Error('no response')


        @operations.bootstrapFromUrl(payload).then(

          (result) ->
            res.status(200).send(result)

          (error) ->
            res.status(503).send(error)
        )
      )

      # VERSION
      app.get('/rest/version', (req, res) =>

        if not res?
          logger.log('error', 'no response')
          throw new Error('no response')

        pjson = require('../package.json')
        server_version =    pjson.version
#        commons_version =             pjson.dependencies["weaver-commons-js"]

        res.status(200).send(server_version)
      )