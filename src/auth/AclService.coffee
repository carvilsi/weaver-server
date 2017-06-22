conf        = require('config')
LokiService = require('LokiService')
RoleService = require('RoleService')
cuid        = require('cuid')
_           = require('lodash')
logger      = require('logger')


class AclService extends LokiService
  serverFunctionACLs: [
    'create-projects',
    'modify-acl',
    'create-users'
  ]

  projectFunctionACLs: [
    'delete-project'
  ]

  constructor: ->
    super('acl',
      acl:      ['id']
      objects:  ['acl']
    )

  load: ->
    super().then(=>
      @createServerFunctionACLs()
    )

  createServerFunctionACLs: ->
    logger.code.debug "Initializing server function ACLs"
    for functionACL in @serverFunctionACLs
      @createFunctionACL(functionACL) if !@getACL(functionACL)?

  createFunctionACL: (functionACL) ->
    logger.code.debug "Creating server function ACL: #{functionACL}"
    acl =
      id: functionACL
      userRead: []
      userWrite: []
      roleRead: []
      roleWrite: []
      publicRead: false
      publicWrite: false

    @acl.insert(acl)

  getProjectFunctionAclId: (projectId, functionname) ->
    "project-#{projectId}-function-#{functionname}"

  createProjectACLs: (projectId, user) ->
    logger.usage.info "Creating ACLs for project #{projectId}"
    acl = @createACL(projectId, user)
    for projectFunctionAcl in @projectFunctionACLs
      delAcl = @createFunctionACL(@getProjectFunctionAclId(projectId, projectFunctionAcl))
      delAcl.userWrite.push(user.userId)
      @acl.update(delAcl)
    acl

  checkProjectAcl: (projectId) ->
    logger.code.info "Checking existence of function ACLs for project: #{projectId}"
    for f in @projectFunctionACLs
      id = @getProjectFunctionAclId(projectId, f)
      @createFunctionACL(id) if !getACL(id)?

  createACL: (objectId, user) ->
    acl =
      id:          cuid()
      userRead:    []
      userWrite:   [user.userId]
      roleRead:    []
      roleWrite:   []
      publicRead:  false
      publicWrite: false

    @objects.insert({id: objectId, acl: acl.id})
    aclDoc = @acl.insert(acl)
    logger.code.silly "Created ACL with id #{acl.id} for object #{objectId}"
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

    logger.code.silly "Created ACL with id #{acl.id} from aclServerObject"
    @acl.insert(acl)


  getACL: (aclId) ->
    result = @acl.findOne({id: aclId})
    logger.code.debug "getACL(#{aclId}) result: #{JSON.stringify(result)}"
    result

  getACLByObject: (objectId) ->
    object = @objects.findOne({id: objectId})
    logger.code.debug "getACLByObject(#{objectId}): #{object}"
    @getACL(object.acl)


  updateACL: (aclServerObject) ->
    acl = @acl.findOne({id: aclServerObject._id})
    logger.usage.debug "Updating acl #{acl.id}"

    acl.publicRead  = aclServerObject._publicRead
    acl.publicWrite = aclServerObject._publicWrite
    acl.userRead    = aclServerObject._userRead
    acl.userWrite   = aclServerObject._userWrite
    acl.roleRead    = aclServerObject._roleRead
    acl.roleWrite   = aclServerObject._roleWrite

    @acl.update(acl)


  getAllowedUsers: (acl, readOnly) ->
    # Use object to easily avoid duplicates
    users = {}

    # Add all direct users
    users[u] = null for u in acl.userRead if readOnly
    users[u] = null for u in acl.userWrite

    roles = if readOnly then acl.roleRead.concat(acl.roleWrite) else acl.roleWrite

    usersFromRole = RoleService.getUsersFromRoles(roles)
    users[u] = null for u in usersFromRole

    (user for user of users)


  assertACLPermission: (user, aclId, readOnly) ->
    return if user.isAdmin()
    logger.usage.silly "Checking acl access for user #{user.username} on #{aclId}"

    acl = @getACL(aclId)
    allowedUsers = @getAllowedUsers(acl, readOnly)

    denied = allowedUsers.indexOf(user.userId) is -1
    if denied
      throw {code: -1, message: "Permission denied for #{user.username}"}


  assertACLReadPermission: (user, aclId) ->
    @assertACLPermission(user, aclId, true)


  assertACLWritePermission: (user, aclId) ->
    @assertACLPermission(user, aclId, false)

  allACL: ->
    @acl.find()

  allObjects: ->
    @objects.find()

  wipe: ->
    logger.usage.warn "Wiping ACL Service"
    super()
    @createServerFunctionACLs()

module.exports = new AclService()
