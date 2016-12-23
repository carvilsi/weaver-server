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
        try
          options =
            method: 'GET',
            url:    'http://' + @options.weaverServiceIp + ':' + @options.weaverServicePort + '/read/individual'
            qs:     {id, eagerness}

          request(options, (error, response, body) ->
            if error? then reject(error) else resolve(body)
          )
        catch error
          reject()
      )

    ###
     Creates a weaver entry
     POST /write/weaverEntity
    ###
    
    createIndividual: (individual) ->
      new Promise((resolve, reject) =>
        try
          options =
            method: 'POST',
            url:    'http://' + @options.weaverServiceIp + ':' + @options.weaverServicePort + '/write/weaverEntity'
            body:   JSON.stringify(individual)
          request(options, (error, response, body) ->
            if error? then reject(error) else resolve(JSON.parse(body))
          )
        catch error
          reject(error)
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

    # TODO: Maybe is better to send just the id as qs instead to send a payload
    deleteObject: (payload) ->
      new Promise((resolve, reject) =>
        try
          options =
            method: 'POST',
            url:    'http://' + @options.weaverServiceIp + ':' + @options.weaverServicePort + '/destroy/individual'
            body:   JSON.stringify(payload)
          request(options, (error, response, body) ->
            if error? then reject(error) else resolve(body)
          )
        catch error
          reject(error)
      )
      
    deleteRelation: (payload) ->
      new Promise((resolve, reject) =>
        try
          options =
            method: 'POST',
            url:    'http://' + @options.weaverServiceIp + ':' + @options.weaverServicePort + '/destroy/relation'
            body:   JSON.stringify(payload)
          request(options, (error, response, body) ->
            if error? then reject(error) else resolve(body)
          )
        catch error
          reject(error)
      )

    wipe: ->
      new Promise((resolve, reject) =>
        try
          options =
            method: 'POST',
            url:    'http://' + @options.weaverServiceIp + ':' + @options.weaverServicePort + '/wipe/db',
            qs: {}
          request(options, (error, response, body) ->
            if error? then reject(error) else resolve(body)
          )
        catch error
          reject(error)
      )

    wipeWeaver: ->
      new Promise((resolve, reject) =>
        try
          options =
            method: 'POST',
            url:    'http://' + @options.weaverServiceIp + ':' + @options.weaverServicePort + '/wipe/weaver',
            qs: {}
          request(options, (error, response, body) ->
            if error? then reject(error) else resolve(body)
          )
        catch error
          reject(error)
      )
    
    bulkNodes: (payload) ->
      new Promise((resolve, reject) =>
        try
          options =
            method: 'POST',
            url:    'http://' + @options.weaverServiceIp + ':' + @options.weaverServicePort + '/write/bulk/weaverEntity',
            body: JSON.stringify(payload)
          request(options, (error, response, body) ->
            if error? then reject(error) else resolve(body)
          )
        catch error
          reject(error)
      )
    
    bulkRelations: (payload) ->
      new Promise((resolve, reject) =>
        try
          options =
            method: 'POST',
            url:    'http://' + @options.weaverServiceIp + ':' + @options.weaverServicePort + '/create/bulk/relation',
            body: JSON.stringify(payload)
          request(options, (error, response, body) ->
            if error? then reject(error) else resolve(body)
          )
        catch error
          reject(error)
      )
