Promise = require('bluebird')

class EventListener
  constructor: (@eventName) ->
    @_require  = []
    @_optional = []
    @_provide  = []
    @_priority = 0
    @_enabled  = true
    @_final = false

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

  # Retrieve objects returned by the provide bus
  retrieve: (args...) ->
    @_provide.push(a) for a in args
    @

  require: (args...) ->
    @_require.push(a) for a in args
    @

  optional: (args...) ->
    @_optional.push(a) for a in args
    @

  final: (final) ->
    @_final = final
    @

  isFinal: ->
    @_final

  call: (args...) ->
    if not @_enabled
      return Promise.reject({code: -1, message: "Route #{@eventName} is not enabled"})

    # Load all state objects
    bus = require('WeaverBus')
    Promise.mapSeries(@_provide, (eventName) ->
      req = args[0]
      bus.get('provide').emit(eventName, req)
    ).then((retrievedObjects) =>

      # Add objects
      args.push(o) for o in retrievedObjects

      # Check if all fields are set in the request
      # The first argument must be a request object with payload
      req = args[0]
      for require in @_require
        if not req.payload[require]?
          return Promise.reject({code: -1, message: "Missing field " + require})
        else
          args.push(req.payload[require])

      # Add all optional fields, otherwise inject null
      for optional in @_optional
        if req.payload[optional]?
          args.push(req.payload[optional])
        else
          args.push(null)

      # All fields found, do the actual call now
      try
        return @_func(args...)
      catch error
        isErrorObject = Object.prototype.toString.call(error) is '[object Error]'

        # TODO: Make all errors error objects, or log the error here
        if isErrorObject
          Promise.reject({code: -1, message: error.message})
        else
          Promise.reject(error)
    )

module.exports = EventListener
