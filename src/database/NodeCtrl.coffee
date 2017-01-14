config       = require('config')
DbConnection = require('DatabaseConnection')
bus          = require('EventBus').get('weaver')

connection = new DbConnection(config.get('services.database.endpoint'))

bus.on('read', (req, res)->
  connection.read(req.payload.nodeId)
)

bus.on('write', (req, res)->
  connection.write(req.payload)
)