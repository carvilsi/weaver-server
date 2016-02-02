Promise = require('bluebird')
redis = new require('ioredis')()

module.exports =
  class DefaultEntity

    constructor: (@id) ->

    getEntityIdentifier: ->
      console.log('Error: Entity identifier not set in entity')

    getIdIdentifier: ->
      @getEntityIdentifier() + '_id'

    getCollectionIdentifier: ->
      @getEntityIdentifier() + 's'

    getDependencyIdentifiers: ->
      {}

    getId: ->
      @id

    nextId: ->
      redis.incr(@getIdIdentifier())

    create: (object) ->
      # Id may have already been given in object
      if object? and object.id?
        @id = object.id
        delete object.id
        @store(object)
      else
        # TODO: Not being used at the moment, for token generation it IS!
        @nextId().bind(@).then((id) ->
          @id = id
          @store(object)
        )

    store: (object) ->
      Promise.all([
        @addToCollection()
        @save(object)
      ])

    read: (key) ->
      redis.hget(@getEntityIdentifier()+ ':' +@id, key)

    addToCollection: ->
      redis.sadd(@getCollectionIdentifier(), @id)

    save: (object) ->
      # Return if undefined or empty
      if not object? or Object.keys(object).length == 0
        return

      redis.hmset(@getEntityIdentifier()+ ':' +@id, object)

    update: (attribute, value) ->
      if value?
        redis.hset(@getEntityIdentifier()+ ':' +@id, attribute, value)
      else
        redis.hdel(@getEntityIdentifier()+ ':' +@id, attribute)

    addDependency: (key, id) ->
      redis.sadd(@getEntityIdentifier()+ ':' +@id+ ':' +key, id)

    removeDependency: (key, id) ->
      redis.srem(@getEntityIdentifier()+ ':' +@id+ ':' +key, id)

    delete: ->
      redis.srem(@getCollectionIdentifier(), @id).bind(@).then(->
        redis.del(@getEntityIdentifier()+ ':' +@id)
      )

    getProperties: ->
      redis.hgetall(@getEntityIdentifier()+ ':' +@id).bind(@).then((object)->
        object.id = @id
        object
      )

    getObjects: ->
      objects = {}
      promises = []
      for dependency, Type of @getDependencyIdentifiers()
        promises.push(@getEntities(objects, dependency, Type))

      Promise.all(promises).then(->
        objects
      )

    getEntities: (object, key, Type) ->
      object[key] = []

      redis.smembers(@getEntityIdentifier()+ ':' +@id+ ':' + key).each((entityId) ->
        new Type(entityId).getObject().then((entity) ->
          object[key].push(entity)
        )
      ).then(-> return object[key])

    getObject: ->
      @getProperties().bind(@).then((object) ->
        @getObjects().bind(@).then((objects) ->

          object[key] = value for key, value of objects
        ).then(-> return object)
      )