Promise = require('bluebird')
Redis   = require('ioredis')

logger    = require('./logger')
# Append type
isNumber  = (a) -> Object.prototype.toString.call(a) is '[object Number]'
isBoolean = (a) -> Object.prototype.toString.call(a) is '[object Boolean]'

encode = (val) ->
  if isNumber(val)
    val + '^^number'
  else if isBoolean(val)
    val + '^^boolean'
  else
    val

decode = (val) ->
  index = val.indexOf('^^')
  return val if index is -1

  type  = val.slice(index)
  value = val.slice(0, index)

  if type is '^^number'
    Number(value)
  else if type is '^^boolean'
    Boolean(value)
  else
    value


# This is the main entry point of any new socket connection.
# Define a route function that will take a message signature and construct a route for
# that signature using the controller function
module.exports =

  class Database

    constructor: (@port, @host) ->
      @redis = new Redis({@port, @host, lazyConnect: true, connectTimeout: 1500})

    connect: ->
      deferred = Promise.defer()
      @redis.connect((error) =>
        @connected = not error?
      
        if @connected
          deferred.resolve()
        else
          deferred.reject('Could not connect to Redis')
      )
      deferred.resolve()
      deferred.promise
      
    createDict: (payload) ->
      @redis.set(payload.id, JSON.stringify(payload.attributes))
    
    readDict: (payload) ->
      self = @
      self.redis.get(payload.id).then((res) ->
        if res
          payload.data = JSON.parse(res)
          Promise.resolve(payload)
        else
          Promise.reject('The value does not exits @REDIS')
      )

    update: (payload, opts) ->

      redis = if opts.buffer? then opts.buffer else @redis

      # ID
      id = payload.source.id

      # Value
      attribute = payload.key

      # Value
      value = payload.target.value

      if value?
        redis.hset(id, attribute, encode(value))
      else
        redis.hdel(id, attribute)

      Promise.resolve() # todo reject

      # TODO: fire onUpdated


    link: (payload, opts) ->

      redis = if opts.buffer? then opts.buffer else @redis

      # ID
      id = payload.source.id

      # users or projects
      key = payload.key

      # target object to add
      target = payload.target.id

      # add key to object as dependencies
      redis.sadd(id + ':_LINKS', key)

      # save link
      redis.set(id + ':' + key, target)

      Promise.resolve()

      # TODO: fire onLinked


    unlink: (payload, opts) ->

      redis = if opts.buffer? then opts.buffer else @redis

      # ID
      id = payload.id

      # users or projects
      key = payload.key

      # add key to object as dependencies
      redis.srem(id + ':_LINKS', key)

      # delete link
      redis.del(id + ':' + key)

      Promise.resolve() # todo reject

      # TODO: fire onUnlinked

    # Delete key
    destroyAttribute: (payload, opts) ->

      redis = if opts.buffer? then opts.buffer else @redis

      # ID
      id = payload.id

      # Attribute
      attribute = payload.attribute

      # Delete
      redis.hdel(id, attribute)

      Promise.resolve() # todo reject


    # Destroy object
    destroyEntity: (payload, opts) ->

      redis = if opts.buffer? then opts.buffer else @redis

      # ID
      id = payload.id

      # Delete key
      redis.del(id)

      Promise.resolve() # todo reject



    # TODO
    onUpdate: (id, callback) ->
      return

    # TODO
    onLinked: (id, callback) ->
      return

    # TODO
    onUnlinked: (id, callback) ->
      return

    # todo process the boolean this function returns
    wipe: ->
      throw Error('Redis not connected') if not @connected
      @redis.call('flushall')
