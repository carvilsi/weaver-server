EventBus = require('EventBus')

busNames = [
  'internal'
  'private'
  'public'
  'admin'
]

class WeaverBus extends EventBus

  constructor: ->
    @buses = {}

    busNames.forEach((name) =>
      @buses[name] = new EventBus(name)
      @[name] = (path) ->
        @buses[name].addListener(path)
    )

  get: (name) ->
    @buses[name]

module.exports = new WeaverBus()
