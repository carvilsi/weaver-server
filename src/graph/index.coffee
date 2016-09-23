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
          url:    'http://localhost:9474/read/individual'
          qs:     {id, eagerness}

        request(options, (error, response, body) ->
          if error? then reject(error) else resolve(body)
        )
      )

    createIndividual: (individual) ->
      new Promise((resolve, reject) =>

        options =
          method: 'POST',
          url:    'http://localhost:9474/create/individual'
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
          url:    'http://localhost:9474/create/value'
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
          url:    'http://localhost:9474/create/relation'
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
          url:    'http://localhost:9474/update/relation'
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
          url:    'http://localhost:9474/update/value'
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
          url:    'http://localhost:9474/destroy/individual'
          qs:      {nodeId}
        request(options, (error) ->
          if error? then reject(error) else resolve()
        )
      )

    wipe: ->
      return
