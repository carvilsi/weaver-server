conf        = require('config')
LokiService = require('LokiService')
RoleService = require('RoleService')
cuid        = require('cuid')
_           = require('lodash')

adminUser   = conf.get('admin.username')
adminPass   = conf.get('admin.password')

class AclService extends LokiService

  constructor: ->
    super('acl',
      acl:      []
      objects:  ['acl']
    )

  createACL: (objectId, user) ->
    acl =
      id:          cuid()
      userRead:    []
      userWrite:   [user.username]
      userManage:  []
      roleRead:    []
      roleWrite:   []
      roleManage:  []
      publicRead:  false
      publicWrite: false

    @objects.insert({id: objectId, acl: acl.id})
    aclDoc = @acl.insert(acl)
    aclDoc



  getACL: (aclId) ->
    @acl.findOne({id: aclId})


  getACLByObject: (objectId) ->
    object = @objects.findOne({id: objectId})
    acl    = @acl.findOne({id: object.acl})
    acl


  writeACL: (aclServerObject) ->
    acl = @acl.findOne({id: aclServerObject._id})
    acl.publicRead  = aclServerObject._publicRead
    acl.publicWrite = aclServerObject._publicWrite
    acl.userRead    = aclServerObject._userRead
    acl.userWrite   = aclServerObject._userWrite
    acl.roleRead    = aclServerObject._roleRead
    acl.roleWrite   = aclServerObject._roleWrite

    @acl.update(acl)


  storeACL: (aclServerObject) ->
    acl =
      id          : aclServerObject._id
      publicRead  : aclServerObject._publicRead
      publicWrite : aclServerObject._publicWrite
      userRead    : aclServerObject._userRead
      userWrite   : aclServerObject._userWrite
      roleRead    : aclServerObject._roleRead
      roleWrite   : aclServerObject._roleWrite

    @acl.insert(acl)



  getAllowedUsers: (acl) ->

   # Use object to easily avoid duplicates
    users = {}

    # Add all direct users
    users[u] = null for u in acl.userRead
    users[u] = null for u in acl.userWrite

    # Add users from given role
    getUsersFromRole = (acl) =>
      for roleId in acl.roleRead
        role = RoleService.getRole(roleId)

        users[u] = null for u in role.users

        # Recursively go down the roles
        # TODO: Fix that this breaks when circular dependency
        getUsersFromRole(r) for r in role.roles


    getUsersFromRole(acl)

    # Return array
    (key for key of users)


  getAllowedWriteUsers: (acl) ->

    # Use object to easily avoid duplicates
    users = {}

    # Add all direct users
    users[u] = null for u in acl.userWrite

    # Add users from given role
    getUsersFromRole = (acl) =>
      for roleId in acl.roleWrite
        role = RoleService.getRole(roleId)

        users[u] = null for u in role.users

        # Recursively go down the roles
        # TODO: Fix that this breaks when circular dependency
        getUsersFromRole(r) for r in role.roles


    getUsersFromRole(acl)

    # Return array
    (key for key of users)


  assertACLReadPermission: (user, aclId) ->
    return if user.username is adminUser

    acl = @getACL(aclId)
    allowedUsers = @getAllowedUsers(acl)

    denied = allowedUsers.indexOf(user.userId) is -1
    if denied
      throw {code: -1, message: "User #{user.username} has no read permission for ACL #{aclId}"}


  assertACLWritePermission: (user, aclId) ->
    return if user.username is adminUser

    acl = @getACL(aclId)
    allowedUsers = @getAllowedWriteUsers(acl)

    denied = allowedUsers.indexOf(user.userId) is -1
    if denied
      throw {code: -1, message: "User #{user.username} has no write permission for ACL #{aclId}"}


module.exports = new AclService()
