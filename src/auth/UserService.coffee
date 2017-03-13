conf        = require('config')
LokiService = require('LokiService')
cuid        = require('cuid')
_           = require('lodash')

adminUser   = conf.get('admin.username')
adminPass   = conf.get('admin.password')

class UserService extends LokiService

  constructor: ->
    super('users',
      users:    ['username', 'email']
      sessions: ['authToken']
      acl:      []
      objects:  ['acl']
      roles:    ['users', 'roles']
    )


  signUp: (userId, username, email, password) ->
    userExists = @users.findOne({username})? or username is adminUser

    if userExists
      throw {code:-1, message: "User with username #{username} already exists"}

    @users.insert({userId, username, email, password})
    @signIn(username, password)


  signIn: (username, password) ->
    # There is always an admin user
    grantedAdmin = username is adminUser and password is adminPass

    if not grantedAdmin
      user = @users.find({username})[0]

      if not user?
        throw {code: -1, message: "User not found"}

      if user.password isnt password
        throw {code: -1, message: "Password incorrect"}

    authToken = cuid()
    sessionId = cuid()
    @sessions.insert({sessionId, authToken, username})

    # Should create the admin user here when not created
    # TODO Must change so that admin is created
    authToken


  getUser: (authToken) ->
    session = @sessions.find({authToken})[0]
    if not session?
      throw {code: -1, message: "No session found for authToken #{authToken}"}

    # Hack
    return {username: adminUser} if session.username is adminUser

    user = @users.findOne({username: session.username})
    _.omit(user, ['password'])


  signOut: (authToken) ->
    # TODO: Google how to delete in loki
    return


  destroy: (user) ->
    #username = user.username
    @users.remove(user)
    # TODO: Google how to delete in loki
    return


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


  createRole: (role, user) ->
    roleId = role.roleId

    if @roles.find({roleId}).length isnt 0
      throw {code:-1, message: "Role with id #{roleId} already exists"}

    # Create ACL for this user
    acl = @createACL(roleId, user.username)

    @roles.insert({
      roleId: role.roleId
      name: role.name
      users: role._users
      roles: role._roles
      acl: acl.id
    })





  getACL: (aclId) ->
    acl = @acl.findOne({id: aclId})
    acl

  getACLByObjects: (objects) ->
    (@getACLByObject(id) for id in objects)

  getACLByObject: (objectId) ->
    object = @objects.findOne({id: objectId})
    acl    = @acl.findOne({id: object.acl})
    acl

  setACL: (values) ->
    return

  getRole: (roleId) ->
    role = @roles.findOne({roleId})
    role

  getUsersFromRole: (roleId) ->
    role = @getRole(roleId)
    users[u] = null for u in role.users

    # Recursively go down the roles
    # TODO: Breaks when circular
    @getUsersFromRole(r, level) for r in role.roles

  getAllowedUsers: (acl) ->

    # Use object to easily avoid duplicates
    users = {}

    # Add all direct users
    users[u] = null for u in acl.userRead
    users[u] = null for u in acl.userWrite

    # Add users from given role
    getUsersFromRole = (acl) =>
      for roleId in acl.roleRead
        role = @getRole(roleId)

        console.log(role)

        users[u] = null for u in role.users

        # Recursively go down the roles
        # TODO: Breaks when circular
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
        role = @getRole(roleId)

        console.log(role)

        users[u] = null for u in role.users

        # Recursively go down the roles
        # TODO: Breaks when circular
        getUsersFromRole(r) for r in role.roles


    getUsersFromRole(acl)

    # Return array
    (key for key of users)



  writeACL: (aclServerObject) ->
    ###
  { _id: 'cj081ufb5000clmxkr4qaq2cw',
  _objects: [],
  _publicRead: false,
  _publicWrite: false,
  _userReadMap: {},
  _userWriteMap: { admin: null },
  _roleReadMap: { cj081ufdc0006mcxkdo3otxwq: true },
  _roleWriteMap: {},
  _created: true,
  _deleted: false,
  _userRead: [],
  _userWrite: [],
  _roleRead: [ 'cj081ufdc0006mcxkdo3otxwq' ],
  _roleWrite: [] }


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
###

    acl = @acl.findOne({id: aclServerObject._id})
    acl.publicRead  = aclServerObject._publicRead
    acl.publicWrite = aclServerObject._publicWrite

    acl.userRead  = aclServerObject._userRead
    acl.userWrite = aclServerObject._userWrite
    acl.roleRead  = aclServerObject._roleRead
    acl.roleWrite = aclServerObject._roleWrite

    @acl.update(acl)
    #console.log(acl)
    return


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


    true

  assertObjectReadPermission: (user, objectId) ->
    true

  assertObjectWritePermission: (user, objectId) ->
    true

module.exports = new UserService()
