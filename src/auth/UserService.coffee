conf        = require('config')
LokiService = require('LokiService')
cuid        = require('cuid')
_           = require('lodash')
jwt         = require('jsonwebtoken')

secret = conf.get('auth.secret')
expiresIn = conf.get('auth.expire')

class UserService extends LokiService

  constructor: ->
    super('users',
      users:    ['username', 'email']
      sessions: ['authToken']
    )

  all: ->
    users = []
    for u in @users.find()
      users.push({
        username: u.username
        email: u.email
        userId: u.userId
        })

    users

  signUp: (userId, username, email, password) ->
    userExists = @users.findOne({username})?

    if userExists
      throw {code:-1, message: "User with username #{username} already exists"}

    @users.insert({userId, username, email, password})
    @signInUsername(username, password)

  insertSession: (authToken, username) ->
    sessionId = cuid()
    @sessions.insert({sessionId, authToken, username})

  signInUsername: (username, password) ->
    user = @users.find({username})[0]
    if not user?
      throw {code: -1, message: "User not found"}

    if user.password isnt password
      throw {code: -1, message: "Password incorrect"}

    # Sign token with secret set in config and add username to payload
    authToken = jwt.sign({ username }, secret, { expiresIn })
    @insertSession(authToken, username)

    authToken

  # Sign user in using a token.
  signInToken: (authToken) ->
    payload = @verifyToken(authToken)
    username = payload.username
    @insertSession(authToken, username)

    authToken

  getUser: (authToken) ->
    session = @sessions.find({authToken})[0]
    if not session?
      throw {code: -1, message: "No session found for authToken #{authToken}"}

    # Check if the token is still valid. If not -> throw error
    @verifyToken(authToken)

    user = @users.findOne({username: session.username})
    _.omit(user, ['password'])

  signOut: (authToken) ->
    session = @sessions.findOne({authToken})
    @sessions.remove(session)

  destroy: (username) ->
    user = @users.findOne({username})
    @users.remove(user)

  update: (update) ->
    # TODO Lots of checking (is the username/email correct?, does the user exist? etc)
    user = @users.findOne({userId: update.userId})
    user.username = update.username
    user.email    = update.email
    @users.update(user)
    return

  # Verify if the token is valid and not expired. if not -> throw error
  verifyToken: (authToken) ->
    try
      jwt.verify(authToken, secret)
    catch error
      throw {code: -1, message: "Invalid token supplied #{authToken}"}

module.exports = new UserService()
