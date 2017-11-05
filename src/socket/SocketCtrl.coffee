bus     = require('WeaverBus')
logger  = require('logger')
PubSub  = require('pubsub-js')

bus.private('socket.shout').retrieve('user').require('message').on((req, user, message) ->
  logger.usage.info "User #{user.username} shouting message #{JSON.stringify(message)}"
  PubSub.publish('socket.shout', message)
)
