Promise = require('bluebird')
request = require('request')
conf    = require('config')

# Helper functions for creating requests
baseUrl = "http://#{conf.get('services.connector.host')}:#{conf.get('services.connector.port')}/"

req = (method) -> (path, body, func) ->
  
  # Defaults
  func = (x) -> x if not func?
  body = "" if not body?
  
  # Full URL
  url  = baseUrl + path

  # Params
  params  = {POST: 'body', GET:  'qs'}
  options = {method, url}
  options[params[method]] = body

  # Request
  new Promise((resolve, reject) =>
    try
      request(options, (error, response, body) ->
        if error? then reject(error) else resolve(func(body))
      )
    catch error
      reject(error)
  )

POST =  req('POST')
GET  =  req('GET')



class ConnectorService

  # Reads a weaver entity with optional eagerness
  readIndividual: (id, eagerness) ->
    GET('read/individual', {id, eagerness})


  # Creates a weaver entry
  createIndividual: (individual) ->
    POST('write/weaverEntity', JSON.stringify(individual))


  createValueProperty: (valueProperty) ->
    payload =
      id:        valueProperty.id
      originId:  valueProperty.relations.subject
      predicate: valueProperty.relations.predicate
      value:     valueProperty.attributes.object

    POST('create/value', JSON.stringify(payload))


  # Creates a call to the weaver-service to create a relationship
  createIndividualProperty: (individualProperty) ->
    POST('create/relation', JSON.stringify(individualProperty), JSON.parse)


  updateIndividualProperty: (individualProperty) ->
    payload =
      nodeId:    individualProperty.subject
      predicate: individualProperty.predicate
      targetId:  individualProperty.object

    POST('update/relation', JSON.stringify(payload))


  updateValueProperty: (valueProperty) ->
    POST('update/value', JSON.stringify(valueProperty), JSON.parse)

    
  deleteObject: (payload) ->
    POST('destroy/individual', JSON.stringify(payload))

    
  deleteRelation: (payload) ->
    POST('destroy/relation', JSON.stringify(payload))
    
  wipe: ->
    POST('wipe/db')
    
#  bulkNodes: (payload) ->
#    POST('/write/bulk/weaverEntity', JSON.stringify(payload))
#    
#  bulkRelations: (payload) ->
#    POST('/create/bulk/relation', JSON.stringify(payload))


module.exports = new ConnectorService()