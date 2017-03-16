bus             = require('WeaverBus')
UserService     = require('UserService')
AclService      = require('AclService')
AdminUser       = require('AdminUser')


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


# Sign up a new user.
bus.public("user.signUp").require('userId', 'username', 'password', 'email').on((req, userId, username, password, email)->

  if AdminUser.hasUsername(username)
    throw {code:-1, message: "Admin user is not allowed to signup."}

  UserService.signUp(userId, username, email, password)
)


# Sign in existing user
bus.public("user.signIn").require('username', 'password').on((req, username, password) ->

  if AdminUser.signIn(username, password)
    return AdminUser.getAuthToken()
  else
    UserService.signIn(username, password)
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


# Destroy user
bus.private("user.delete").retrieve('user').on((req, user) ->

  if AdminUser.hasUsername(user.username)
    throw {code:-1, message: "Admin user can not be deleted."}

  UserService.destroy(user)
  return
)
