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


# TODO: Can we remove this? Weaver.load uses Weaver.Query
bus.private('read').retrieve('user').require('target', 'nodeId').on((req, user, target, nodeId) ->
  UserService.assertACLReadPermission(user, nodeId)

  getDb(target).then((db) ->
    db.read(nodeId)
  )
)

bus.private('write').retrieve('user', 'project', 'database').on((req, user, project, database) ->
  # Check project write permission of database for current user
  UserService.assertACLWritePermission(user, project.acl)

  database.write(req.payload.operations)
)

bus.private('nodes').require('target').on((req, target) ->

  getDb(target).then((db) ->
    db.listAllNodes(req)
  )
)

bus.private('relations').require('target').on((req, target) ->
  getDb(target).then((db) ->
    db.listAllRelations()
  )
)

bus.private('wipe').require('target').on((req, target) ->
  getDb(target).then((db) ->
    db.wipe()
  )
)

