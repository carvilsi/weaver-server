module.exports =

  class DefaultCtrl
    constructor: (@identifier, @Type) ->

    getIdentifier: ->
      @identifier

    getType: ->
      @Type

    create: (payload, socket, ack) ->
      Type = @getType()
      instance = new Type()
      instance.create(payload)

    read: (payload, socket, ack) ->
      Type = @getType()
      new Type(payload.id).getObject().then(ack)

    add: (payload, socket) ->
      InstanceType = @getType()
      instance = new InstanceType(payload.id)
      instance.addDependency(payload.key, payload.objectId)

      Type = instance.getDependencyIdentifiers()[payload.key]
      new Type(payload.objectId).getObject().bind(@).then((object) ->
        socket.broadcast.emit(@getIdentifier()+ ':' +payload.id+ ':' +payload.key+ ':added', object)
      )

    remove: (payload, socket) ->
      Type = @getType()
      new Type(payload.id).removeDependency(payload.key, payload.objectId)
      socket.broadcast.emit(@getIdentifier()+ ':' +payload.id+ ':' +payload.key+ ':removed', payload.objectId)


    update: (payload, socket) ->
      Type = @getType()
      new Type(payload.id).update(payload.attribute, payload.value).bind(@).then( ->
        socket.broadcast.emit(@getIdentifier()+ ':updated:' +payload.id, payload)
      )


    delete: (payload, socket) ->
      Type = @getType()
      new Type(payload.id).delete().bind(@).then( ->
        socket.broadcast.emit(@getIdentifier()+ ':deleted:' +payload.id)
      )