bus             = require('WeaverBus')
UserService     = require('UserService')
AclService      = require('AclService')


# All private routes require a signed in user that is loaded in this handler based on authToken
bus.private("*").priority(1000).retrieve('user').on((req, user) ->
)

bus.provide("user").require('authToken').on((req, authToken) ->
  UserService.getUser(authToken)
)


# Sign up a new user.
bus.public("user.signUp").require('userId', 'username', 'password', 'email').on((req, userId, username, password, email)->
  UserService.signUp(userId, username, email, password)
)

# Sign in existing user
bus.public("user.signIn").require('username', 'password').on((req, username, password) ->
  UserService.signIn(username, password)
)

# Sign out current signed in user
bus.private("user.signOut").require('authToken').on((req, authToken) ->
  UserService.signOut(authToken)
  return
)

# Gives back user object that is currently signed in
bus.private("user.read").retrieve('user').on((req, user) ->
  user
)

# Destroy user
bus.private("user.delete").retrieve('user').on((req, user) ->
  UserService.destroy(user)
  return
)
