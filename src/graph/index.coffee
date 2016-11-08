Promise = require('bluebird')
request = require('request')
colors = require('colors')

module.exports =
  class GraphDatabase

    constructor: (@options) ->
      
    ###
     Reads a weaver entity with optional eagerness
     GET /read/individual
    ###
    
    readIndividual: (id, eagerness) ->
      new Promise((resolve, reject) =>
        options =
          method: 'GET',
          url:    'http://' + @options.weaverServiceIp + ':' + @options.weaverServicePort + '/read/individual'
          qs:     {id, eagerness}

        request(options, (error, response, body) ->
          if error? then reject(error) else resolve(body)
        )
      )

    ###
     Creates a weaver entry
     POST /write/weaverEntity
    ###
    
    createIndividual: (individual) ->
      new Promise((resolve, reject) =>
        options =
          method: 'POST',
          url:    'http://' + @options.weaverServiceIp + ':' + @options.weaverServicePort + '/write/weaverEntity'
          body:   JSON.stringify(individual)
        request(options, (error, response, body) ->
          if error? then reject(error) else resolve(JSON.parse(body))
        )
      )

    ###
     TODO: adapt to new format
    ###
    
    createValueProperty: (valueProperty) ->
      payload =
        id: valueProperty.id
        originId: valueProperty.relations.subject
        predicate: valueProperty.relations.predicate
        value: valueProperty.attributes.object

      new Promise((resolve, reject) =>

        options =
          method: 'POST',
          url:    'http://' + @options.weaverServiceIp + ':' + @options.weaverServicePort + '/create/value'
          body:   JSON.stringify(payload)

        request(options, (error) ->
          if error? then reject(error) else resolve()
        )
      )

    ###
     Creates a call to the weaver-service to create a relationship
     POST /create/relation
    ###
    

    createIndividualProperty: (individualProperty) ->
      new Promise((resolve, reject) =>
        options =
          method: 'POST',
          url:    'http://' + @options.weaverServiceIp + ':' + @options.weaverServicePort + '/create/relation'
          body:   JSON.stringify(individualProperty)
        request(options, (error, response, body) ->
          if error? then reject(error) else resolve(JSON.parse(body))
        )
      )



    updateIndividualProperty: (individualProperty) ->
      payload =
        nodeId: individualProperty.subject
        predicate: individualProperty.predicate
        targetId: individualProperty.object

      new Promise((resolve, reject) =>

        options =
          method: 'POST',
          url:    'http://' + @options.weaverServiceIp + ':' + @options.weaverServicePort + '/update/relation'
          qs: payload
        request(options, (error) ->
          if error? then reject(error) else resolve()
        )
      )


    updateValueProperty: (valueProperty) ->
      
      new Promise((resolve, reject) =>

        options =
          method: 'POST',
          url:    'http://' + @options.weaverServiceIp + ':' + @options.weaverServicePort + '/update/value'
          body:   JSON.stringify(valueProperty)
        request(options, (error, response, body) ->
          if error? then reject(error) else resolve(JSON.parse(body))
        )
      )


    deleteObject: (nodeId) ->
      new Promise((resolve, reject) =>

        options =
          method: 'POST',
          url:    'http://' + @options.weaverServiceIp + ':' + @options.weaverServicePort + '/destroy/individual'
          qs:      {nodeId}
        request(options, (error, response, body) ->
          if error? then reject(error) else resolve()
        )
      )
      
    deleteRelation: (payload) ->
      new Promise((resolve, reject) =>
        
        console.log '=^^=|_DeleteRelation!!!!!!'
        console.log payload
        options =
          method: 'POST',
          url:    'http://' + @options.weaverServiceIp + ':' + @options.weaverServicePort + '/destroy/relation'
          qs:      JSON.stringify(payload)
          
        console.log options
        request(options, (error, response, body) ->
          if error? then reject(error) else resolve(body)
        )
      )

    wipe: ->
      new Promise((resolve, reject) =>
        
        options =
          method: 'POST',
          url:    'http://' + @options.weaverServiceIp + ':' + @options.weaverServicePort + '/wipe/db',
          qs: {}
        request(options, (error, response, body) ->
          if error? then reject(error) else resolve(body)
        )
      )

    wipeWeaver: ->
      new Promise((resolve, reject) =>
        
        options =
          method: 'POST',
          url:    'http://' + @options.weaverServiceIp + ':' + @options.weaverServicePort + '/wipe/weaver',
          qs: {}
        request(options, (error, response, body) ->
          if error? then reject(error) else resolve(body)
        )
      )
