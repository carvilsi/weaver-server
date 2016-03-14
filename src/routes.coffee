Promise = require('bluebird')

# This is the main entry point of any new socket connection.
module.exports =
  
  class Routes
    constructor: (@database) ->

    wire: (socket) ->
      
      socket.on('create', (payload, ack) ->
        @database.create(payload)
        
        socket.broadcast.emit(payload.type + ':created', payload.id)
        ack(0)
      )
      
      socket.on('read', (payload, ack) ->
        @database.read(payload).then(ack)
      )
      
      socket.on('update', (payload, ack) ->
        @database.update(payload).then(ack)

        socket.broadcast.emit(payload.id + ':updated', payload)
        ack(0)
      )
      
      socket.on('link', (payload, ack) ->
        @database.link(payload).then(ack)

        socket.broadcast.emit(payload.id + ':linked', payload)
        ack(0)
      )
      
      socket.on('unlink', (payload, ack) ->
        @database.unlink(payload).then(ack)

        socket.broadcast.emit(payload.id + ':unlinked', payload)
        ack(0)
      )
      
      socket.on('delete', (payload, ack) ->
        @database.delete(payload).then(ack)
      )