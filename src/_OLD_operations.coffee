Promise = require('bluebird')
util    = require('util')
http    = require('http')
https   = require('https')
cuid    = require('cuid')
request = require('request')
logger  = require('./logger')

WeaverCommons  = require('weaver-commons-js')
RedisBuffer    = require('./redis-buffer')

# This is the main entry point of any new socket connection.
module.exports =

  class Operations
    @payloadCount: 1
    @neo4j_service_ip
    @neo4j_service_port

    constructor: (@database, @connector, @opts) ->
      @neo4j_service_ip = @opts.weaverServiceIp
      @neo4j_service_port = @opts.weaverServicePort

    logPayload: (action, payload) ->

    create: (payload, opts) ->
      
      proms = []
      try
        proms.push(
            @connector.createIndividual(payload)
        )
        Promise.all(proms)
      catch error
        Promise.reject('error during create call: ' + error)


    createDict: (payload) ->
      
      proms = []
      try
        proms.push(
          @database.createDict(payload, 'lol')
        )
        Promise.all(proms)
      catch error
        Promise.reject('error during create call for REDIS: ' + error)
        
    readDict: (id) ->
      proms = []
      try
        proms.push(
          @database.readDict(id)
        )
        Promise.all(proms)
      catch error
        Promise.reject('error reading from REDIS ' + error )

    read: (payload, opts) ->
      opts = {} if not opts?

      # payload = new WeaverCommons.read.Entity(payload)
      
      proms = []

      # if payload.isValid()
      proms.push(
        @connector.readIndividual(payload.id, payload.opts.eagerness)
      )
      Promise.all(proms)

    bulkNodes: (payload) ->
      proms = []

      # if payload.isValid()
      proms.push(
        @connector.bulkNodes(payload)
      )
      Promise.all(proms)

    bulkRelations: (payload) ->
      proms = []

      # if payload.isValid()
      proms.push(
        @connector.bulkRelations(payload)
      )
      Promise.all(proms)
    
    update: (payload, opts) ->
      
      proms = []
      try
        proms.push(
          @connector.updateValueProperty(payload)
        )
        Promise.all(proms)
      catch error
        Promise.reject('error during create call: ' + error)

    updateAttributeLink: (payload, opts) ->
      opts = {} if not opts?

      payload = new WeaverCommons.update.AttributeLink(payload)
      return Promise.reject('update attribute link call not valid') if not payload.isValid()

      try

        @logPayload('update', payload) if not opts.ignoreLog

        proms = []

        if opts.ignoreConnector
          return @database.update(payload, opts)

        proms.push(@database.update(payload, opts))

        if payload.source.type is '$VALUE_PROPERTY' and payload.key is 'object'
          proms.push(
            @connector.updateValueProperty(payload)
          )

        Promise.all(proms)

      catch error
        Promise.reject('error during update call: '+error)



    updateEntityLink: (payload, opts) ->
      opts = {} if not opts?

      payload = new WeaverCommons.update.EntityLink(payload)
      return Promise.reject('update entity link call not valid') if not payload.isValid()

      try

        @logPayload('update', payload) if not opts.ignoreLog

        proms = []

        if opts.ignoreConnector
          return @database.link(payload, opts)

        proms.push(@database.link(payload, opts))

        if payload.source.type is '$INDIVIDUAL_PROPERTY' and payload.key is 'object'
          proms.push(
            @connector.updateIndividualProperty(payload)
          )

        Promise.all(proms)

      catch error
        Promise.reject('error during update entity link call: '+error)


    # renamed from delete
    destroyAttribute: (payload, opts) ->
      opts = {} if not opts?

      payload = new WeaverCommons.destroyAttribute.Entity(payload)
      return Promise.reject('destroy attribute call not valid') if not payload.isValid()

      try

        @logPayload('destroyAttribute', payload) if not opts.ignoreLog

        proms = []

        proms.push(@database.destroyAttribute(payload, opts))

        Promise.all(proms)

      catch error
        Promise.reject('error during destroy attribute call: '+error)


    # renamed from destroy
    destroyEntity: (payload) ->
      try
        proms = []
        proms.push(
          @connector.deleteObject(payload)
        )
        Promise.all(proms)
      catch error
        Promise.reject('error during destroy entity call: '+error)

    link: (payload) ->
      proms = []
      try
        proms.push(
          @connector.createIndividualProperty(payload)
        )
        Promise.all(proms)
      catch error
        Promise.reject('error during link call: ' + error)


    unlink: (payload) ->
      
      proms = []
      try
        proms.push(
          @connector.deleteRelation(payload)
        )
        Promise.all(proms)
      catch error
        Promise.reject('error during unlink call: ' + error)
        

    nativeQuery: (payload) ->

      payload = new WeaverCommons.nativeQuery.Query(payload)
      return Promise.reject('native query call not valid') if not payload.isValid()

      try

        @connector.query().then((query) ->
          result = query.nativeQuery(payload)        # todo: accept this object in connector
          result
        )

      catch error
        Promise.reject('error during native query call: '+error)

    queryFromView: (payload) ->

      payload = new WeaverCommons.queryFromView.View(payload)
      return Promise.reject('query from view call not valid') if not payload.isValid()

      try

        # Retrieve the view object
        @read({id: payload.id, opts: {eagerness: -1}}).then(

          (readResponse) =>
            view = new WeaverCommons.read.response.View(readResponse)

            filters = view.getFilters()
            promise = @queryFromFilters(filters)
            return promise

          (error) ->
            Promise.reject('error during query from view call: '+error)
        )

      catch error
        Promise.reject('error during query from view call: '+error)



    queryFromFilters: (filters) ->
      filters = JSON.parse(filters) if typeof filters is 'string'
      viewProvider = @

      @connector.query().then((query) ->
        query.selectIndividuals(filters, viewProvider).then((result) ->
          result
        )
      )

    wipe: ->
      Promise.all([@connector.wipe(), @database.wipe()])


    dump: ->
      payloads = []
      @database.redis.lrange('payloads', 0, -1).bind(@).each((payloadId) ->
        @database.redis.hgetall(payloadId).then((payload) ->
          payload.id = payloadId
          payload.payload = JSON.parse(payload.payload)
          payloads.push(payload)
        )
      ).then(->
        Promise.resolve(JSON.stringify(payloads))
      )

    bootstrapFromUrl: (url) ->

      new Promise((resolve, reject) =>

        logArray = ''

        processResponse = (res) =>

          if not res.statusCode is 200
            reject('wrong status code: '+res.statusCode)

          res.on('data', (data)=>
            logArray += data
          )
          res.on('end', ()=>
            @bootstrapFromJson(logArray).then(
              () ->
                resolve()
              (error) ->
                reject(error)
            )
          )

        if url.substr(0,5) is 'https'
          https.get(url, processResponse)
        else
          http.get(url, processResponse)

      )


    bootstrapFromJson: (logArray) ->
      console.log("Payload " + Operations.payloadCount)
      Operations.payloadCount++

      connectorImport = @connector.bulkInsert(logArray)

      buffer = new RedisBuffer(@database.host)
      redisImport = new Promise((resolve, reject) =>

        if typeof logArray is 'string'

          try
            logArray = JSON.parse(logArray)
            console.log("Processing payload size " + logArray.length)
          catch error
            logger.error('error', 'json contained error: '+error)
            #logger.error('error', logArray)
            reject(error)

        actions = {
          'create': @create
          'update': @update
          'destroyAttribute': @destroyAttribute
          'destroyEntity': @destroyEntity
          'link' : @link
          'unlink' : @unlink
        }

        limit = 1000
        processBatch = (arr) =>
          if arr.length <= limit
            batch = arr
            tail = []
          else
            batch = arr[0...limit]
            tail = arr[limit..]

          Promise.each(batch, (record) =>
            if actions[record.action]?
              actions[record.action].bind(@)(record.payload, {ignoreLog: true, ignoreConnector: true, buffer})
            else
              logger.error('unsupported action in bootstrap: '+record.action)
          ).then(

            ()->
              if tail.length > 0
                processBatch(tail)
              else
                resolve()

            (error)->
              reject(error)

          )

        processBatch(logArray)
      )

      # Run
      connectorImport
      .then(->
        redisImport
      ).then(->
        buffer.execute()
      )
