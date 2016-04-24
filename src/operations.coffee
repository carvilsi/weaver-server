Promise = require('bluebird')

# This is the main entry point of any new socket connection.
module.exports =

  class Operations
    constructor: (@database, @connector) ->


    create: (payload) ->
      console.log('op create')
      console.log(payload)

      proms = []

      proms.push(@database.create(payload))


      if payload.type is '$OBJECT'
        proms.push(
          @connector.transaction().then((trx)->
            trx.createObject(payload)).then(=>
              trx.commit()
            )
        )

      if payload.type is '$OBJECT_PROPERTY'
        proms.push(
          @connector.transaction().then((trx)->
            trx.createProperty(payload)).then(=>
              trx.commit()
            )
        )

      if payload.type is '$VALUE_PROPERTY'
        proms.push(
          @connector.transaction().then((trx)->
            trx.createProperty(payload)).then(=>
              trx.commit()
            )
        )

      Promise.all(proms)





    read: (payload) ->
      console.log('op read')
      console.log(payload)

      proms = []

      result = @database.read(payload)
      proms.push(result)
#
#
#      if payload.type is '$OBJECT'
#        proms.push(
#          @connector.transaction().then((trx)->
#            trx.readObject(payload)).then(=>
#            trx.commit()
#          )
#        )
#
#      if payload.type is '$OBJECT_PROPERTY'
#        proms.push(
#          @connector.transaction().then((trx)->
#            trx.readProperty(payload)).then(=>
#            trx.commit()
#          )
#        )
#
#      if payload.type is '$VALUE_PROPERTY'
#        proms.push(
#          @connector.transaction().then((trx)->
#            trx.readProperty(payload)).then(=>
#            trx.commit()
#          )
#        )
#
#        #todo merge result
#
      Promise.all(proms).then(->
        result
      )



    update: (payload) ->
      console.log('op update')
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
      console.log('op deleteField')
      console.log(payload)

      proms = []

      proms.push(@database.destroyAttribute(payload))




      Promise.all(proms)


    # renamed from destroy
    destroyEntity: (payload) ->
      console.log('op deleteEntity')
      console.log(payload)

      proms = []

      proms.push(@database.destroyEntity(payload))


      if payload.type is '$OBJECT'
        proms.push(
          @connector.transaction().then((trx)->
            trx.deleteObject(payload)).then(=>
            trx.commit()
          )
        )

      if payload.type is '$OBJECT_PROPERTY'
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
      console.log('op link')
      console.log(payload)

      proms = []

      proms.push(@database.link(payload))

      if payload.source.type is '$COLLECTION' and payload.target.type is '$OBJECT_PROPERTY'
        proms.push(
          @connector.transaction().then((trx)->
            trx.linkProperty(payload)).then(=>
            trx.commit()
          )
        )

      if payload.source.type is '$COLLECTION' and payload.target.type is '$VALUE_PROPERTY'
        proms.push(
          @connector.transaction().then((trx)->
            trx.linkProperty(payload)).then(=>
            trx.commit()
          )
        )

      Promise.all(proms)



    unlink: (payload) ->
      console.log('op unlink')
      console.log(payload)

      proms = []

      proms.push(@database.unlink(payload))


      if payload.type is '$OBJECT'
        proms.push(
          @connector.transaction().then((trx)->
            trx.unlinkObject(payload)).then(=>
            trx.commit()
          )
        )

      if payload.type is '$OBJECT_PROPERTY'
        proms.push(
          @connector.transaction().then((trx)->
            trx.destroyProperty(payload)).then(=>
            trx.commit()
          )
        )

      if payload.type is '$VALUE_PROPERTY'
        proms.push(
          @connector.transaction().then((trx)->
            trx.destroyProperty(payload)).then(=>
            trx.commit()
          )
        )

      Promise.resolve(proms)


# TODO
    onUpdate: (id, callback) ->
      return

# TODO  
    onLinked: (id, callback) ->
      return

# TODO
    onUnlinked: (id, callback) ->
      return