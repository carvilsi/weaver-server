LokiService = require('LokiService')
cuid        = require('cuid')

class UserService extends LokiService

  constructor: ->
    super('users',
      users:    ['username', 'email']
      sessions: []
      roles:    []
      acl:      []
      nodes:    []
    )

  userExists: (username) ->
    @users.find({username}).length isnt 0

  getUserBySessionId: (sessionId) ->
    session = @sessions.find({sessionId})[0]
    if not session?
      throw {code: -1, message: "Invalid session id #{sessionId}"}

    user = @users.find({username: session.username})[0]
    user

  addUser: (userId, username, email, password) ->
    @users.insert({userId, username, email, password})

  deleteUser: (username) ->
    return

  signIn: (username, password) ->
    user = @users.find({username})[0]
    if user.password isnt password
      throw {code: -1, message: "Password incorrect"}

    sessionId = cuid()
    @sessions.insert({sessionId, username})
    sessionId

  signOff: (session) ->


module.exports = new UserService()
