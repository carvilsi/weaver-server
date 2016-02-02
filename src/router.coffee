DefaultCtrl = require('./controller/default.ctrl')

# This is the main entry point of any new socket connection.
module.exports =

  # Define a route function that will take a message signature and construct a route for
  # that signature using the controller function
  # This procedure gets called on each new connection! TODO Check time penalty
  (socket) -> (path) -> (key, operation) ->

    try
      Controller = require('./controller/' + path + '/' +  key + '.ctrl')
      ctrl = new Controller()
    catch error
      # No controller found, so initiate with default controller
      try
        Entity = require('./entity/' + path + '/' + key + '.entity')
        ctrl = new DefaultCtrl(key, Entity)
      catch error
        console.log('Error: ' +key+ ':' +operation+ ' route has no controller or entity.')

    # Actual Socket route
    socket.on(key + ':' + operation, (payload, ack) ->
      ctrl[operation](payload, socket, ack)
    )