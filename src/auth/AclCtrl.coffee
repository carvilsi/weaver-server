bus = require('WeaverBus')
UserService = require('UserService')

bus.private('acl.read').retrieve('user').require('id').on((req, user, id) ->
  UserService.assertACLReadPermission(user, id)
  UserService.getACL(id)
)

bus.private('acl.write').retrieve('user').require('acl').on((req, user, acl) ->
  UserService.assertACLWritePermission(user, acl._id)
  UserService.writeACL(acl)
)

bus.private('acl.delete').retrieve('user').require('id').on((req, user, id) ->
  UserService.assertACLWritePermission(user, id)
  UserService.deleteACL(id)
)
