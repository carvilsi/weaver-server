require("./test-suite")()
WeaverServer = require('../src/index')
Connector  = require('weaver-connector')

describe 'Create an object using Empty connector', ->

  server = null
  object = null

  before ->
    filters = {}
#      { _ATTRIBUTES: {}
#        _META:
#          fetched: true
#          type: '$COLLECTION'
#          id: 'cinsxf6nh00013j6mfd4etfmf'
#        _RELATIONS:
#        { cinsxfgll00063j6mbhp1s2xz:
#          { _ATTRIBUTES: { label: 'unnamed', predicate: 'unnamed', celltype: 'object' }
#            _META:
#            { fetched: true
#              type: '$FILTER'
#              id: 'cinsxfgll00063j6mbhp1s2xz' }
#            _RELATIONS:
#            { conditions:
#              { _ATTRIBUTES: {}
#                _META:
#                { fetched: true
#                  type: '$COLLECTION'
#                  id: 'cinsxfgll00073j6mhbps5d1q' }
#                _RELATIONS:
#                { cinsxgf4p000f3j6mawhtr9ay:
#                { _ATTRIBUTES:
#                  { predicate: 'rdf:type'
#                    operation: 'this object'
#                    value: ''
#                    conditiontype: 'object' }
#                    _META:
#                    { fetched: true
#                      type: '$CONDITION'
#                      id: 'cinsxgf4p000f3j6mawhtr9ay' }
#                    _RELATIONS:
#                    { object:
#                      { _ATTRIBUTES: { name: 'User' }
#                        _META:
#                        { fetched: false
#                          type: '$INDIVIDUAL'
#                          id: 'cinsxg12r000a3j6mcg8g9f8k' }
#                      }
#                    }
#                  }
#                }
#              }
#            }
#          }
#        }
#      }



    server = new WeaverServer("http://localhost:6379")

    emptyConnector = new Connector()
    server.setConnector(emptyConnector)

  it 'Destroy', ->

    server.operations.populateFromFilters(filters).then(->

      # resolved
      ->
        console.log('success')

      # rejected
      (error) ->
        console.log(error)
    )



