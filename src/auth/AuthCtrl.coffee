bus             = require('WeaverBus')
UserService     = require('UserService')
AclService      = require('AclService')
ProjectService  = require('ProjectService')
DatabaseService = require('DatabaseService')


# Sign up a new user.
bus.public("auth.signUp").require('userId', 'username', 'password', 'email').on((req, userId, username, password, email)->
  UserService.signUp(userId, username, email, password)
)

# Sign in existing user
bus.public("auth.signIn").require('username', 'password').on((req, username, password) ->
  UserService.signIn(username, password)
)

# All private routes require a signed in user that is loaded in this handler based on authToken
bus.private("*").priority(1000).retrieve('user').on((req, user) ->
  return
)

bus.provide("user").require('authToken').on((req, authToken) ->
  UserService.getUser(authToken)
)

bus.provide("project").require('target').on((req, target) ->
  ProjectService.get(target)
)

bus.provide("database").retrieve('user', 'project').on((req, user, project) ->
  AclService.assertACLReadPermission(user, project.acl)
  new DatabaseService(project.endpoint)
)

# Gives back user object that is currently signed in
bus.private("auth.getUser").retrieve('user').on((req, user) ->
  user
)

# Sign out current signed in user
bus.private("auth.signOut").require('authToken').on((req, authToken) ->
  UserService.signOut(authToken)
  return
)

# Destroy user
bus.private("auth.destroyUser").retrieve('user').on((req, user) ->
  UserService.destroy(user)
  return
)
