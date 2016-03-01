Promise = require('bluebird')

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

redis = null

# This is the main entry point of any new socket connection.
# Define a route function that will take a message signature and construct a route for
# that signature using the controller function
console.log('weaverrr')
module.exports =
  redis: (url) ->
    if url?
      redis = new require('ioredis')(url)
    else
      redis = new require('ioredis')()

  wire: (socket) ->

    # CREATE
    socket.on('create', (payload, ack) ->
      for key, val of payload.data
        payload.data[key] = encode(val)
        
      # Example: user, session, project, model
      type = payload.type 
      
      # ID
      id = payload.id
      
      # Data
      data = payload.data
            
      # Save type to redis set
      redis.sadd(type, id)
      
      # Append type to data
      data.type = type

      if data and Object.keys(data).length isnt 0
        redis.hmset(id, data)

      socket.broadcast.emit(type + ':created', payload.id)
      ack('0')
    )
    
    
    # READ
    socket.on('read', (payload, ack) ->

      # Assume eagerness = 1
      
      # Prevention of circular references blowing up the recursion chain
      visited = []
      
      read = (id, eagerness) ->
        object = {}
        visited.push(id)

        # Get properties
        redis.hgetall(id).then((properties) ->
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
            redis.smembers(id + ':_LINKS').each((link) ->
              redis.get(id + ':' + link).then((linkId) ->
                
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
      
      read(id, opts.eagerness).then(ack)
    )
        
    
    # UPDATE
    socket.on('update', (payload, ack) ->

      # ID
      id = payload.id 
      
      # Value
      attribute = payload.attribute      
      
      # Value
      value = payload.value

      if value?
        redis.hset(id, attribute, encode(value))
      else
        redis.hdel(id, attribute)

      socket.broadcast.emit(payload.id + ':updated', payload)
      ack(0)
    )   

    
    # LINK
    socket.on('link', (payload, ack) ->

      # ID
      id = payload.id

      # users or projects
      key = payload.key
      
      # target object to add
      target = payload.target

      # add key to object as dependencies
      redis.sadd(id + ':_LINKS', key)

      # save link
      redis.set(id + ':' + key, target)

      socket.broadcast.emit(payload.id + ':linked', payload)
      ack(0)
    )


    # UNLINK
    socket.on('unlink', (payload, ack) ->

      # ID
      id = payload.id

      # users or projects
      key = payload.key

      # add key to object as dependencies
      redis.srem(id + ':_LINKS', key)

      # save link
      redis.del(id + ':' + key)

      socket.broadcast.emit(payload.id + ':unlinked', payload)
      ack(0)
    )


    # DELETE
    socket.on('delete', (payload, ack) ->

      # ID
      id = payload.id

      # Find type
      redis.hget(id, 'type')
      .then((type) ->
    
      ).then(->
        socket.broadcast.emit(payload.id + ':deleted')
        ack(0)
      )
    )