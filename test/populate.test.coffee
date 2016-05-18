require("./test-suite")()
WeaverServer = require('../src/index')
Connector  = require('weaver-connector')

describe 'Create an object using Empty connector', ->

  server = null
  object = null
  filters = {}

  before ->
    filters = {}




    server = new WeaverServer("http://localhost:6379")

    emptyConnector = new Connector()
    server.setConnector(emptyConnector)

#  it 'Populate from filters', ->
#
#    server.operations.populateFromFilters(filters).then(->
#
#      # resolved
#      ->
#        console.log('success')
#
#      # rejected
#      (error) ->
#        console.log(error)
#    )
#
#

