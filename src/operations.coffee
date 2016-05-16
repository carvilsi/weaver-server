Promise = require('bluebird')
util = require('util')
WeaverConnector    = require('weaver-connector')
Individual         = WeaverConnector.model.Individual
IndividualProperty = WeaverConnector.model.IndividualProperty
ValueProperty      = WeaverConnector.model.ValueProperty
Filter             = WeaverConnector.model.Filter

# This is the main entry point of any new socket connection.
module.exports =

  class Operations
    constructor: (@database, @connector, @opts) ->

    createBulk: (payloads) ->
      proms = (@create(payload) for payload in payloads.creates)
      Promise.all(proms)

    create: (payload) ->
      console.log('op create')
      console.log(payload)

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
      console.log('op read')
      console.log(payload)

      @database.read(payload).then((object) ->

        console.log(util.inspect(object, {showHidden: false, depth: null}))

        object
      )


#      # lookup the entity
#      @database.read(payload).then((signature) ->
#        if signature.type is '$INDIVIDUAL'
#
#             @connector.query().then((query)->
#              query.selectIndividual(payload.id).then((result) ->
#                console.log('querying virtuoso for an object')
#                console.log(result)
#
#                # add redis stuff to result
#
#                return result
#              )
#            )
#
#        else if signature.type is '$INDIVIDUAL_PROPERTY'
#
#            @connector.query().then((query)->
#              query.selectIndividualProperty(payload.id).then((result) ->
#                console.log('querying virtuoso for an individual property')
#                console.log(result)
#
#                # add redis stuff to result
#
#                return result
#
#
#              )
#            )
#
#        else if signature.type is '$VALUE_PROPERTY'
#
#            @connector.query().then((query)->
#              query.selectValueProperty(payload.id).then((result) ->
#                console.log('querying virtuoso for a value property')
#                console.log(result)
#
#                # add redis stuff to result
#
#                return result
#              )
#            )
#
#      )






    update: (payload) ->

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

      proms = []

      proms.push(@database.destroyAttribute(payload))




      Promise.all(proms)


    # renamed from destroy
    destroyEntity: (payload) ->

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

      @database.link(payload)



    unlink: (payload) ->

      @database.unlink(payload)


    populateFromFilters: (filters) ->

      @connector.query().then((query) ->
        query.selectIndividuals(filters)
      )


    populate: (payload) ->

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

      if not @opts['wipeEnabled']? or not @opts['wipeEnabled']
        throw new Error('wiping disabled')
      console.log('will wipe everything')