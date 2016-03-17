Promise = require('bluebird')

# This is the main entry point of any new socket connection.
module.exports =
  
  class Routes
    constructor: (@database) ->

    wire: (socket) ->
      
      self = @
      socket.on('create', (payload, ack) ->
        self.database.create(payload)
        
        socket.broadcast.emit(payload.type + ':created', payload.id)
        ack(0)
      )
      
      socket.on('read', (payload, ack) ->
        self.database.read(payload).then(ack)
      )
      
      socket.on('update', (payload, ack) ->
        self.database.update(payload).then(ack)

        socket.broadcast.emit(payload.id + ':updated', payload)
        ack(0)
      )

      # Removes a key from an entity
      socket.on('remove', (payload, ack) ->
        self.database.remove(payload).then(ack)

        socket.broadcast.emit(payload.id + ':removed', payload)
        ack(0)
      )
      
      socket.on('link', (payload, ack) ->
        self.database.link(payload).then(ack)

        socket.broadcast.emit(payload.id + ':linked', payload)
        ack(0)
      )
      
      socket.on('unlink', (payload, ack) ->
        self.database.unlink(payload).then(ack)

        socket.broadcast.emit(payload.id + ':unlinked', payload)
        ack(0)
      )
      
      # Destroys entity
      socket.on('destroy', (payload, ack) ->
        self.database.destroy(payload).then(ack)
        
        socket.broadcast.emit(payload.id + ':destroyed', payload)
        ack(0)
      )