bus        = require('WeaverBus')
AclService = require('AclService')
logger = require('logger')

nodeSort = (a, b) ->
  res = a.timestamp - b.timestamp
  if res is 0
    res += 1 if b.action is 'create-node'
    res += -1 if a.action is 'create-node'
  res

bus.private('write').retrieve('user', 'project', 'database').on((req, user, project, database) ->
  logger.code.debug("The user stuff: #{JSON.stringify(user)}")
  AclService.assertACLWritePermission(user, project.acl)
  req.payload.operations.sort(nodeSort)
  console.log(req.payload.operations)
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
