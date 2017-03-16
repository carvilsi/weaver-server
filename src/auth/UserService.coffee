conf        = require('config')
LokiService = require('LokiService')
cuid        = require('cuid')
_           = require('lodash')

class UserService extends LokiService

  constructor: ->
    super('users',
      users:    ['username', 'email']
      sessions: ['authToken']
    )

  signUp: (userId, username, email, password) ->
    userExists = @users.findOne({username})?

    if userExists
      throw {code:-1, message: "User with username #{username} already exists"}

    @users.insert({userId, username, email, password})
    @signIn(username, password)


  signIn: (username, password) ->
    user = @users.find({username})[0]

    if not user?
      throw {code: -1, message: "User not found"}

    if user.password isnt password
      throw {code: -1, message: "Password incorrect"}

    authToken = cuid()
    sessionId = cuid()
    @sessions.insert({sessionId, authToken, username})

    authToken


  getUser: (authToken) ->
    session = @sessions.find({authToken})[0]
    if not session?
      throw {code: -1, message: "No session found for authToken #{authToken}"}

    user = @users.findOne({username: session.username})
    _.omit(user, ['password'])

  signOut: (authToken) ->
    session = @sessions.findOne({authToken})
    @sessions.remove(session)

  destroy: (user) ->
    @users.remove(user)


module.exports = new UserService()
