rp = require('request-promise')

module.exports =
  class DatabaseService

    constructor: (@uri) ->

    _rp : (method) -> (uri, body) ->
      rp({method, uri, body, json: true, resolveWithFullResponse: true}).then((response) ->
        if response.statusCode is 200
          Promise.resolve(response.body)
        else
          Promise.reject({code: -1, message: "Server error: #{response.body}"})
      )
      .catch((err) ->
        if err.error.code? and err.error.message?
          Promise.reject(err.error)
        else if err.error.code is 'ECONNREFUSED'
          Promise.reject({code: -1, message: "Could not connect to database: #{err.error.address}:#{err.error.port}"})
        else
          Promise.reject({code: -1, message: "Unexpected error occurred: #{err.message}"})
      )

    _GET : (args...) ->
      @_rp("GET")(args...)

    _POST: (args...) ->
      @_rp("POST")(args...)

    read: (id) ->
      @_GET("#{@uri}/read/#{id}")

    write: (payload) ->
      @_POST("#{@uri}/write", payload)

    writeQuick: (payload) ->
      @_POST("#{@uri}/write?disable-checking", payload)

    query: (query) ->
      @_POST("#{@uri}/query", query)

    nativeQuery: (query) ->
      switch ('VIRTUOSO') #add all our different database types here, at some point
        when 'NEO4J'                then return
        when 'GRAPH_DB'             then return
        when 'VIRTUOSO'             then @_GET("#{@uri}/sparql?query=" + encodeURIComponent(query))
        when 'THE_NEXT_BIG_THING'   then return
        else return #do fail


    listAllNodes: (args) ->
      @_GET("#{@uri}/nodes?attributes="+encodeURI(args))

    listAllRelations: ->
      @_GET("#{@uri}/relationKeys")

    wipe: ->
      @_GET("#{@uri}/wipe")
