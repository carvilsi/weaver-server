require("./test-suite")()
WeaverServer = require('../src/index')
Connector  = require('weaver-connector')

describe 'Create an object using Empty connector', ->

  server = null
  object = null

  before ->


    object = {
      id: 'id_o1'
      name: 'Aap'
      annotations: [
        {
          id: 'id_a1'
          label: 'eet'
          celltype: 'object'
        }
      ]
      properties: [
        {
          id: 'id_p1'
          annotation: 'id_a1'
          subject: 'id_o1'
          predicate: 'eet'
          object: 'id_o2'
        }
      ]
    }


    server = new WeaverServer("http://localhost:6379")


    emptyConnector = new Connector()
    server.setConnector(emptyConnector)






  it 'Create', ->

    payload = {"type":"$ROOT","id":"cimm01hj800043k5bz527ys3x","data":{"name":"mo"}}

    server.operations.create(payload).then(->

      # resolved
      ->
        console.log('success')

      # rejected
      (error) ->
        console.log(error)
    )




  it 'Read', ->

    payload = {"type":"$ROOT","id":"cimm01hj800043k5bz527ys3x","data":{"name":"mo"}}

    server.operations.read(payload).then(->

      # resolved
      ->
        console.log('success')

      # rejected
      (error) ->
        console.log(error)
    )




  it 'Update', ->

    payload = {"type":"$ROOT","id":"cimm01hj800043k5bz527ys3x","data":{"name":"mo"}}

    server.operations.update(payload).then(->

      # resolved
      ->
        console.log('success')

      # rejected
      (error) ->
        console.log(error)
    )




  it 'Delete', ->

    payload = {"type":"$ROOT","id":"cimm01hj800043k5bz527ys3x","data":{"name":"mo"}}

    server.operations.delete(payload).then(->

      # resolved
      ->
        console.log('success')

      # rejected
      (error) ->
        console.log(error)
    )




  it 'Link', ->

    payload = {"type":"$ROOT","id":"cimm01hj800043k5bz527ys3x","data":{"name":"mo"}}

    server.operations.link(payload).then(->

      # resolved
      ->
        console.log('success')

      # rejected
      (error) ->
        console.log(error)
    )




  it 'Unlink', ->

    payload = {"type":"$ROOT","id":"cimm01hj800043k5bz527ys3x","data":{"name":"mo"}}

    server.operations.unlink(payload).then(->

      # resolved
      ->
        console.log('success')

      # rejected
      (error) ->
        console.log(error)
    )




  it 'Destroy', ->

    payload = {"type":"$ROOT","id":"cimm01hj800043k5bz527ys3x","data":{"name":"mo"}}

    server.operations.destroy(payload).then(->

      # resolved
      ->
        console.log('success')

      # rejected
      (error) ->
        console.log(error)
    )



