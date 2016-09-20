Promise = require('bluebird')

module.exports =
  class Transaction

    @tx
    @java
    @graphdb
    @conn


    constructor: (@db) ->
      @java = @db.java
      @tx = @db.tx
      @graphdb = @db.graphdb
      @conn = @db.conn

    createIndividual: (individual) ->
      new Promise((resolve, reject) =>

        try
          # Importing Java ArrayList
          ArrayList = @java.import('java.util.ArrayList')

          propertyList = new ArrayList()
          relationList = new ArrayList()

          if not individual.id
            throw new Error('id is mandatory')

          @java.callMethodSync(@tx,'createIndividual',individual.id,propertyList,relationList)
          resolve()


        catch error
          reject(new Error('Error creating individual'))

      )

    createMultiple: (group) ->
      new Promise((resolve, reject) =>

        try
          # Importing Java ArrayList
          ArrayList = @java.import('java.util.ArrayList')

          for individual in group
            propertyList = new ArrayList()
            relationList = new ArrayList()

            for valueProperty in individual.valueProperties
              vp = @java.newInstanceSync('com.sysunite.weaver.connector.ValueProperty',
                  valueProperty.id, valueProperty.predicate, valueProperty.object)
              propertyList.addSync(vp)

            for relationProperty in individual.relationProperties
              rp = @java.newInstanceSync('com.sysunite.weaver.connector.RelationProperty',
                  relationProperty.id, relationProperty.predicate, relationProperty.subject)
              relationList.addSync(rp)

            @java.callMethodSync(@tx,'createIndividual',individual.id,propertyList,relationList)

          resolve()

        catch error
          reject(new Error('Error creating multiple'))

      )

    createValueProperty: (valueProperty) ->
      new Promise((resolve, reject) =>
        try
          vp = @java.newInstanceSync('com.sysunite.weaver.connector.ValueProperty',
              valueProperty.relations.subject, valueProperty.attributes.predicate, valueProperty.attributes.object)
          @java.callMethodSync(@tx, 'createValueProperty',vp)
          resolve()

        catch error
          reject(new Error('Error creating ValueProperty'))

      )

    createIndividualProperty: (individualProperty) ->
      new Promise((resolve, reject) =>

        try

          rp = @java.newInstanceSync('com.sysunite.weaver.connector.RelationProperty',
              individualProperty.relations.subject, individualProperty.attributes.predicate, individualProperty.relations.object)
          @java.callMethodSync(@tx, 'createRelationProperty',rp)
          resolve()

        catch error
          reject(error)

      )

    createRelationProperty: (relationProperty) ->
      new Promise((resolve, reject) =>
        try
          rp = @java.newInstanceSync('com.sysunite.weaver.connector.RelationProperty',
              relationProperty.id, relationProperty.predicate, relationProperty.object)
          @java.callMethodSync(@tx, 'createRelationProperty',rp)
          resolve()

        catch error
          reject(new Error('fail creating relationProperty'))

      )

    createPropertyRelation: (relationProperty, property, key) ->
      new Promise((resolve, reject) =>

        try
          rp = @java.newInstanceSync('com.sysunite.weaver.connector.RelationProperty',
              relationProperty.id, relationProperty.predicate, relationProperty.object)
          @java.callMethodSync(@tx, 'createPropertyRelation',rp, property, key)
          resolve()

        catch error
          reject(error)

      )

    updateIndividualProperty: (individualProperty) ->
      new Promise((resolve, reject) =>

        try
          @updateRelationProperty(individualProperty.subject, individualProperty.predicate, individualProperty.object)
          resolve()
        catch error
          reject(error)

      )

    updateValueProperty: (valueProperty) ->
      new Promise((resolve, reject) =>

        try
          @java.callMethodSync(@tx, 'updateValueProperty',valueProperty.subject, valueProperty.predicate, valueProperty.object)
          resolve()
        catch error
          reject(error)

      )

    updateRelationProperty: (nodeId, predicate, targetID) ->
      new Promise((resolve, reject) =>

        try
          @java.callMethodSync(@tx, 'updateRelationProperty',nodeId, predicate, targetID)
          resolve()
        catch error
          reject(error)

      )

    destroyIndividual: (nodeId) ->
      new Promise((resolve, reject) =>

        try
          @java.callMethodSync(@tx, 'destroyIndividual',nodeId)
          resolve()
        catch error
          reject(error)

      )

    destroyValueProperty: (nodeId, predicate) ->
      new Promise((resolve, reject) =>

        try
          @java.callMethodSync(@tx, 'destroyValueProperty',nodeId, predicate)
          resolve()
        catch error
          reject(error)

      )


    destroyRelationProperty: (nodeId, predicate) ->
      new Promise((resolve, reject) =>

        try
          @java.callMethodSync(@tx, 'destroyRelationProperty',nodeId, predicate)
          resolve()
        catch error
          reject(error)

      )

    commit: () ->
      new Promise((resolve, reject) =>

        try
          @java.callMethodSync(@tx,'commit')
          resolve()

        catch error
          reject(error)
      )


    close: () ->
      new Promise((resolve, reject) =>

        try
          @conn
          resolve()

        catch error
          reject(error)
      )

    rollback: () ->
      new Promise((resolve, reject) =>

        try
          @java.callMethodSync(@tx,'rollback')
          resolve()

        catch error
          reject(error)

      )

    shutdown: () ->
      new Promise((resolve, reject) =>

        try
          @java.callMethodSync(@graphdb,'shutdown')
          resolve()

        catch error
          console.log error
          reject(error)

      )
