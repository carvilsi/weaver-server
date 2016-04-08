Promise = require('bluebird')
Redis   = require('ioredis') 

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
    
    constructor: (@url, @redis) ->
      if @url?
        @redis = new Redis(@url)
      else
        @redis = new Redis()
        
    create: (payload) ->
      for key, val of payload.data
        payload.data[key] = encode(val)
        
      # Example: user, session, project, model
      type = payload.type 
      type = '$ROOT' if not type?
      
      # ID
      id = payload.id
      
      # Data
      data = payload.data
      data = {} if not data?
      
      # Save type to @redis set
      @redis.sadd(type, id)
      
      # Append type to data
      data.type = type

      if data and Object.keys(data).length isnt 0
        @redis.hmset(id, data)

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

          object = properties
          
          # Save meta information
          object._META = {fetched: false, type: object.type, id}
          
          # Remove type from object
          delete object.type
          
        ).then(->
          # Stop condition
          if eagerness isnt 0
  
            # Set fetched tag to true
            object._META.fetched = true
            
            # Get links
            self.redis.smembers(id + ':_LINKS').each((link) ->
              self.redis.get(id + ':' + link).then((linkId) ->
                
                if visited.indexOf(linkId) is -1
                  read(linkId, eagerness - 1).then((result) ->
                    object[link] = result
                  )
                else
                  object[link] = {'_REF': linkId}
              )
            )         
        ).then(-> object)


      # ID
      id   = payload.id
      opts = payload.opts
      opts = defaultReadOptions(opts)
      
      read(id, opts.eagerness)
      
          
    update: (payload) ->
      
      # ID
      id = payload.id 
      
      # Value
      attribute = payload.attribute      
      
      # Value
      value = payload.value

      if value?
        @redis.hset(id, attribute, encode(value))
      else
        @redis.hdel(id, attribute)

      Promise.resolve() # todo reject
      
      # TODO: fire onUpdated 
  
  

    link: (payload) ->
  
      # ID
      id = payload.id

      # users or projects
      key = payload.key
      
      # target object to add
      target = payload.target

      # add key to object as dependencies
      @redis.sadd(id + ':_LINKS', key)

      # save link
      @redis.set(id + ':' + key, target)

      Promise.resolve() # todo reject

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
    delete: (payload) ->
      # ID
      id = payload.id

      # Attribute
      attribute = payload.attribute

      # Delete
      @redis.hdel(id, attribute)

      Promise.resolve() # todo reject


    # Destroy object
    destroy: (payload) ->
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