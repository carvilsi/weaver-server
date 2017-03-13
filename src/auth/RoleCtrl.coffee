bus = require('WeaverBus')
UserService = require('UserService')

bus.private('role.create').retrieve('user').require('role').on((req, user, role) ->
  UserService.createRole(role, user)
)

bus.private('role.read').retrieve('user').require('id').on((req, user, id) ->
  UserService.assertACLReadPermission(user, id)
  UserService.getRole(id)
)

bus.private('role.update').retrieve('user').require('role').on((req, user, role) ->
  UserService.assertACLWritePermission(user, role._id)
  UserService.updateRole(role)
)

bus.private('role.delete').retrieve('user').require('id').on((req, user, id) ->
  UserService.assertACLWritePermission(user, id)
  UserService.deleteRole(id)
)
