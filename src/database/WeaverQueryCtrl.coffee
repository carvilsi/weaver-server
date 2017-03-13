Promise         = require('bluebird')
config          = require('config')
DatabaseService = require('DatabaseService')
bus             = require('WeaverBus')
UserService     = require('UserService')


systemDatabase  = new DatabaseService(config.get('services.systemDatabase.endpoint'))

# Helper function to get the designated database based on target
getDb = (target) ->
  if target is '$SYSTEM'
    Promise.resolve(systemDatabase)
  else
    bus.get("internal").emit('getDatabaseForProject', target).then((endpoint) ->
      new DatabaseService(endpoint)
    )


bus.private('query').retrieve('user', 'database').on((req, user, database) ->

  database.query(req.payload.query).then((results) ->

    # Check permission
    #ids    = (r.nodeId for r in results)
    #aclIds = UserService.getACLByObjects(ids)

    #console.log(aclIds)
    #UserService.assertACLReadPermission(user, ids)

    results
  )
)

bus.private('query.native').require('target').on((req, target) ->
  getDb(target).then((db) ->
    db.nativeQuery(req.payload.query)
  )
)
