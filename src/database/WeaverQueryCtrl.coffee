Promise         = require('bluebird')
config          = require('config')
DatabaseService = require('DatabaseService')
bus             = require('EventBus').get('weaver')
expect          = require('util/bus').getExpect(bus)

systemDatabase  = new DatabaseService(config.get('services.systemDatabase.endpoint'))

# Helper function to get the designated database based on target
getDb = (target) ->
  console.log
  if target is '$SYSTEM'
    Promise.resolve(systemDatabase)
  else
    bus.emit('getDatabaseForProject', target).then((endpoint) ->
      new DatabaseService(endpoint)
    )


expect('target').bus('query').do((req, res, target) ->
  getDb(target).then((db) ->
    db.query(req.payload.query)
  )
)
