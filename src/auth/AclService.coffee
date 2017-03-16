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
      acl:      ['id']
      objects:  ['acl']
    )


  createACL: (objectId, user) ->
    acl =
      id:          cuid()
      userRead:    []
      userWrite:   [user.username]
      roleRead:    []
      roleWrite:   []
      publicRead:  false
      publicWrite: false

    @objects.insert({id: objectId, acl: acl.id})
    aclDoc = @acl.insert(acl)
    aclDoc


  createACLFromServer: (aclServerObject) ->
    acl =
      id          : aclServerObject._id
      publicRead  : aclServerObject._publicRead
      publicWrite : aclServerObject._publicWrite
      userRead    : aclServerObject._userRead
      userWrite   : aclServerObject._userWrite
      roleRead    : aclServerObject._roleRead
      roleWrite   : aclServerObject._roleWrite

    @acl.insert(acl)


  getACL: (aclId) ->
    @acl.findOne({id: aclId})


  getACLByObject: (objectId) ->
    object = @objects.findOne({id: objectId})
    @getACL(object.acl)


  updateACL: (aclServerObject) ->
    acl = @acl.findOne({id: aclServerObject._id})
    acl.publicRead  = aclServerObject._publicRead
    acl.publicWrite = aclServerObject._publicWrite
    acl.userRead    = aclServerObject._userRead
    acl.userWrite   = aclServerObject._userWrite
    acl.roleRead    = aclServerObject._roleRead
    acl.roleWrite   = aclServerObject._roleWrite

    @acl.update(acl)


  getAllowedUsers: (acl, writeAllowed) ->

    writeAllowed = writeAllowed or false

    # Use object to easily avoid duplicates
    users = {}

    # Add all direct users
    users[u] = null for u in acl.userRead
    users[u] = null for u in acl.userWrite if writeAllowed

    if writeAllowed
      RoleService.getUsersFromRoles(acl.roleWrite)
    else
      RoleService.getUsersFromRoles(acl.roleRead.concat(acl.roleWrite))


  assertACLPermission: (user, aclId, writeAllowed) ->
    return if user.username is adminUser

    acl = @getACL(aclId)
    allowedUsers = @getAllowedUsers(acl, writeAllowed)

    denied = allowedUsers.indexOf(user.userId) is -1
    if denied
      throw {code: -1, message: "Permission denied for #{user.username}"}


  assertACLReadPermission: (user, aclId) ->
    @assertACLPermission(user, aclId, false)


  assertACLWritePermission: (user, aclId) ->
    @assertACLPermission(user, aclId, true)


module.exports = new AclService()
