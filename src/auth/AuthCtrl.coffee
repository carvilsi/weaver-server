bus             = require('WeaverBus')
UserService     = require('UserService')
ProjectService  = require('ProjectService')
DatabaseService = require('DatabaseService')


# Sign up a new user.
bus.public("auth.signUp").require('userId', 'username', 'password', 'email').on((req, userId, username, password, email)->
  authToken = UserService.signUp(userId, username, email, password)
  authToken
)

# Sign in existing user
bus.public("auth.signIn").require('username', 'password').on((req, username, password) ->
  authToken = UserService.signIn(username, password)
  authToken
)

# All private routes require a signed in user that is loaded in this handler based on authToken
bus.private("*").priority(1000).retrieve('user').on((req, user) ->
  req.state.user = user
  return
)

bus.provide("user").require('authToken').on((req, authToken) ->
  UserService.getUser(authToken)
)

bus.provide("project").require('target').on((req, target) ->
  ProjectService.get(target)
)

bus.provide("database").retrieve('user', 'project').on((req, user, project) ->
  # Check permission of current user to project
  UserService.assertACLReadPermission(user, project.acl)

  new DatabaseService(project.endpoint)
)

# Gives back user object that is currently signed in
bus.private("auth.getUser").on((req) ->
  req.state.user
)

# Sign out current signed in user
bus.private("auth.signOut").require('authToken').on((req, authToken) ->
  UserService.signOut(authToken)
  return
)

# Destroy user
bus.private("auth.destroyUser").on((req) ->
  UserService.destroy(req.state.user)
  return
)
