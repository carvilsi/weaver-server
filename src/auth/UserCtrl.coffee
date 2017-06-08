bus             = require('WeaverBus')
UserService     = require('UserService')
AclService      = require('AclService')
RoleService     = require('RoleService')
AdminUser       = require('AdminUser')
logger          = require('logger')
config          = require('config')

# All private routes require a signed in user that is loaded in this handler based on authToken
bus.private("*").priority(1000).retrieve('user').on((req, user) ->
)


bus.provide("user").require('authToken').on((req, authToken) ->
  if AdminUser.hasAuthToken(authToken)
    AdminUser
  else
    user = UserService.getUser(authToken)
    user.isAdmin = -> false
    user
)


# Get all users
bus.private("users").retrieve('user').on((req, user)->
  if not user.isAdmin()
    throw {code:-1, message: "Only admin user is allowed to get all users."}

  UserService.all()
)

# Sign up a new user.
bus.public("user.signUp").require('userId', 'username', 'password', 'email').on((req, userId, username, password, email)->

  if AdminUser.hasUsername(username)
    throw {code:-1, message: "Admin user is not allowed to signup."}

  if username.length < 2
    throw {code:-1, message: "Username must be 2 characters minimum"}

  if username.indexOf(' ') >= 0
    throw {code:-1, message: "Username may not contain spaces"}

  if password.length < 6
    throw {code:-1, message: "Password must be 6 characters minimum"}

  UserService.signUp(userId, username, email, password)
)


# Sign in existing user
bus.public("user.signInUsername").require('username', 'password').on((req, username, password) ->
  if typeof username isnt 'string'
    throw {code:-1, message: "Username not valid"}
  else
    if AdminUser.signInUsername(username, password)
      return AdminUser.getAuthToken()
    else
      UserService.signInUsername(username, password)
)

bus.public("user.signInToken").require('authToken').on((req, authToken) ->
  if AdminUser.signInToken(authToken)
    return AdminUser.getAuthToken()
  else
    UserService.signInToken(authToken)
)


# Sign out current signed in user
bus.private("user.signOut").require('authToken').on((req, authToken) ->
  if AdminUser.hasAuthToken(authToken)
    AdminUser.signOut(authToken)
  else
    UserService.signOut(authToken)

  return
)


# Gives back user object that is currently signed in
bus.private("user.read").retrieve('user').on((req, user) ->
  user
)

# Gives back user object that is currently signed in
bus.private("user.roles").require('id').on((req, id) ->
  # TODO: Check permissions
  RoleService.getRolesForUser(id)
)


# Destroy user
bus.private("user.delete").retrieve('user').require('username').on((req, user, username) ->

  if AdminUser.hasUsername(username)
    throw {code:-1, message: "Admin user can not be deleted."}

  UserService.destroy(username)
  return
)

bus.private('user.update').retrieve('user').require('update').on((req, user, update) ->
  UserService.update(update)
)

# Wipe of all users
bus.public('users.wipe').enable(config.get('application.wipe')).on((req) ->

  logger.usage.info "Wiping all users on weaver server"

  Promise.all([
    UserService.wipe()
    AclService.wipe()
    RoleService.wipe()
  ])
)
