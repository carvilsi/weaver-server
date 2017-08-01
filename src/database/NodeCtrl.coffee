bus           = require('WeaverBus')
AclService    = require('AclService')
logger        = require('logger')

bus.private('write').retrieve('user', 'project', 'database').on((req, user, project, database) ->
  logger.code.debug("The user stuff: #{JSON.stringify(user)}")
  AclService.assertACLWritePermission(user, project.acl)
  database.write(req.payload.operations, user.userId)
)

bus.private('nodes').retrieve('database').on((req, database) ->
  database.listAllNodes(req)
)

bus.private('relations').retrieve('database').on((req, database) ->
  database.listAllRelations()
)
