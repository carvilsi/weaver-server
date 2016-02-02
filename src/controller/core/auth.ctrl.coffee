cuid = require('cuid')
Promise     = require('bluebird')
randomBytes = Promise.promisify(require('crypto').randomBytes)

Token = require('./../../entity/core/token.entity')
User = require('./../../entity/core/user.entity')
Session = require('./../../entity/core/session.entity')


module.exports =

  class AuthCtrl
    signup: (payload, socket, ack) ->
      
      randomBytes(48).then((buf) ->

        # Generate Token ID
        tokenId = buf.toString('hex')

        # Create Token
        token = new Token()
        token.create(tokenId)

        # Read out session and user in payload
        user = new User(payload.user)          # TODO: Check if user is not already signed up
        session = new Session(payload.session)

        # Link token to session and back
        token.update('session', session.getId())
        session.update('token', tokenId)

        ack({token: tokenId})
      )


    signinToken: (tokenId, socket, ack) ->
      new Token(tokenId).read("session").then((sessionId)->
        session = new Session(sessionId)
        session.read("user").then((userId) ->
          user = new User(userId)

          session.getObject().then((sessionObject) ->
            user.getObject().then((userObject) ->

              if sessionObject.id is null or userObject.id is null
                ack(granted: false)
              else
                ack(granted: true, user: userObject, session: sessionObject)
            )
          )
        )
      )

    signinUsername: (payload, socket, ack) ->
      username = payload.username
      password = payload.password

      # First find user belonging to username
      User.getUserIdForUsername(username).then((userId) ->
        ack(granted: false) if not userId?

        # User found, get user password
        user = new User(userId)
        user.read('password').then((userPassword) ->

          # Deny access if passwords don't match
          ack(granted: false) if password isnt userPassword

          # Grant access
          randomBytes(48).then((buf) ->

            # Generate Token ID
            tokenId = buf.toString('hex')

            # Create Token
            token = new Token()
            token.create(tokenId)

            # Read out session and user in payload
            session = new Session()
            sessionId = cuid()
            session.create({id: sessionId, user: userId})

            # Link session to user
            user.addDependency('sessions', sessionId)

            # Link token to session and back
            token.update('session', sessionId)
            session.update('token', tokenId)

            # Read session and user and return
            session.getObject().then((sessionObject) ->
              user.getObject().then((userObject) ->
                ack(granted: true, user: userObject, session: sessionObject, token: tokenId)
              )
            )
          )
        )
      )

