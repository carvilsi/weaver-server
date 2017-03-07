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
      acl:      ['object']
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
      objects:     [objectId]
      userRead:    []
      userWrite:   [user.username]
      userManage:  []
      roleRead:    []
      roleWrite:   []
      roleManage:  []
      publicRead:  false
      publicWrite: false

    aclDoc = @acl.insert(acl)
    aclDoc


  getACL: (aclId) ->
    acl = @acl.findOne({id: aclId})
    acl

  getACLByObject: (objectId) ->
    acl = @acl.findOne({object: objectId})
    acl

  setACL: (values) ->
    return

  ###
  # DAMN ik ben hier nu te  moe voor
  ###

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

    # Add users from given role
    getUsersFromRole = (acl) =>
      for roleId in acl.roleRead
        role = @getRole(roleId)
        users[u] = null for u in role.users

        # Recursively go down the roles
        # TODO: Breaks when circular
        getUsersFromRole(r) for r in role.roles


    getUsersFromRole(acl)

    # Return array
    (key for key of users)





  assertACLReadPermission: (user, aclId) ->
    acl = @getACL(aclId)
    getAllowedUsers(acl)
    # fuuuuuck -> array in lokijs, hoe werkt dat
    true

  assertAClWritePermission: (user, aclId) ->
    true

  assertObjectReadPermission: (user, objectId) ->
    true

  assertObjectWritePermission: (user, objectId) ->
    true

module.exports = new UserService()
