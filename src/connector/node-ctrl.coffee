ERROR          = require('error')
bus            = require('event-bus').get('weaver')
connector      = require('connector-service')
validator      = require('validator')

payloadValidator = (fields, success) -> (req, res) ->
  if not validator.hasFields(req.payload, fields)
    res.status(503).send(ERROR('invalid payload supplied', req.payload))
  else
    success(req, res)


bus.on('create', payloadValidator(['id', 'attributes'], (req, res)->
    res.promise(connector.createIndividual(req.payload))  
  )
)

bus.on('read', payloadValidator(['id', 'eagerness'], (req, res)->
    res.promise(connector.readIndividual(req.payload))
  )
)