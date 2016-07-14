Promise = require('bluebird')
util = require('util')
http = require('http')
https = require('https')
cuid = require('cuid')

WeaverCommons    = require('weaver-commons-js')


logger    = require('./logger')

# This is the main entry point of any new socket connection.
module.exports =

  class Operations
    constructor: (@database, @connector, @opts) ->




    logPayload: (action, payload) ->

      @database.redis.incr('payloadIndex').then((payloadIndex) =>

        # Add payload ID to payloads set
        payloadId = 'payload:' + payloadIndex + ':' + cuid()
        @database.redis.rpush('payloads', payloadId)

        # Save payload as map
        @database.redis.hmset(payloadId, {timestamp: new Date().getTime(), action: action, payload: JSON.stringify(payload)})
      )





    create: (payload) ->

      payload = new WeaverCommons.create.Entity(payload)
      return Promise.reject('create call not valid') if not payload.isValid()

      try

        @logPayload('create', payload)

        proms = []

        proms.push(@database.create(payload))

        if payload.type is '$INDIVIDUAL'

          individual = new WeaverCommons.create.Individual(payload)

          if individual.isValid()
            proms.push(
              @connector.transaction().then((trx)->
                trx.createIndividual(individual).then(=>
                  trx.commit()
                  trx.conn.close()
                )
              )
            )

          else
            return Promise.reject('This payload does not content a valid $INDIVIDUAL object')

        if payload.type is '$INDIVIDUAL_PROPERTY'
          individualProperty = new WeaverCommons.create.IndividualProperty(payload)

          if individualProperty.isValid()
            proms.push(
              @connector.transaction().then((trx)->
                trx.createIndividualProperty(individualProperty).then(=>
                  trx.commit()
                  trx.conn.close()
                )
              )
            )

          else
            return Promise.reject('This payload does not content a valid $INDIVIDUAL_PROPERTY object')

        if payload.type is '$VALUE_PROPERTY'
          valueProperty = new WeaverCommons.create.ValueProperty(payload)

          if valueProperty.isValid()
            proms.push(
              @connector.transaction().then((trx)->
                trx.createValueProperty(valueProperty).then(=>
                  trx.commit()
                  trx.conn.close()
                )
              )
            )

          else
            return Promise.reject('This payload does not content a valid $VALUE_PROPERTY object')

        Promise.all(proms)

      catch error
        Promise.reject('error during create call: '+error)


    read: (payload) ->

      payload = new WeaverCommons.read.Entity(payload)
      return Promise.reject('read call not valid') if not payload.isValid()

      try

        @database.read(payload).then((result) ->
          logger.log('debug', result)
          if result?
            Promise.resolve(result)
          else
            Promise.reject('entity not found, request payload: '+payload)
        )

        # todo in the future see if the cache was invalidated

      catch error
        Promise.reject('error during read call: '+error)



    # deprecated, please use updateAttributeLink or updateEntityLink
    update: (payload) ->

      payload = JSON.parse(payload) if typeof payload is 'string'

      # pointing to a value
      if payload.target? and payload.target.value?
        @updateAttributeLink(payload)

        # pointing to an individual
      else if payload.target? and payload.target.id?
        @updateEntityLink(payload)

      else
        return Promise.reject('update called not for value or target')







    updateAttributeLink: (payload) ->

      payload = new WeaverCommons.update.AttributeLink(payload)
      return Promise.reject('update attribute link call not valid') if not payload.isValid()

      try

        @logPayload('update', payload)

        proms = []

        if payload.source.type is '$VALUE_PROPERTY' and payload.key is 'object'
          proms.push(
            @connector.transaction().then((trx)->
              trx.updateValueProperty(payload).then(=>
                trx.commit()
                trx.conn.close()
              )
            )
          )

        proms.push(@database.update(payload))

        Promise.all(proms)

      catch error
        Promise.reject('error during update call: '+error)



    updateEntityLink: (payload) ->

      payload = new WeaverCommons.update.EntityLink(payload)
      return Promise.reject('update entity link call not valid') if not payload.isValid()

      try

        @logPayload('update', payload)

        proms = []

        if payload.source.type is '$INDIVIDUAL_PROPERTY' and payload.key is 'object'
          proms.push(
            @connector.transaction().then((trx)->
              trx.updateIndividualProperty(payload).then(=>
                trx.commit()
                trx.conn.close()
              )
            )
          )

        proms.push(@database.link(payload))

        Promise.all(proms)

      catch error
        Promise.reject('error during update entity link call: '+error)


    # renamed from delete
    destroyAttribute: (payload) ->

      payload = new WeaverCommons.destroyAttribute.Entity(payload)
      return Promise.reject('destroy attribute call not valid') if not payload.isValid()

      try

        @logPayload('destroyAttribute', payload)

        proms = []

        proms.push(@database.destroyAttribute(payload))

        Promise.all(proms)

      catch error
        Promise.reject('error during destroy attribute call: '+error)


    # renamed from destroy
    destroyEntity: (payload) ->

      payload = new WeaverCommons.destroyEntity.Entity(payload)
      return Promise.reject('destroy entity call not valid') if not payload.isValid()

      try

        @logPayload('destroyEntity', payload)

        proms = []

        proms.push(@database.destroyEntity(payload))


        if payload.type is '$INDIVIDUAL' or payload.type is '$INDIVIDUAL_PROPERTY' or payload.type is '$VALUE_PROPERTY'
          proms.push(
            @connector.transaction().then((trx)->
              trx.deleteObject(payload).then(=>
                trx.commit()
                trx.conn.close()
              )
            )
          )

        Promise.all(proms)

      catch error
        Promise.reject('error during destroy entity call: '+error)



    link: (payload) ->

      payload = new WeaverCommons.link.Link(payload)
      return Promise.reject('link call not valid') if not payload.isValid()

      try

        @logPayload('link', payload)

        @database.link(payload)

      catch error
        Promise.reject('error during link call: '+error)



    unlink: (payload) ->

      payload = new WeaverCommons.unlink.Link(payload)
      return Promise.reject('unlink call not valid') if not payload.isValid()

      try

        @logPayload('unlink', payload)

        @database.unlink(payload)

      catch error
        Promise.reject('error during unlink call: '+error)



    nativeQuery: (payload) ->

      payload = new WeaverCommons.nativeQuery.Query(payload)
      return Promise.reject('native query call not valid') if not payload.isValid()

      try

        @connector.query().then((query) ->
          result = query.nativeQuery(payload)        # todo: accept this object in connector
          query.conn.close()
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
          query.conn.close()
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

      deferred = Promise.defer()
      logArray = ''

      processResponse = (res) =>

        if not res.statusCode is 200
          deferred.reject()

        res.on('data', (data)=>
          logArray += data
        )
        res.on('end', ()=>
          @bootstrapFromJson(logArray).then(->
            deferred.resolve()
          )
        )

      if url.substr(0,5) is 'https'
        https.get(url, processResponse)
      else
        http.get(url, processResponse)
      
      deferred.promise


    bootstrapFromJson: (stringLogArray) ->

      try 
        logArray = JSON.parse(stringLogArray)
      catch error
        logger.log('info', 'json contained error: '+error)
        return Promise.reject(error)

      actions = {
        'create': @create
        'update': @update
        'destroyAttribute': @destroyAttribute
        'destroyEntity': @destroyEntity
        'link' : @link
        'unlink' : @unlink
      }

      Promise.each(logArray, (record) =>
        if actions[record.action]?
          actions[record.action].bind(@)(record.payload)
      )


