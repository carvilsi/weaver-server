Promise = require('bluebird')
Redis   = require('ioredis')

logger    = require('./logger')

# Append type
isNumber  = (a) -> Object.prototype.toString.call(a) is '[object Number]'
isBoolean = (a) -> Object.prototype.toString.call(a) is '[object Boolean]'

defaultReadOptions = (opts) ->
  opts = {} if not opts?
  opts.eagerness = 1 if not opts.eagerness?
  opts
  
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
      
      deferred.promise
      
    create: (payload) ->
      
      logger.log('info', payload)

      for key, val of payload.attributes
        payload.attributes[key] = encode(val)
        
      # Example: user, session, project, model
      type = payload.type 
      type = '$ROOT' if not type?
      
      # ID
      id = payload.id
      
      # Data
      data = payload.attributes
      data = {} if not data?
      
      # Save type to @redis set
      @redis.sadd(type, id)
      
      # Append type to data
      data.type = type

      if data and Object.keys(data).length isnt 0
        @redis.hmset(id, data)




      # do a link for each relations field
      if payload.relations?
        for key, value of payload.relations       # todo unlink

          # add key to object as dependencies
          @redis.sadd(id + ':_LINKS', key)

          # save link
          @redis.set(id + ':' + key, value)

      Promise.resolve() # todo reject

      # TODO: fire onCreated 

    read: (payload) ->

      # Assume eagerness = 1
      
      # Prevention of circular references blowing up the recursion chain
      visited = []
      
      self = @
      read = (id, eagerness) ->
        object = {}
        visited.push(id)

        # Get properties
        self.redis.hgetall(id).then((properties) ->
          for key,val of properties
            properties[key] = decode(val)

          object._ATTRIBUTES = properties
          
          # Save meta information
          object._META = {fetched: false, type: object._ATTRIBUTES.type, id}
          
          # Remove type from object
          delete object._ATTRIBUTES.type
          
        ).then(->
          # Stop condition
          if eagerness isnt 0
  
            # Set fetched tag to true
            object._META.fetched = true
            
            # Get links
            self.redis.smembers(id + ':_LINKS').each((link) ->
              self.redis.get(id + ':' + link).then((linkId) ->
                
                # Init if not set
                object._RELATIONS = {} if not object._RELATIONS?
                
                if visited.indexOf(linkId) is -1
                  read(linkId, eagerness - 1).then((result) ->
                    object._RELATIONS[link] = result
                  )
                else
                  object._RELATIONS[link] = {'_REF': linkId}
              )
            )         
        ).then(->
           object
        )


      # ID
      id   = payload.id
      opts = payload.opts
      opts = defaultReadOptions(opts)
      
      read(id, opts.eagerness)
      
          
    update: (payload) ->

      if not payload? or
         not payload.source? or
         not payload.source.id? or
         not payload.source.type? or
         not payload.attribute? or
         not payload.target? or
         not payload.target.value? or
         not payload.target.datatype?
        Promise.reject('payload for update does not contain all fields: '+JSON.stringify(payload))

      # ID
      id = payload.source.id 
      
      # Value
      attribute = payload.attribute      
      
      # Value
      value = payload.target.value

      if value?
        @redis.hset(id, attribute, encode(value))
      else
        @redis.hdel(id, attribute)

      Promise.resolve() # todo reject
      
      # TODO: fire onUpdated 
  

    link: (payload) ->
      
      if not payload? or
         not payload.source? or
         not payload.source.id? or
         not payload.key? or
         not payload.target? or
         not payload.target.id?
        Promise.reject('payload for link does not contain all fields: '+JSON.stringify(payload))
  
      # ID
      id = payload.source.id

      # users or projects
      key = payload.key
      
      # target object to add
      target = payload.target.id

      # add key to object as dependencies
      @redis.sadd(id + ':_LINKS', key)

      # save link
      @redis.set(id + ':' + key, target)

      Promise.resolve()

      # TODO: fire onLinked
  
  
    unlink: (payload) ->
      # ID
      id = payload.id

      # users or projects
      key = payload.key

      # add key to object as dependencies
      @redis.srem(id + ':_LINKS', key)

      # delete link
      @redis.del(id + ':' + key)

      Promise.resolve() # todo reject

      # TODO: fire onUnlinked
  
    # Delete key
    destroyAttribute: (payload) ->
      # ID
      id = payload.id

      # Attribute
      attribute = payload.attribute

      # Delete
      @redis.hdel(id, attribute)

      Promise.resolve() # todo reject


    # Destroy object
    destroyEntity: (payload) ->
      # ID
      id = payload.id

      # Delete key
      @redis.del(id)

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
