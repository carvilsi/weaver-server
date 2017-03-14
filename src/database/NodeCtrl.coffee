bus             = require('WeaverBus')
UserService     = require('UserService')


bus.private('write').retrieve('user', 'project', 'database').on((req, user, project, database) ->
  UserService.assertACLWritePermission(user, project.acl)
  database.write(req.payload.operations)
)

bus.private('nodes').retrieve('database').on((req, database) ->
  database.listAllNodes(req)
)

bus.private('relations').retrieve('database').on((req, database) ->
  database.listAllRelations()
)

bus.private('wipe').retrieve('database').on((req, database) ->
  database.wipe()
)
