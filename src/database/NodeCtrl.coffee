config          = require('config')
DatabaseService = require('DatabaseService')
bus             = require('EventBus').get('weaver')

db = new DatabaseService(config.get('services.database.endpoint'))

bus.on('read', (req, res)->
  db.read(req.payload.nodeId)
)

bus.on('write', (req, res)->
  db.write(req.payload)
)