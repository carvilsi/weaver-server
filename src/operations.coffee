Promise = require('bluebird')

# This is the main entry point of any new socket connection.
module.exports =

  class Operations
    constructor: (@database, @connector) ->


    create: (payload) ->

      proms = []

      proms.push(@database.create(payload))


      if payload.type is '$OBJECT'
        proms.push(
          @connector.transaction().then((trx)->
            trx.createObject(payload)).then(=>
              trx.commit()
            )
        )

      if payload.type is '$PROPERTY'
        proms.push(
          @connector.transaction().then((trx)->
            trx.createProperty(payload)).then(=>
              trx.commit()
            )
        )

      Promise.all(proms)





    read: (payload) ->

      proms = []

      @database.read(payload)


      if payload.type is '$OBJECT'
        proms.push(
          @connector.transaction().then((trx)->
            trx.readObject(payload)).then(=>
            trx.commit()
          )
        )

      if payload.type is '$PROPERTY'
        proms.push(
          @connector.transaction().then((trx)->
            trx.readProperty(payload)).then(=>
            trx.commit()
          )
        )

        #todo merge result

      Promise.all(proms)



    update: (payload) ->

      proms = []

      proms.push(@database.update(payload))


      if payload.type is '$OBJECT'
        proms.push(
          @connector.transaction().then((trx)->
            trx.updateObject(payload)).then(=>
            trx.commit()
          )
        )

      if payload.type is '$PROPERTY'
        proms.push(
          @connector.transaction().then((trx)->
            trx.updateProperty(payload)).then(=>
            trx.commit()
          )
        )

      Promise.all(proms)



    delete: (payload) ->

      proms = []

      proms.push(@database.delete(payload))


      if payload.type is '$OBJECT'
        proms.push(
          @connector.transaction().then((trx)->
            trx.deleteObject(payload)).then(=>
            trx.commit()
          )
        )

      if payload.type is '$PROPERTY'
        proms.push(
          @connector.transaction().then((trx)->
            trx.deleteProperty(payload)).then(=>
            trx.commit()
          )
        )

      Promise.all(proms)



    link: (payload) ->

      proms = []

      proms.push(@database.link(payload))

      Promise.all(proms)



    unlink: (payload) ->

      proms = []

      proms.push(@database.unlink(payload))

      Promise.resolve(proms)



    destroy: (payload) ->

      proms = []

      proms.push(@database.destroy(payload))


      if payload.type is '$OBJECT'
        proms.push(
          @connector.transaction().then((trx)->
            trx.deleteObject(payload)).then(=>
            trx.commit()
          )
        )

      if payload.type is '$PROPERTY'
        proms.push(
          @connector.transaction().then((trx)->
            trx.deleteProperty(payload)).then(=>
            trx.commit()
          )
        )

      Promise.all(proms)