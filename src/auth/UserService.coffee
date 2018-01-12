conf         = require('config')
LokiService  = require('LokiService')
cuid         = require('cuid')
_            = require('lodash')
jwt          = require('jsonwebtoken')
HashPassInit = require('HashPassInit')
secret       = conf.get('auth.secret')
expiresIn    = conf.get('auth.expire')
bcrypt       = require('bcrypt')
logger       = require('logger')
Weaver       = require('weaver-sdk')

class UserService extends LokiService

  constructor: ->
    super('users',
      users:    ['username', 'email']
      sessions: ['authToken']
    )
    checkPasswords()

  all: ->
    (_.omit(user, ['passwordHash']) for user in @users.find())

  get: (userId) ->
    user = @users.find({userId})[0]
    if not user?
      throw {code: -1, message: "No user found for id #{userId}"}

    _.omit(user, ['passwordHash', 'password' ])

  signUp: (userId, username, email, password, firstname, lastname) ->

    if @users.findOne({username})?
      logger.auth.warn("User with username #{username} already exists")
      throw {code:-1, message: "User with username #{username} already exists"}

    if @users.findOne({userId})?
      logger.auth.warn("User with userId #{userId} already exists")
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
      logger.auth.warn("Password changed for #{userId}")
      user.passwordHash = passwordHash
      @users.update(user)
    )

  insertSession: (authToken, username) ->
    logger.auth.info("#{username} signed in")
    sessionId = cuid()
    @sessions.insert({sessionId, authToken, username})

  signInUsername: (username, password) ->
    user = @users.find({username})[0]
    if not user?
      comparePassword(username,password)
      .then( ->
        logger.auth.warn("Invalid sign in: #{username} does not exist")
        throw {code: Weaver.Error.INVALID_USERNAME_PASSWORD, message: "Invalid Username or Password"}
      )
    else
      if not user.active
        logger.auth.warn("User #{username} not active")
        throw {code: -1, message: "User not active"}

      comparePassword(password, user.passwordHash)
      .then((res) =>
        if !res
          logger.auth.warn("Invalid sign in: #{username} wrong password")
          throw {code: Weaver.Error.INVALID_USERNAME_PASSWORD, message: "Invalid Username or Password"}
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
      logger.auth.error("No session found for authToken #{authToken}")
      throw {code: -1, message: "No session found for authToken #{authToken}"}

    # Check if the token is still valid. If not -> throw error
    @verifyToken(authToken)

    user = @users.findOne({username: session.username})
    _.omit(user, ['passwordHash'])

  signOut: (authToken) ->
    session = @sessions.findOne({authToken})
    @sessions.remove(session)

  destroy: (id) ->
    user = @users.findOne({userId:id})
    @users.remove(user)

  update: (update) ->
    # TODO Lots of checking (is the username/email correct?, does the user exist? etc)
    logger.auth.info "Updating user #{update.userId}"
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
      logger.auth.warn("Invalid token supplied #{authToken}")
      throw {code: Weaver.Error.INVALID_SESSION_TOKEN, message: "Invalid token supplied #{authToken}"}

  # Checking if there is any password stored in plain text
  checkPasswords = ->
    hashPassInit = new HashPassInit()

module.exports = new UserService()
