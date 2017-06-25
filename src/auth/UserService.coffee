conf         = require('config')
LokiService  = require('LokiService')
cuid         = require('cuid')
_            = require('lodash')
jwt          = require('jsonwebtoken')
HashPassInit = require('HashPassInit')

secret = conf.get('auth.secret')
expiresIn = conf.get('auth.expire')
bcrypt = require('bcrypt')

class UserService extends LokiService

  constructor: ->
    super('users',
      users:    ['username', 'email']
      sessions: ['authToken']
    )
    checkPasswords()

  all: ->
    (_.omit(user, ['passwordHash']) for user in @users.find())

  signUp: (userId, username, email, password, firstname, lastname) ->

    if @users.findOne({username})?
      throw {code:-1, message: "User with username #{username} already exists"}

    if @users.findOne({userId})?
      throw {code:-1, message: "User with userId #{userId} already exists"}

    bcrypt.hash(password,conf.get('auth.salt'))
    .then((passwordHash) =>
      @users.insert({userId, username, email, passwordHash, firstname, lastname, active: true})
      @signInUsername(username, password)
    )

  comparePassword =  (plainPassword, passwordHash) ->
    bcrypt.compare(plainPassword,passwordHash)

  changePassword: (userId, password) ->
    user = @users.findOne({userId})
    bcrypt.hash(password, conf.get('auth.salt'))
    .then((passwordHash) =>
      user.passwordHash = passwordHash
      @users.update(user)
    )

  insertSession: (authToken, username) ->
    sessionId = cuid()
    @sessions.insert({sessionId, authToken, username})

  signInUsername: (username, password) ->
    user = @users.find({username})[0]
    if not user?
      comparePassword(username,password)
      .then( ->
        throw {code: -1, message: "Invalid Username or Password"}
      )
    else
      if not user.active
        throw {code: -1, message: "User not active"}

      comparePassword(password, user.passwordHash)
      .then((res) =>
        if !res
          throw {code: -1, message: "Invalid Username or Password"}
        else
          # Sign token with secret set in config and add username to payload
          authToken = jwt.sign({ username }, secret, { expiresIn })
          @insertSession(authToken, username)

          authToken
      )



  # Sign user in using a token.
  signInToken: (authToken) ->
    payload = @verifyToken(authToken)
    username = payload.username

    user = @users.find({username})[0]
    if not user?.active
        throw {code: -1, message: "User not active"}

    @insertSession(authToken, username)

    authToken

  getUser: (authToken) ->
    session = @sessions.find({authToken})[0]
    if not session?
      throw {code: -1, message: "No session found for authToken #{authToken}"}

    # Check if the token is still valid. If not -> throw error
    @verifyToken(authToken)

    user = @users.findOne({username: session.username})
    _.omit(user, ['passwordHash'])

  signOut: (authToken) ->
    session = @sessions.findOne({authToken})
    @sessions.remove(session)

  destroy: (username) ->
    user = @users.findOne({username})
    @users.remove(user)

  update: (update) ->
    # TODO Lots of checking (is the username/email correct?, does the user exist? etc)
    user = @users.findOne({userId: update.userId})
    user.username  = update.username
    user.email     = update.email
    user.firstname = update.firstname
    user.lastname  = update.lastname
    user.active    = update.active
    @users.update(user)
    return

  # Verify if the token is valid and not expired. if not -> throw error
  verifyToken: (authToken) ->
    try
      jwt.verify(authToken, secret)
    catch error
      throw {code: -1, message: "Invalid token supplied #{authToken}"}

  # Checking if there is any password stored in plain text
  checkPasswords = ->
    hashPassInit = new HashPassInit()

module.exports = new UserService()
