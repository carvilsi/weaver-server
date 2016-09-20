Promise = require('bluebird')
Transaction = require('./transaction')

module.exports =
  class Connection

    @tx
    @java

    constructor: (@conn) ->
      @tx = @conn.tx
      @java = @conn.java
    ###
    Below are methods specified by the original weaver connector interface. These
    are heavily based on the use of a virtuoso database however there are not
    part of the weaver-connector-neo4j-java so are not implemented here
    ###

    executeUpdate: () ->
      new Promise((resolve, reject) =>

        reject(throw new Error('not implemented'))
      )

    executeQuery: () ->
      new Promise((resolve, reject) =>

        reject(throw new Error('not implemented'))
      )


    close: () ->
      new Promise((resolve, reject) =>

        try
          @java.callMethodSync(@tx,'close')
          resolve()

        catch error
          reject(error)
      )
    # close: ->
    #   new Promise((resolve, reject) =>
    #     try
    #       Transaction.close()
    #       resolve()
    #     catch error
    #       reject()
    #
    #     # reject(throw new Error('not implemented'))
    #   )
