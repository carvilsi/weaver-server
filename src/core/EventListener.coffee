Promise = require('bluebird')

class EventListener
  constructor: (@eventName) ->
    @_require  = []
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

  require: (args...) ->
    @_require.push(r) for r in args
    @

  call: (args...) ->
    return if not @_enabled

    # Check if all fields are set in the request
    # The first argument must be a request object with payload
    req = args[0]
    for require in @_require
      if not req.payload[require]?
        return Promise.reject({code: -1, message: "Missing field " + require})
      else
        args.push(req.payload[require])

    # All required fields are found
    new Promise((resolve, reject) =>
      try
        resolve(@_func(args...))
      catch error
        isErrorObject = Object.prototype.toString.call(error) is '[object Error]'

        # TODO: Make all errors error objects, or log the error here
        if isErrorObject
          reject({code: -1, message: error.message})
        else
          reject(error)
    )


module.exports = EventListener
