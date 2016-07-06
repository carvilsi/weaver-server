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
      if not payload.isValid()
        throw new Error('create call not valid')

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


    read: (payload) ->

      payload = new WeaverCommons.read.Entity(payload)
      throw new Error('read call not valid') if not payload.isValid()

      @database.read(payload).then((result) ->   
        logger.log('debug', result)
        if result?
          Promise.resolve(result)
        else
          Promise.reject('entity not found, request payload: '+payload)
      )

      # todo in the future see if the cache was invalidated



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
      throw new Error('update call not valid') if not payload.isValid()

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



    updateEntityLink: (payload) ->

      payload = new WeaverCommons.update.EnityLink(payload)
      throw new Error('update call not valid') if not payload.isValid()

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


    # renamed from delete
    destroyAttribute: (payload) ->

      payload = new WeaverCommons.destroyAttribute.Entity(payload)
      throw new Error('destroyAttribute call not valid') if not payload.isValid()

      @logPayload('destroyAttribute', payload)

      proms = []

      proms.push(@database.destroyAttribute(payload))

      Promise.all(proms)


    # renamed from destroy
    destroyEntity: (payload) ->

      payload = new WeaverCommons.destroyEntity.Entity(payload)
      throw new Error('destroyEntity call not valid') if not payload.isValid()

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



    link: (payload) ->

      payload = new WeaverCommons.link.Link(payload)
      throw new Error('link call not valid') if not payload.isValid()

      @logPayload('link', payload)

      

      @database.link(payload)



    unlink: (payload) ->

      payload = new WeaverCommons.unlink.Link(payload)
      throw new Error('unlink call not valid') if not payload.isValid()

      @logPayload('unlink', payload)

      @database.unlink(payload)



    nativeQuery: (payload) ->

      payload = new WeaverCommons.nativeQuery.Query(payload)
      throw new Error('nativeQuery call not valid') if not payload.isValid()

      @connector.query().then((query) ->
        result = query.nativeQuery(payload)        # todo: accept this object in connector
        query.conn.close()
        result
      )

    queryFromView: (payload) ->

      payload = new WeaverCommons.queryFromView.View(payload)
      throw new Error('queryfromView call not valid') if not payload.isValid()

      # Retrieve the view object
      @read({ id: payload.id, opts: { eagerness: -1 } }).then((view) =>
        
        # view might not exist, or have no filters
        if not view? or 
           not view._RELATIONS? or 
           not view._RELATIONS.filters? or 
           not view._RELATIONS.filters._RELATIONS?
          throw new Error('the view object does not contain the required fields')
          return []
          
        filtersMap = view._RELATIONS.filters._RELATIONS
        filters = []
        for filter_id, filter of filtersMap


          conditions = []
          for cond_id, condition of filter._RELATIONS.conditions._RELATIONS


            # todo extremely ugly
            if condition._ATTRIBUTES.conditiontype is 'string'
              conditions.push({
                operation:     condition._ATTRIBUTES.operation
                value:         condition._ATTRIBUTES.value
                conditiontype: condition._ATTRIBUTES.conditiontype
              })


            # todo extremely ugly
            else if condition._ATTRIBUTES.conditiontype is 'individual'
              conditions.push({
                operation:     condition._ATTRIBUTES.operation
                individual:    condition._ATTRIBUTES.individual
                conditiontype: condition._ATTRIBUTES.conditiontype
              })


            # todo extremely ugly
            else if condition._ATTRIBUTES.conditiontype is 'view' 
              conditions.push({
                operation:     condition._ATTRIBUTES.operation
                view:          condition._ATTRIBUTES.view
                conditiontype: condition._ATTRIBUTES.conditiontype
              })


            # todo extremely ugly
            else
              throw new Error('unsupported condition type')



          filter = {
            label: filter._ATTRIBUTES.label
            predicate: filter._ATTRIBUTES.predicate
            celltype: filter._ATTRIBUTES.celltype
            conditions: conditions
          }


          filters.push(filter)
        promise = @queryFromFilters(filters)
        return promise
      )


    queryFromFilters: (filters) ->
      filters = JSON.parse(filters) if typeof filters is 'string'

      @connector.query().then((query) ->
        result = query.selectIndividuals(filters)
        query.conn.close()
        result
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


