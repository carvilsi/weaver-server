Promise = require('bluebird')
util = require('util')
http = require('http')
https = require('https')
cuid = require('cuid')

require('colors')

WeaverCommons  = require('weaver-commons-js')
RedisBuffer    = require('./redis-buffer')


logger    = require('./logger')

# This is the main entry point of any new socket connection.
module.exports =

  class Operations
    @payloadCount: 1

    constructor: (@database, @connector, @opts) ->




    logPayload: (action, payload) ->

      console.log action .green
      console.log payload .green

      # @database.redis.incr('payloadIndex').then((payloadIndex) =>
      #
      #   # Add payload ID to payloads set
      #   payloadId = 'payload:' + payloadIndex + ':' + cuid()
      #   @database.redis.rpush('payloads', payloadId)
      #
      #   # Save payload as map
      #   @database.redis.hmset(payloadId, {timestamp: new Date().getTime(), action: action, payload: JSON.stringify(payload)})
      # )





    create: (payload, opts) ->
      opts = {} if not opts?

      payload = new WeaverCommons.create.Entity(payload)
      return Promise.reject('create call not valid') if not payload.isValid()

      try

        console.log 'ignoreLog: ' + opts.ignoreLog + ''.green

        @logPayload('create', payload) if not opts.ignoreLog

        proms = []

        # proms.push(@database.create(payload, opts))

        if payload.type is '$INDIVIDUAL'

          individual = new WeaverCommons.create.Individual(payload)

          if individual.isValid()
            proms.push(
              @connector.createIndividual(individual)
            )

          else
            return Promise.reject('This payload does not contain a valid $INDIVIDUAL object')

        if payload.type is '$INDIVIDUAL_PROPERTY'
          individualProperty = new WeaverCommons.create.IndividualProperty(payload)

          if individualProperty.isValid()
            proms.push(
              @connector.createIndividualProperty(individualProperty)
            )

          else
            return Promise.reject('This payload does not contain a valid $INDIVIDUAL_PROPERTY object')

        else if payload.type is '$VALUE_PROPERTY'
          valueProperty = new WeaverCommons.create.ValueProperty(payload)

          if valueProperty.isValid()
            proms.push(
              @connector.createValueProperty(valueProperty)
            )

          else
            return Promise.reject('This payload does not contain a valid $VALUE_PROPERTY object')

        else if payload.type is '$PREDICATE'
          predicate = new WeaverCommons.create.Predicate(payload)

          if predicate.isValid()
              proms.push(
               @connector.createIndividual(predicate)
              )

          else
            return Promise.reject('This payload does not contain a valid $PREDICATE object')

        Promise.all(proms)

      catch error
        Promise.reject('error during create call: '+error)


    read: (payload, opts) ->

      console.log '=^^=|_'.green

      console.log payload

      opts = {} if not opts?

      payload = new WeaverCommons.read.Entity(payload)

      # console.log payload
      #
      # return Promise.reject('read call not valid') if not payload.isValid()
      #
      # Promise.resolve(payload)

      proms = []

      if payload.isValid()
        proms.push(
          @connector.readIndividual(payload.id, payload.opts.eagerness)
        )

      Promise.all(proms)

      # We need to check if this ID exists in Redis. If it doesnt, then it must exists in the Graph database.
      # We do not want redis any more....
      # TODO: Maybe we can put here something like a cache......

      # try
      #
      #   @database.read(payload).then((result) ->
      #     logger.log('debug', result)
      #     if result?
      #       Promise.resolve(result)
      #     else
      #
      #       # Not found in Redis, try the database
      #
      #       Promise.reject('entity not found, request payload: '+payload)
      #   )
      # catch error
      #   Promise.reject('error during read call: '+error)



    # deprecated, please use updateAttributeLink or updateEntityLink
    update: (payload, opts) ->
      opts = {} if not opts?

      payload = JSON.parse(payload) if typeof payload is 'string'

      # pointing to a value
      if payload.target? and payload.target.value?
        @updateAttributeLink(payload, opts)

        # pointing to an individual
      else if payload.target? and payload.target.id?
        @updateEntityLink(payload, opts)

      else
        return Promise.reject('update called not for value or target')







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
    destroyEntity: (payload, opts) ->
      opts = {} if not opts?

      payload = new WeaverCommons.destroyEntity.Entity(payload)
      return Promise.reject('destroy entity call not valid') if not payload.isValid()

      try

        @logPayload('destroyEntity', payload) if not opts.ignoreLog

        proms = []

        if opts.ignoreConnector
          return @database.destroyEntity(payload, opts)

        proms.push(@database.destroyEntity(payload, opts))


        if payload.type is '$INDIVIDUAL' or payload.type is '$INDIVIDUAL_PROPERTY' or payload.type is '$VALUE_PROPERTY'
          proms.push(
            @connector.deleteObject(payload)
          )

        Promise.all(proms)

      catch error
        Promise.reject('error during destroy entity call: '+error)



    link: (payload, opts) ->
      opts = {} if not opts?

      payload = new WeaverCommons.link.Link(payload)
      return Promise.reject('link call not valid') if not payload.isValid()

      try

        @logPayload('link', payload) if not opts.ignoreLog

        @database.link(payload, opts)

      catch error
        Promise.reject('error during link call: '+error)



    unlink: (payload, opts) ->
      opts = {} if not opts?

      payload = new WeaverCommons.unlink.Link(payload)
      return Promise.reject('unlink call not valid') if not payload.isValid()

      try

        @logPayload('unlink', payload) if not opts.ignoreLog

        @database.unlink(payload, opts)

      catch error
        Promise.reject('error during unlink call: '+error)



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





    # TODO
    onUpdate: (id, callback) ->
      return

    # TODO
    onLinked: (id, callback) ->
      return

    # TODO
    onUnlinked: (id, callback) ->
      return


    wipe: ->

      if not @opts? or not @opts['wipeEnabled']? or not @opts['wipeEnabled']
        throw new Error('wiping disabled')

      proms = []
      # todo: cleanup state / re-init ????
      proms.push(@connector.wipe())
      proms.push(@database.wipe())

      Promise.all(proms)


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
