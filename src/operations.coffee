Promise = require('bluebird')
util = require('util')
http = require('http')
cuid = require('cuid')

WeaverConnector    = require('weaver-connector')
Individual         = WeaverConnector.model.Individual
IndividualProperty = WeaverConnector.model.IndividualProperty
ValueProperty      = WeaverConnector.model.ValueProperty
Filter             = WeaverConnector.model.Filter

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

      @logPayload('create', payload)

      proms = []


      if payload.type is '$INDIVIDUAL'
        proms.push(
          @connector.transaction().then((trx)->
            trx.createIndividual(new Individual(payload.id)).then(=>
              trx.commit()
            )
          )
        )

      if payload.type is '$INDIVIDUAL_PROPERTY'

        return Promise.reject('field missing for creating $INDIVIDUAL_PROPERTY') if not payload.attributes?
        return Promise.reject('field missing for creating $INDIVIDUAL_PROPERTY') if not payload.attributes.predicate?
        return Promise.reject('field missing for creating $INDIVIDUAL_PROPERTY') if not payload.relations?
        return Promise.reject('field missing for creating $INDIVIDUAL_PROPERTY') if not payload.relations.subject?
        return Promise.reject('field missing for creating $INDIVIDUAL_PROPERTY') if not payload.relations.object?

        proms.push(
          @connector.transaction().then((trx)->
            trx.createIndividualProperty(new IndividualProperty(payload.id, payload.relations.subject, payload.attributes.predicate, payload.relations.object)).then(=>
              trx.commit()
            )
          )
        )

      if payload.type is '$VALUE_PROPERTY'

        return Promise.reject('field missing for creating $INDIVIDUAL_PROPERTY') if not payload.attributes?
        return Promise.reject('field missing for creating $INDIVIDUAL_PROPERTY') if not payload.attributes.predicate?
        return Promise.reject('field missing for creating $INDIVIDUAL_PROPERTY') if not payload.attributes.object?
        return Promise.reject('field missing for creating $INDIVIDUAL_PROPERTY') if not payload.relations?
        return Promise.reject('field missing for creating $INDIVIDUAL_PROPERTY') if not payload.relations.subject?

        proms.push(
          @connector.transaction().then((trx)->
            trx.createValueProperty(new ValueProperty(payload.id, payload.relations.subject, payload.attributes.predicate, payload.attributes.object)).then(=>
              trx.commit()
            )
          )
        )




      proms.push(@database.create(payload))

      Promise.all(proms)





    read: (payload) ->

      @database.read(payload).then((object) ->

        Promise.resolve(object)
      )

      # todo in the future see if the cache was invalidated









    update: (payload) ->

      @logPayload('update', payload)

      console.log(payload)

      proms = []

      proms.push(@database.update(payload))

      if false
        proms.push(
          @connector.transaction().then((trx)->
            trx.updateProperty(payload)).then(=>
            trx.commit()
          )
        )

      Promise.all(proms)


    # renamed from delete
    destroyAttribute: (payload) ->

      @logPayload('destroyAttribute', payload)

      proms = []

      proms.push(@database.destroyAttribute(payload))




      Promise.all(proms)


    # renamed from destroy
    destroyEntity: (payload) ->

      @logPayload('destroyEntity', payload)

      proms = []

      proms.push(@database.destroyEntity(payload))


      if payload.type is '$INDIVIDUAL'
        proms.push(
          @connector.transaction().then((trx)->
            trx.deleteObject(payload)).then(=>
            trx.commit()
          )
        )

      if payload.type is '$INDIVIDUAL_PROPERTY'
        proms.push(
          @connector.transaction().then((trx)->
            trx.deleteProperty(payload)).then(=>
            trx.commit()
          )
        )

      if payload.type is '$VALUE_PROPERTY'
        proms.push(
          @connector.transaction().then((trx)->
            trx.deleteProperty(payload)).then(=>
            trx.commit()
          )
        )

      Promise.all(proms)



    link: (payload) ->

      @logPayload('link', payload)

      @database.link(payload)



    unlink: (payload) ->

      @logPayload('unlink', payload)

      @database.unlink(payload)



    nativeQuery: (query) ->
      Promise.resolve({})

    queryFromView: (payload) ->

      @logPayload('populate', payload)

      # Retrieve the view object
      @read({ id: payload.id, opts: { eagerness: -1 } }).then((view) =>

        filtersMap = view._RELATIONS.filters._RELATIONS
        filters = []
        for filter_id, filter of filtersMap


          conditions = []
          for cond_id, condition of filter._RELATIONS.conditions._RELATIONS


            # todo extremely ugly
            if condition._ATTRIBUTES.conditiontype is 'string'
              conditions.push({
                operation: condition._ATTRIBUTES.operation
                value: condition._ATTRIBUTES.value
                conditiontype: condition._ATTRIBUTES.conditiontype
              })


            # todo extremely ugly
            else if condition._ATTRIBUTES.conditiontype is 'individual'
              conditions.push({
                operation: condition._ATTRIBUTES.operation
                individual: condition._RELATIONS.individual._META.id
                conditiontype: condition._ATTRIBUTES.conditiontype
              })


            # todo extremely ugly
            else if condition._ATTRIBUTES.conditiontype is 'view'
              conditions.push({
                operation: condition._ATTRIBUTES.operation
                view: condition._RELATIONS.view._META.id
                conditiontype: condition._ATTRIBUTES.conditiontype
              })


            # todo extremely ugly
            else
              thrown new Error('unsupported condition type')



          filter = {
            label: filter._ATTRIBUTES.label
            predicate: filter._ATTRIBUTES.predicate
            celltype: filter._ATTRIBUTES.celltype
            conditions: conditions
          }


          filters.push(filter)
        promise = @populateFromFilters(filters)
        return promise
      )


    queryFromFilters: (filters) ->

      @connector.query().then((query) ->
        query.selectIndividuals(filters)
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

    bootstrapFromUrl: (payload) ->

      logArray = ''

      http.get(payload.url, (res)=>

        if not res.statusCode is 200
          return Promise.reject()

        res.on('data', (data)=>
          logArray += data
        )
        res.on('end', ()=>
          return @bootstrapFromJson(logArray)
        )
      )


    bootstrapFromJson: (stringLogArray) ->

      logArray = JSON.parse(stringLogArray)

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


