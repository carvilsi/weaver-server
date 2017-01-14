rp = require('request-promise')

module.exports =
class DatabaseConnection
  
  constructor: (@uri) ->

  read: (id) ->
    options =
      method: 'GET'
      uri:    @uri + '/read/' + id
      json:   true

    rp(options)

  write: (payload) ->
    options =
      method: 'POST'
      uri:    @uri + '/write'
      body:   payload
      json:   true

    rp(options)