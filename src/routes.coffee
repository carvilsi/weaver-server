Promise = require('bluebird')

# This is the main entry point of any new socket connection.
module.exports =
  
  class Routes
    constructor: (@operations) ->

    wire: (socket) ->
      
      self = @

      # Create
      socket.on('create', (payload, ack) ->

        self.operations.create(payload).then(

          (result) ->
            socket.broadcast.emit(payload.type + ':created', payload.id)
            ack(result)

          (error) ->
            ack(-1)

        )
      )

      # Create Bulk
      socket.on('create/bulk', (payload, ack) ->

        self.operations.createBulk(payload).then(

          (result) ->
            ack(result)

          (error) ->
            ack(-1)

        )
      )

      
      #
      socket.on('read', (payload, ack) ->
        self.operations.read(payload).then(

          (result) ->
            ack(result)

          (error) ->
            ack(-1)

        )
      )

      #
      socket.on('update', (payload, ack) ->
        self.operations.update(payload).then(

          (result) ->
            socket.broadcast.emit(payload.id + ':updated', payload)
            ack(result)

          (error) ->
            ack(-1)
        )
      )

      # Removes a key from an entity
      socket.on('remove', (payload, ack) ->
        self.operations.destroyAttribute(payload).then(

          (result) ->
            socket.broadcast.emit(payload.id + ':removed', payload)
            ack(result)

          (error) ->
            ack(-1)

        )
      )

      #
      socket.on('link', (payload, ack) ->
        self.operations.link(payload).then(

          (result) ->
            socket.broadcast.emit(payload.id + ':linked', payload)
            ack(result)

          (error) ->
            ack(-1)
        )
      )

      #
      socket.on('unlink', (payload, ack) ->
        self.operations.unlink(payload).then(

          (result) ->
            socket.broadcast.emit(payload.id + ':unlinked', payload)
            ack(result)

          (error) ->
            ack(-1)
        )
      )
      
      # Destroys entity
      socket.on('destroy', (payload, ack) ->
        self.operations.destroyEntity(payload).then(

          (result) ->
            socket.broadcast.emit(payload.id + ':destroyed', payload)
            ack(result)

          (error) ->
            ack(-1)
        )
      )

      # Populate
      socket.on('populate', (payload, ack) ->
        self.operations.populate(payload).then(

          (result) ->
            ack(result)

          (error) ->
            ack(-1)
        )
      )

      # Wipe
      socket.on('wipe', (payload, ack) ->
        self.operations.wipe().then(

          (result) ->
            ack(result)

          (error) ->
            ack(-1)
        )
      )

      # Dump
      socket.on('dump', (payload, ack) ->
        self.operations.dump().then(

          (result) ->
            ack(result)

          (error) ->
            ack(-1)
        )
      )

      # Bootstrap
      socket.on('bootstrap', (url, ack) ->
        self.operations.bootstrap(url).then(

          (result) ->
            ack(result)

          (error) ->
            ack(-1)
        )
      )