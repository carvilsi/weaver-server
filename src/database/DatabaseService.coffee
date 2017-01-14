rp = require('request-promise')

module.exports =
class DatabaseService
  
  constructor: (@uri) ->

  read: (id) ->
    rp(
      method: 'GET'
      uri:    @uri + '/read/' + id
      json:   true
    )

  write: (payload) ->
    rp(
      method: 'POST'
      uri:    @uri + '/write'
      body:   payload
      json:   true
    )