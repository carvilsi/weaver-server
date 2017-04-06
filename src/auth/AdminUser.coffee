conf = require('config')
jwt  = require('jsonwebtoken')

adminUser = conf.get('admin.username')
adminPass = conf.get('admin.password')

authTokens = {}

class AdminUser

  constructor: (@username) ->
    @id = @username

  hasUsername: (username) ->
    @username is username

  signIn: (username, password) ->
    username is @username and password is adminPass

  signOut: (authToken) ->
    delete authTokens[authToken]

  hasAuthToken: (authToken) ->
    authTokens[authToken] is true

  getAuthToken: ->
    authToken = jwt.sign(
      { test: "token" },
      conf.get("auth.secret"),
      { expiresIn: conf.get("auth.expire") }
    )
    authTokens[authToken] = true
    authToken

  isAdmin: ->
    true

module.exports = new AdminUser(adminUser)
