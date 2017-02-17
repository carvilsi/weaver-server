LokiService = require('LokiService')
cuid        = require('cuid')
_           = require('lodash')

class UserService extends LokiService

  constructor: ->
    super('users',
      users:    ['username', 'email']
      sessions: ['authToken']
      roles:    []
      acl:      []
      nodes:    []
    )

  signUp: (userId, username, email, password) ->
    if @users.find({username}).length isnt 0
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

    user = @users.find({username: session.username})[0]
    _.omit(user, ['password'])


  signOut: (authToken) ->
    # TODO: Google how to delete in loki
    return

  destroy: (user) ->
    username = user.username
    # TODO: Google how to delete in loki
    return


module.exports = new UserService()
