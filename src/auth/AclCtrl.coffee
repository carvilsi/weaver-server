bus         = require('WeaverBus')
AclService  = require('AclService')

bus.private('acl.create').retrieve('user').require('acl').on((req, user, acl) ->
  AclService.createACLFromServer(acl, user)
)

bus.private('acl.read').retrieve('user').require('id').on((req, user, id) ->
  AclService.assertACLReadPermission(user, id)
  AclService.getACL(id)
)

bus.private('acl.read.byObject').retrieve('user').require('objectId').on((req, user, objectId) ->
  acl = AclService.getACLByObject(objectId)
  AclService.assertACLReadPermission(user, acl.id)
  acl
)

bus.private('acl.update').retrieve('user').require('acl').on((req, user, acl) ->
  AclService.assertACLWritePermission(user, acl._id)
  AclService.updateACL(acl)
)

bus.private('acl.delete').retrieve('user').require('id').on((req, user, id) ->
  AclService.assertACLWritePermission(user, id)
  AclService.deleteACL(id)
)

bus.private("acl.all").retrieve('user').on((req, user)->
  if not user.isAdmin()
    throw {code:-1, message: "Only admin user is allowed get all ACL's."}

  AclService.allACL()
)

bus.private("acl.objects").retrieve('user').on((req, user)->
  if not user.isAdmin()
    throw {code:-1, message: "Only admin user is allowed to get all ACL objects."}

  AclService.allObjects()
)
