conf = require('config')
cuid = require('cuid')

adminUser = conf.get('admin.username')
adminPass = conf.get('admin.password')

authTokens = {}

class AdminUser

  constructor: (@username) ->

  hasUsername: (username) ->
    @username is username

  signIn: (username, password) ->
    username is @username and password is adminPass

  signOut: (authToken) ->
    delete authTokens[authToken]

  hasAuthToken: (authToken) ->
    authTokens[authToken] is true

  getAuthToken: ->
    authToken = cuid()
    authTokens[authToken] = true
    authToken

  isAdmin: ->
    true

module.exports = new AdminUser(adminUser)
