require("../test-suite")()
WeaverServer = require('../../src/index')
Virtuoso  = require('weaver-connector-virtuoso')

describe 'Create an object', ->
  server = null
  virtuoso = null
  object = null

  beforeEach ->


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

    virtuoso = new Virtuoso({
      host:'192.168.99.100'
      port:'1111'
      user:'dba'
      password:'myDbaPassword'
      graph:'http://weaver-connector-virtuoso/test#'
    })

    server.setConnector(virtuoso)

    virtuoso.init()




  it 'Do something', ->

    payload = {"type":"$OBJECT","id":"cimm01hj800043k5bz527ys3x","data":{"name":"mo"}}
#    server.operations.create(payload).then(->
#      console.log('baaaa')
#    )