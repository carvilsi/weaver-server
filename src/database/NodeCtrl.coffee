bus           = require('WeaverBus')
AclService    = require('AclService')
logger        = require('logger')

bus.private('write').retrieve('user', 'project', 'database').on((req, user, project, database) ->
  logger.code.silly("Write received for user: #{JSON.stringify(user)}")
  AclService.assertACLWritePermission(user, project.acl)
  database.write(req.payload.operations, user.userId)
)

bus.private('nodes').retrieve('database').on((req, database) ->
  database.listAllNodes(req)
)

bus.private('node.clone')
.retrieve('database', 'user', 'project')
.require('sourceId', 'targetId', 'relationsToTraverse')
.optional('sourceGraph', 'targetGraph')
.on((req, database, user, project, sourceId, targetId, relationsToTraverse, sourceGraph, targetGraph) ->
  AclService.assertACLWritePermission(user, project.acl)
  database.clone(sourceId, targetId, user.userId, relationsToTraverse, sourceGraph, targetGraph)
)

bus.private('relations').retrieve('database').on((req, database) ->
  database.listAllRelations()
)
