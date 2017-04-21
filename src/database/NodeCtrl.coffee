bus           = require('WeaverBus')
AclService    = require('AclService')
logger        = require('logger')
operationSort = require('operationSort')

bus.private('write').retrieve('user', 'project', 'database').on((req, user, project, database) ->
  logger.code.debug("The user stuff: #{JSON.stringify(user)}")
  AclService.assertACLWritePermission(user, project.acl)
  req.payload.operations.sort(operationSort)
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
