rp = require('request-promise')

module.exports =
  class DatabaseService

    constructor: (@uri) ->

    _rp : (method) -> (uri, body) ->
      rp({method, uri, body, json: true, resolveWithFullResponse: true}).then((response) ->
        if response.statusCode is 200
          response.body
        else
          Promise.reject({code: -1, message: "Server error: #{response.body}"})
      )
      .catch((err) ->
        if err.error.code is 'ECONNREFUSED'
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
      @_POST("#{@uri}/write?disable-checking", payload)

    query: (query) ->
      @_POST("#{@uri}/query", query)

    wipe: ->
      @_GET("#{@uri}/wipe")
