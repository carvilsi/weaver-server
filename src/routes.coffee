Promise = require('bluebird')

logger    = require('./logger')

# This is the main entry point of any new socket connection.
module.exports =

  class Routes
    constructor: (@operations, @opts) ->

    wire: (socket) ->

      # If no tokens are set, read and write are per default permitted
      socket.readPermitted  = not @opts['readToken']?
      socket.writePermitted = not @opts['writeToken']?

      noReadPermission = (socket, ack) ->
        if not socket.readPermitted
          ack('unauthorized to read operations')

        not socket.readPermitted

      noWritePermission = (socket, ack) ->
        if not socket.writePermitted
          ack('unauthorized to write operations')

        not socket.writePermitted

      socket.on('authenticate', (token, ack) =>
        if token is @opts['readToken']
          socket.readPermitted  = true
        else if token is @opts['writeToken']
          socket.readPermitted  = true
          socket.writePermitted = true

        ack({read: socket.readPermitted, write: socket.writePermitted})
      )

      socket.on('error',  (err) ->
        logger.log('error', err.stack)
      )

      self = @

      # Event
      socket.on('event', (payload, ack) ->

        logger.log('debug', 'event event on socket, with payload:')
        logger.log('debug', payload)


      )

      # Disconnect
      socket.on('disconnect', (payload, ack) ->

        logger.log('debug', 'disconnect event on socket, with payload:')
        logger.log('debug', payload)
      )

      # Create over Neo4j
      socket.on('create', (payload, ack) ->

        logger.log('debug', 'create event on socket, with payload:')
        logger.log('debug', payload)

        return if noWritePermission(socket, ack)

        if not ack?
          logger.log('error', 'no ack function')
          throw new Error('no ack function')

        self.operations.create(payload).then(

          (result) ->
            socket.broadcast.emit(payload.type + ':created', payload.id)
            ack(result[0])

          (error) ->
            logger.error('create call failed for payload with error: '+error)
            logger.error(payload)
            ack({code: 503, message: error, payload})

        )
      )
      
      # Create over Dict (REDIS)
      socket.on('createDict', (payload, ack) ->
        logger.log('debug','create object on REDIS')
        logger.log('debug', payload)
                
        return if noWritePermission(socket, ack)

        if not ack?
          logger.log('error', 'no ack function')
          throw new Error('no ack function')
          
        self.operations.createDict(payload).then(
        
          (result) ->
            socket.broadcast.emit(payload.id + ' :created', payload)
            ack(result)
          
          (error) ->
            logger.error('create call to REDIS failed for payload with error: ' + error)
            logger.error(payload)
            ack({code: 503, message: error, payload})
        )
      )
      
      socket.on('readDict', (id, ack) ->
        logger.log('debug', 'readDict event on socket')
        logger.log('debug', id)

        return if noWritePermission(socket, ack)

        if not ack?
          logger.log('error', 'no ack function')
          throw new Error('no ack function')
          
        self.operations.readDict(id).then(
          
          (result) ->
            socket.broadcast.emit(id + ' :read', result)
            ack(result)
            
          (error) ->
            logger.error('read call to REDIS failed for id with error: ' + error)
            logger.error(id)
            ack({code: 503, message: error, id})
            
        )
      )

      # Create Bulk
      socket.on('create/bulk', (payload, ack) ->

        logger.log('debug', 'create/bulk event on socket, with payload:')
        logger.log('debug', payload)

        return if noWritePermission(socket, ack)

        if not ack?
          logger.log('error', 'no ack function')
          throw new Error('no ack function')

        self.operations.createBulk(payload).then(

          (result) ->
            ack(result)

          (error) ->
            logger.error('create/bulk call failed for')
            logger.error(payload)
            ack({code: 503, message: error, payload})
        )
      )


      # reading over Neo4j
      socket.on('read', (payload, ack) ->

        logger.log('debug', 'read event on socket, with payload:')
        logger.log('debug', payload)

        return if noReadPermission(socket, ack)

        if not ack?
          logger.log('error', 'no ack function')
          throw new Error('no ack function')

        self.operations.read(payload).then(
          (result) ->
            ack(result)

          (error) ->
            # Check if its a read error
            if(error.code and error.message and error.payload?)
              ack(error)
            else
              errorObject = {code: 503, message: error, payload}
              logger.error('read call failed for payload ' + JSON.stringify(payload) + ' because of error: ' + error)
              ack(errorObject)
        )
      )

      #
      socket.on('update', (payload, ack) ->

        logger.log('debug', 'update event on socket, with payload:')
        logger.log('debug', payload)

        return if noWritePermission(socket, ack)

        if not ack?
          logger.log('error', 'no ack function')
          throw new Error('no ack function')

        self.operations.update(payload).then(

          (result) ->
            socket.broadcast.emit(payload.id + ':updated', payload)
            ack(result)

          (error) ->
            logger.error('update call failed for')
            logger.error(payload)
            ack({code: 503, message: error, payload})
        )
      )

      # Removes a key from an entity
      socket.on('remove', (payload, ack) ->

        logger.log('debug', 'remove event on socket, with payload:')
        logger.log('debug', payload)

        return if noWritePermission(socket, ack)

        if not ack?
          logger.log('error', 'no ack function')
          throw new Error('no ack function')

        self.operations.destroyAttribute(payload).then(

          (result) ->
            socket.broadcast.emit(payload.id + ':removed', payload)
            ack(result)

          (error) ->
            logger.error('remove call failed for')
            logger.error(payload)
            ack({code: 503, message: error, payload})

        )
      )

      #
      socket.on('link', (payload, ack) ->

        logger.log('debug', 'link event on socket, with payload:')
        logger.log('debug', payload)

        return if noWritePermission(socket, ack)

        if not ack?
          logger.log('error', 'no ack function')
          throw new Error('no ack function')

        self.operations.link(payload).then(

          (result) ->
            socket.broadcast.emit(payload.id + ':linked', payload)
            ack(result)

          (error) ->
            logger.error('link call failed for')
            logger.error(payload)
            ack({code: 503, message: error, payload})
        )
      )

      #
      socket.on('unlink', (payload, ack) ->

        logger.log('debug', 'unlink event on socket, with payload:')
        logger.log('debug', payload)

        return if noWritePermission(socket, ack)

        if not ack?
          logger.log('error', 'no ack function')
          throw new Error('no ack function')

        self.operations.unlink(payload).then(

          (result) ->
            socket.broadcast.emit(payload.id + ':unlinked', payload)
            ack(result)

          (error) ->
            logger.error('unlink call failed for')
            logger.error(payload)
            ack({code: 503, message: error, payload})
        )
      )

      # Destroys entity
      socket.on('destroy', (payload, ack) ->

        logger.log('debug', 'destroy event on socket, with payload:')
        logger.log('debug', payload)

        return if noWritePermission(socket, ack)

        if not ack?
          logger.log('error', 'no ack function')
          throw new Error('no ack function')

        self.operations.destroyEntity(payload).then(

          (result) ->
            socket.broadcast.emit(payload.id + ':destroyed', payload)
            ack(result)

          (error) ->
            logger.error('destroy call failed for')
            logger.error(payload)
            ack({code: 503, message: error, payload})
        )
      )

      # Populate
      socket.on('nativeQuery', (payload, ack) ->

        logger.log('debug', 'nativeQuery event on socket, with payload:')
        logger.log('debug', payload)

        return if noReadPermission(socket, ack)

        if not ack?
          logger.log('error', 'no ack function')
          throw new Error('no ack function')

        self.operations.nativeQuery(payload).then(

          (result) ->
            ack(result)

          (error) ->
            logger.error('nativeQuery call failed for')
            logger.error(payload)
            ack({code: 503, message: error, payload})
        )
      )

      # Populate
      socket.on('queryFromView', (payload, ack) ->

        logger.log('debug', 'queryFromView event on socket, with payload:')
        logger.log('debug', payload)

        return if noReadPermission(socket, ack)

        if not ack?
          logger.log('error', 'no ack function')
          throw new Error('no ack function')

        self.operations.queryFromView(payload).then(

          (result) ->
            ack(result)

          (error) ->
            logger.error('queryFromView call failed for')
            logger.error(payload)
            ack({code: 503, message: error, payload})
        )
      )

      # Populate
      socket.on('queryFromFilters', (payload, ack) ->

        logger.log('debug', 'queryFromFilters event on socket, with payload:')
        logger.log('debug', payload)

        return if noReadPermission(socket, ack)

        if not ack?
          logger.log('error', 'no ack function')
          throw new Error('no ack function')

        self.operations.queryFromFilters(payload).then(

          (result) ->
            ack(result)

          (error) ->
            logger.error('queryFromFilters call failed for')
            logger.error(payload)
            ack({code: 503, message: error, payload})
        )
      )

      # Wipe
      socket.on('wipe', (payload, ack) ->

        logger.log('debug', 'wipe event on socket')

        return if noWritePermission(socket, ack)

        if not ack?
          logger.log('error', 'no ack function')
          throw new Error('no ack function')

        self.operations.wipe().then(

          (result) ->
            ack(result)

          (error) ->
            logger.error('wipe call failed for')
            logger.error(payload)
            ack({code: 503, message: error, payload})
        )
      )

      # Dump
      socket.on('dump', (payload, ack) ->

        logger.log('debug', 'dump event on socket, with payload:')
        logger.log('debug', payload)

        return if noReadPermission(socket, ack)

        if not ack?
          logger.log('error', 'no ack function')
          throw new Error('no ack function')

        self.operations.dump().then(

          (result) ->
            ack(result)

          (error) ->
            logger.error('dump call failed for')
            logger.error(payload)
            ack({code: 503, message: error, payload})
        )
      )

      # Bootstrap
      socket.on('bootstrapFromJson', (payload, ack) ->

        logger.log('debug', 'bootstrapFromJson event on socket, with payload:')
        logger.log('debug', payload)

        return if noWritePermission(socket, ack)

        if not ack?
          logger.log('error', 'no ack function')
          throw new Error('no ack function')

        self.operations.bootstrapFromJson(payload).then(

          () ->
            ack('OK')

          (error) ->
            logger.error('bootstrapFromJson call failed: ' + error)
            ack({code: 503, message: error, payload})
        )
      )

      # Bootstrap
      socket.on('bootstrapFromUrl', (payload, ack) ->

        logger.log('debug', 'Bootstrap event on socket, with payload:')
        logger.log('debug', payload)

        return if noWritePermission(socket, ack)

        if not ack?
          logger.log('error', 'no ack function')
          throw new Error('no ack function')

        self.operations.bootstrapFromUrl(payload).then(

          () ->
            ack('OK')

          (error) ->
            logger.error('bootstrapFromUrl call failed for')
            logger.error(payload)
            ack({code: 503, message: error, payload})
        )
      )

      # Bootstrap
      socket.on('version', (payload, ack) ->

        pjson = require('../package.json')
        server_version =    pjson.version
#        commons_version =             pjson.dependencies["weaver-commons-js"]

        if not ack?
          logger.log('error', 'no ack function')
          throw new Error('no ack function')

        ack(server_version)

      )
