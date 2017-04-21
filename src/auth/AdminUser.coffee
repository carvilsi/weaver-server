conf = require('config')
jwt  = require('jsonwebtoken')

adminUser = conf.get('admin.username')
adminPass = conf.get('admin.password')
secret = conf.get('auth.secret')
expiresIn = conf.get('auth.expire')

authTokens = {}

class AdminUser

  constructor: (@username) ->
    @id = @username

  hasUsername: (username) ->
    @username is username

  signInUsername: (username, password) ->
    username is @username and password is adminPass

  signInToken: (authToken) ->
    payload = @verifyToken(authToken)
    if(payload.admin)
      authTokens[authToken] = true
      authToken
    else
      false

  signOut: (authToken) ->
    delete authTokens[authToken]

  hasAuthToken: (authToken) ->
    authTokens[authToken] is true

  getAuthToken: ->
    authToken = jwt.sign(
      { username: adminUser, admin: true },
      secret,
      { expiresIn }
    )
    authTokens[authToken] = true
    authToken

  isAdmin: ->
    true

  verifyToken: (authToken) ->
    try
      jwt.verify(authToken, secret)
    catch error
      throw {code: -1, message: "Invalid token supplied #{authToken}"}

module.exports = new AdminUser(adminUser)
