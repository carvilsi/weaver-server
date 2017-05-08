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

bus.private('role.update').retrieve('user').require('role').on((req, user, role) ->
  AclService.assertACLWritePermission(user, role._id)
  RoleService.updateRole(role)
)

bus.private('role.delete').retrieve('user').require('id').on((req, user, id) ->
  AclService.assertACLWritePermission(user, id)
  RoleService.deleteRole(id)
)

bus.private("roles").retrieve('user').on((req, user)->
  if not user.isAdmin()
    throw {code:-1, message: "Only admin user is allowed get all roles."}

  RoleService.all()
)
