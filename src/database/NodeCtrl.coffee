config          = require('config')
DatabaseService = require('DatabaseService')
bus             = require('EventBus').get('weaver')

bus.on('read', (req, res)->
  bus.emit('getDatabaseForProject', req.payload.project).then((endpoint) ->
    db = new DatabaseService(endpoint)
    db.read(req.payload.nodeId)
  )
)

bus.on('write', (req, res)->
  bus.emit('getDatabaseForProject', req.payload.project).then((endpoint) ->
    db = new DatabaseService(endpoint)
    db.write(req.payload.operations)
  )
)
