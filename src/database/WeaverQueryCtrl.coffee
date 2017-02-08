Promise         = require('bluebird')
config          = require('config')
DatabaseService = require('DatabaseService')
bus             = require('WeaverBus')

systemDatabase  = new DatabaseService(config.get('services.systemDatabase.endpoint'))

# Helper function to get the designated database based on target
getDb = (target) ->
  if target is '$SYSTEM'
    Promise.resolve(systemDatabase)
  else
    bus.get("internal").emit('getDatabaseForProject', target).then((endpoint) ->
      new DatabaseService(endpoint)
    )


bus.private('query').require('target').on((req, target) ->
  getDb(target).then((db) ->
    db.query(req.payload.query)
  )
)

bus.private('query.native').require('target').on((req, target) ->
  getDb(target).then((db) ->
    db.nativeQuery(req.payload.query)
  )
)
