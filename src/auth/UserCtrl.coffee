bus             = require('WeaverBus')
UserService     = require('UserService')
AclService      = require('AclService')
RoleService     = require('RoleService')
ProjectService  = require('ProjectService')
AdminUser       = require('AdminUser')
logger          = require('logger')
config          = require('config')
Weaver          = require('weaver-sdk')

# All private routes require a signed in user that is loaded in this handler based on authToken
bus.private("*").priority(1000).retrieve('user').on((req, user) ->
)

bus.provide("user").require('authToken').on((req, authToken) ->
  logger.usage.silly "Getting user for authtoken #{authToken}"
  if AdminUser.hasAuthToken(authToken)
    logger.usage.silly "Getting user for authtoken #{authToken}: admin"
    AdminUser
  else
    user = UserService.getUser(authToken)
    logger.code.silly "Getting user for authToken #{authToken}: #{user.username}"
    user.isAdmin = -> false
    user
)

# Get all users
bus.private("users").retrieve('user').on((req, user)->
  if not user.isAdmin()
    logger.auth.error("Only admin user is allowed to get all users.")
    throw {code:-1, message: "Only admin user is allowed to get all users."}

  UserService.all()
)

bus.private("projectUsers").retrieve('user', 'project').on((req, user, project) ->
  logger.usage.silly "Got request from user #{user} for members of project #{project.id}"
  projectAcl = AclService.getACLByObject(project.id)
  AclService.assertACLReadPermission(user, projectAcl.id)
  userIds = AclService.getAllowedUsers(projectAcl, true)
  result = []
  for i in userIds
    try
      result.push(UserService.get(i))
    catch
      #noop
  result
)

registerUser = (userId, username, password, email, firstname, lastname)->
  logger.usage.debug "User signup for #{username}"
  if AdminUser.hasUsername(username) or AdminUser.hasUserId(userId)
    logger.auth.warn("Attempt to sign up with Admin.")
    throw {code:-1, message: "Admin user is not allowed to signup."}

  if username.length < 2
    logger.auth.warn("Sign up attempt username must be 2 characters minimum: #{username}")
    throw {code:-1, message: "Username must be 2 characters minimum"}

  if username.indexOf(' ') >= 0
    logger.auth.warn("Sign up attempt username may not contain spaces: #{username}")
    throw {code:-1, message: "Username may not contain spaces"}

  if password.length < 6
    logger.auth.warn("Sign up attempt Password must be 6 characters minimum")
    throw {code:-1, message: "Password must be 6 characters minimum"}

  logger.usage.info "User signup for #{username} - passed checks"

  UserService.signUp(userId, username, email, password, firstname, lastname)

# Sign up a new user.
if config.get('application.openUserCreation')
  logger.config.warn "User account creation is open to all"
  bus.public("user.signUp")
  .require('userId', 'username', 'password')
  .optional('email', 'firstname', 'lastname')
  .on((req, userId, username, password, email, firstname, lastname)->
    registerUser(userId, username, password, email, firstname, lastname)
  )
else
  logger.config.warn "User account creation is only available to those with permission"
  bus.private("user.signUp")
  .retrieve('user')
  .require('userId', 'username', 'password')
  .optional('email', 'firstname', 'lastname')
  .on((req, user, userId, username, password, email, firstname, lastname)->
    logger.usage.info "User #{user.username} is trying to create account for #{username}"
    AclService.assertServerFunctionPermission(user, 'create-users')
    registerUser(userId, username, password, email, firstname, lastname)
  )

# Sign in existing user
bus.public("user.signInUsername").require('username', 'password').on((req, username, password) ->
  if typeof username isnt 'string' || not /^[a-zA-Z0-9_-]*$/.test(username) ||  not username
    logger.auth.error("Invalid Sign up attempt with invalid username: #{username}")
    throw {code: Weaver.Error.INVALID_USERNAME_PASSWORD, message: "Invalid Username or Password"}
  else
    AdminUser.signInUsername(username, password)
    .then((res) =>
      if res
        logger.auth.warn("Admin user signed in")
        return AdminUser.getAuthToken()
      else
        UserService.signInUsername(username, password)
    )
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
bus.private("user.roles").retrieve('user').require('id').on((req, user, id) ->
  AclService.assertServerFunctionPermission(user, 'create-users') if user.userId isnt id
  RoleService.getRolesForUser(id)
)

bus.private("user.projects").retrieve('user').require('id').on((req, user, id) ->
  if not user.isAdmin() and user.userId isnt id
    throw {code: -1, message: 'Permission denied'}

  if user.userId is id
    return ProjectService.getProjectsForUser(user)
  else
    proxyUser =
      userId: id
      isAdmin: -> false

    return ProjectService.getProjectsForUser(proxyUser)
)



# Destroy user
bus.private("user.delete").retrieve('user').require('id').on((req, user, id) ->
  AclService.assertServerFunctionPermission(user, 'create-users')

  if AdminUser.id is id
    throw {code:-1, message: "Admin user can not be deleted."}

  UserService.destroy(id)
  return
)

bus.private('user.update').retrieve('user').require('update').on((req, user, update) ->
  AclService.assertServerFunctionPermission(user, 'create-users') if user.userId isnt update.userId

  UserService.update(update)
)

bus.private('user.changePassword').retrieve('user').require('userId', 'password').on((req, user, userId, password) ->
  AclService.assertServerFunctionPermission(user, 'create-users') if user.userId isnt userId

  UserService.changePassword(userId, password)
)

# Wipe of all users
bus.private('users.wipe')
.retrieve('user')
.enable(config.get('application.wipe'))
.on((req, user) ->

  if not user.isAdmin()
    throw {code: -1, message: 'Permission denied'}

  logger.usage.info "Wiping all users on weaver server"

  Promise.all([
    UserService.wipe()
    RoleService.wipe()
  ])
)
