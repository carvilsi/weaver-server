Promise = require('bluebird')

module.exports =
  class Query

    @tx
    @java
    @qu

    constructor: (@db) ->
      if not @db
          console.log 'Errror must be a neo4j db'

      @java = @db.java
      @tx = @db.tx
      @qu = @java.newInstanceSync('com.sysunite.weaver.connector.neo4j.Neo4jQuery', @db.graphdb)


    literalQuery: (queryString) ->
      new Promise((resolve, reject) =>

        try
          @java.callMethodSync(@qu,'literalQuery',queryString)
          resolve()

        catch error
          reject(error)

      )


      ###
       find() returns an array with the $ID values of matching nodes
      ###


    find: () ->
      new Promise((resolve, reject) =>

        try
          resultList = @java.callMethodSync(@qu,'find')

          result = []

          for i in [0..resultList.sizeSync()-1]
            nodeList = resultList.getSync(i)
            node = nodeList.getSync(0)
            properties = node.getAllPropertiesSync()
            result.push properties.getSync('$ID')

          resolve(result)

        catch error
          reject(error)

      )

    getValueProperties: (objectId) ->
      new Promise((resolve, reject) =>

        reject(throw new Error('not implemented'))
      )
      ###
       TODO: This method seems not implemented on java
      ###
      # new Promise((resolve, reject) =>
      #
      #   try
      #     @java.callMethodSync(@qu,'getValueProperties',objectId)
      #     resultList = @java.callMethodSync(@qu,'find')
      #     console.log resultList.toStringSync()
      #     resolve()
      #
      #   catch error
      #     reject(error)
      #
      # )


      ###
       first() returns the first $ID from the matching nodes
      ###


    first: () ->
      new Promise((resolve, reject) =>

        try
          res = @java.callMethodSync(@qu,'first')
          node = res.getSync(0)
          properties = node.getAllPropertiesSync()
          result = properties.getSync('$ID')
          resolve(result)

        catch error
          reject(error)

      )

    count: () ->
      new Promise((resolve, reject) =>

        try
          @java.callMethodSync(@qu,'literalQuery','match (n) return n')
          resolve(@java.callMethodSync(@qu,'count'))

        catch error
          reject(error)

      )



    ###
    Below are methods specified by the original weaver connector interface. These
    are heavily based on the use of a virtuoso database however there are not
    part of the weaver-connector-neo4j-java so are not implemented here
    ###


    selectindividuals: (filters) =>
      new Promise((resolve, reject) =>

        reject(throw new Error('not implemented'))
      )

    select: () ->
      new Promise((resolve, reject) =>

        reject(throw new Error('not implemented'))
      )

    filter: () ->
      new Promise((resolve, reject) =>

        reject(throw new Error('not implemented'))
      )

    equalToValue: (pred, value) ->
      new Promise((resolve, reject) =>

        reject(throw new Error('not implemented'))
      )

    equalToObject: (pred, toId) ->
      new Promise((resolve, reject) =>

        reject(throw new Error('not implemented'))
      )

    ascending: (pred) ->
      new Promise((resolve, reject) =>

        reject(throw new Error('not implemented'))
      )

    descending: (pred) ->
      new Promise((resolve, reject) =>

        reject(throw new Error('not implemented'))
      )

    limit: (limit) ->
      new Promise((resolve, reject) =>

        reject(throw new Error('not implemented'))
      )

    skip: (skip) ->
      new Promise((resolve, reject) =>

        reject(throw new Error('not implemented'))
      )
