Weaver       = require('weaver-sdk')
Error        = Weaver.LegacyError
WeaverError  = Weaver.Error

module.exports =

  # Test whether payload is as expected. This allows for doing this:
  #
  # bus      = require('EventBus').get('weaver')
  # expect   = require('util/bus').getExpect(bus)
  #
  # Then use it as follows
  # expect('id').for('node.create').do((req, res, id) ->)
  #
  getExpect: (bus) -> (field) -> bus: (path) -> do: (callback) ->
    bus.on(path, (req, res) ->
      if !req.payload[field]?
        Promise.reject(Error(WeaverError.OTHER_CAUSE, "Missing field " + field))
      else
        callback(req, res, req.payload[field])
    )
