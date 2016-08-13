Promise = require('bluebird')
Redis   = require('ioredis')
fs      = require('fs')
tmp     = require('tmp')
exec = require('child_process').exec;

module.exports =
  
  class RedisBuffer
    
    constructor: ->
      @log = ""
      
    sadd: (arg0, arg1) ->
      @log += @toRedisProtocol("SADD", [arg0, arg1])
    
    hmset: (arg0, arg1) ->
      args = [arg0]
      for key, value of arg1
        args.push(key)
        args.push(value)

      @log += @toRedisProtocol("HMSET", args)

    hset: (arg0, arg1, arg2) ->
      @log += @toRedisProtocol("HSET", [arg0, arg1, arg2])

    hdel: (arg0, arg1) ->
      @log += @toRedisProtocol("HDEL", [arg0, arg1])

    set: (arg0, arg1) ->
      @log += @toRedisProtocol("SET", [arg0, arg1])

    srem: (arg0, arg1) ->
      @log += @toRedisProtocol("SREM", [arg0, arg1])

    del: (arg0) ->
      @log += @toRedisProtocol("DEL", [arg0])
      
      
    toRedisProtocol: (key, args) ->
      lengthInUtf8Bytes = (str) ->
        # Matches only the 10.. bytes that are non-initial characters in a multi-byte sequence.
        m = encodeURIComponent(str).match(/%[89ABab]/g);
        if m?
          str.length + m.length
        else
          str.length


      clean = (value) ->
        # trim, remove linebreaks, and remove non breaking spaces
        value.trim().replace(/(\r\n|\n|\r)/gm,"").replace(/\s/g,' ');
        
      command  = "*" + (args.length + 1) + "\r\n"
      command += "$" + key.length + "\r\n"
      command +=  key + "\r\n"
      
      for arg in args      
        command += "$" + lengthInUtf8Bytes(clean(arg)) + "\r\n"
        command += clean(arg) + "\r\n"
        
      return command

    execute: ->
      deferred = Promise.defer()

      tmp.file((err, path, fd, cleanupCallback) =>
        
        if err
          console.log(path)
          deferred.reject(err)


        fs.writeFile(path, @log, (err) ->
          if (err)
            deferred.reject(error)
          else
            cmd = """cat #{path} | redis-cli --pipe -h docker"""

            exec(cmd, (error, stdout, stderr) ->
              console.log(stdout)
  
              if(error)
                deferred.reject(error)
              else
                cleanupCallback()
                deferred.resolve()
          )
        )
      )
      
      return deferred.promise