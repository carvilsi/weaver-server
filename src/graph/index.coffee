Promise = require('bluebird')
request = require('request')
colors = require('colors')

module.exports =
  class GraphDatabase

    constructor: (@options) ->

    readIndividual: (id, eagerness) ->

      console.log(colors.green('The id: %s'),id)
      console.log(colors.green('The eagerness: %s'),eagerness)

      new Promise((resolve, reject) =>

        options =
          method: 'GET',
          url:    'http://' + @options.weaverServiceIp + ':' + @options.weaverServiceIp + '/read/individual'
          qs:     {id, eagerness}

        request(options, (error, response, body) ->
          if error? then reject(error) else resolve(body)
        )
      )

    createIndividual: (individual) ->
      new Promise((resolve, reject) =>

        options =
          method: 'POST',
          url:    'http://' + @options.weaverServiceIp + ':' + @options.weaverServiceIp + '/create/individual'
          body:   JSON.stringify(individual)

        request(options, (error) ->
          if error? then reject(error) else resolve()
        )
      )

    createValueProperty: (valueProperty) ->
      payload =
        id: valueProperty.id
        originId: valueProperty.relations.subject
        predicate: valueProperty.relations.predicate
        value: valueProperty.attributes.object

      new Promise((resolve, reject) =>

        options =
          method: 'POST',
          url:    'http://' + @options.weaverServiceIp + ':' + @options.weaverServiceIp + '/create/value'
          body:   JSON.stringify(payload)

        request(options, (error) ->
          if error? then reject(error) else resolve()
        )
      )


    createIndividualProperty: (individualProperty) ->
      payload =
        id: individualProperty.id
        originId: individualProperty.relations.subject
        predicate: individualProperty.relations.predicate
        targetId: individualProperty.relations.object

      new Promise((resolve, reject) =>

        options =
          method: 'POST',
          url:    'http://' + @options.weaverServiceIp + ':' + @options.weaverServiceIp + '/create/relation'
          body:   JSON.stringify(payload)

        request(options, (error) ->
          if error? then reject(error) else resolve()
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
          url:    'http://' + @options.weaverServiceIp + ':' + @options.weaverServiceIp + '/update/relation'
          qs: payload
        request(options, (error) ->
          if error? then reject(error) else resolve()
        )
      )


    updateValueProperty: (valueProperty) ->
      payload =
        nodeId: valueProperty.subject
        predicate: valueProperty.predicate

      new Promise((resolve, reject) =>

        options =
          method: 'POST',
          url:    'http://' + @options.weaverServiceIp + ':' + @options.weaverServiceIp + '/update/value'
          qs:      payload
          body:    valueProperty.object
        request(options, (error) ->
          if error? then reject(error) else resolve()
        )
      )


    deleteObject: (nodeId) ->
      new Promise((resolve, reject) =>

        options =
          method: 'POST',
          url:    'http://' + @options.weaverServiceIp + ':' + @options.weaverServiceIp + '/destroy/individual'
          qs:      {nodeId}
        request(options, (error) ->
          if error? then reject(error) else resolve()
        )
      )

    wipe: ->
      return
