conf        = require('config')
LokiService = require('LokiService')
cuid        = require('cuid')
_           = require('lodash')
jwt         = require('jsonwebtoken')

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


  signIn: (args...) ->
    # Check if argument length only contains one param (the token)
    if args.length == 1
      return @signInToken(args[0])

    username = args[0] || null
    password = args[1] || null

    user = @users.find({username})[0]
    if not user?
      throw {code: -1, message: "User not found"}

    if user.password isnt password
      throw {code: -1, message: "Password incorrect"}

    # Sign token with secret set in config and add username to payload
    authToken = jwt.sign(
      { username: username },
      conf.get("auth.secret"),
      { expiresIn: conf.get("auth.expire") }
    )
    sessionId = cuid()
    @sessions.insert({sessionId, authToken, username})

    authToken

  # Sign user in using a token.
  signInToken: (authToken) ->
    if not jwt.verify(authToken, conf.get("auth.secret"))?
      throw {code: -1, message: "Invalid token supplied #{authToken}"}

    payload = jwt.decode(authToken) # JWT payload
    username = payload.username
    sessionId = cuid()
    @sessions.insert({sessionId, authToken, username})

    authToken

  getUser: (authToken) ->
    session = @sessions.find({authToken})[0]
    if not session?
      throw {code: -1, message: "No session found for authToken #{authToken}"}

    # Check if the token is still valid. If not -> throw error
    if not jwt.verify(authToken, conf.get("auth.secret"))?
      throw {code: -1, message: "Invalid token supplied #{authToken}"}

    user = @users.findOne({username: session.username})
    _.omit(user, ['password'])

  signOut: (authToken) ->
    session = @sessions.findOne({authToken})
    @sessions.remove(session)

  destroy: (user) ->
    @users.remove(user)


module.exports = new UserService()
