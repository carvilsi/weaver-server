config          = require('config')
DatabaseService = require('DatabaseService')
bus             = require('EventBus').get('weaver')

busWithDb = on: (path, callback) ->
  bus.on(path, (req, res) ->
    bus.emit('getDatabaseForProject', req.payload.project).then((endpoint) ->
      callback(req, res, new DatabaseService(endpoint))
    )
  )

busWithDb.on('read', (req, res, db) ->
  db.read(req.payload.nodeId)
)

busWithDb.on('write', (req, res, db) ->
  db.write(req.payload.operations)
)