conf = require('config')
jwt  = require('jsonwebtoken')

adminUser = conf.get('admin.username')
adminPass = conf.get('admin.password')
secret = conf.get('auth.secret')
expiresIn = conf.get('auth.expire')
bcrypt = require('bcrypt')
logger = require('logger')

authTokens = {}

class AdminUser

  constructor: (@username) ->
    @userId = 'root'

  hasUsername: (username) ->
    @username is username

  hasUserId: (id) ->
    @userId is id

  signInUsername: (username, password) ->
    bcrypt.compare(password,adminPass)
    .then((res) =>
      username is @username and res
    )

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
      logger.auth.error("Invalid token supplied #{authToken}")
      throw {code: -1, message: "Invalid token supplied #{authToken}"}

module.exports = new AdminUser(adminUser)
