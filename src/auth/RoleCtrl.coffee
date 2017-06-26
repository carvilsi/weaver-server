bus = require('WeaverBus')
AclService  = require('AclService')
RoleService = require('RoleService')

bus.private('role.create').retrieve('user').require('role').on((req, user, role) ->
  acl = AclService.createACL(role.roleId, user.username)
  RoleService.createRole(role, acl.id)
)

bus.private('role.read').retrieve('user').require('id').on((req, user, id) ->
  AclService.assertACLReadPermission(user, id)
  RoleService.getRole(id)
)

bus.private('role.update').retrieve('user').require('update').on((req, user, update) ->
  AclService.assertACLWritePermission(user, update.roleId)
  RoleService.update(update)
)

bus.private('role.delete').retrieve('user').require('id').on((req, user, id) ->
  AclService.assertACLWritePermission(user, id)
  RoleService.destroy(id)
)

bus.private("roles").retrieve('user').on((req, user)->
  if not user.isAdmin()
    throw {code:-1, message: "Only admin user is allowed get all roles."}

  RoleService.all()
)
