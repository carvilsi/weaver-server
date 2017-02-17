Promise = require('bluebird')

class EventListener
  constructor: (@eventName) ->
    @_require  = []
    @_get      = []
    @_priority = 0
    @_enabled = true

  priority: (value) ->
    @_priority = value
    @

  enable: (value) ->
    @_enabled = value
    @

  after: (listener) ->
    @_priority <= listener._priority

  on: (func) ->
    @_func = func

  # Gets state object based on some request argument
  get: (args...) ->
    @_get.push(a) for a in args
    @

  require: (args...) ->
    @_require.push(a) for a in args
    @

  call: (args...) ->
    return if not @_enabled

    # Load all state objects
    Promise.mapSeries(@_get, (stateName) ->
      require('WeaverBus').get('internal').emit("state.#{stateName}")
    ).then((stateObjects) ->
      args.push(s) for s in stateObjects # TODO: Test if concat works

      # Check if all fields are set in the request
      # The first argument must be a request object with payload
      req = args[0]
      for require in @_require
        if not req.payload[require]?
          return Promise.reject({code: -1, message: "Missing field " + require})
        else
          args.push(req.payload[require])

      # All fields found, do the actual call now
      try
        return @_func(args...)
      catch error
        isErrorObject = Object.prototype.toString.call(error) is '[object Error]'

        # TODO: Make all errors error objects, or log the error here
        if isErrorObject
          return Promise.reject({code: -1, message: error.message})
        else
          return Promise.reject(error)
    )

module.exports = EventListener
