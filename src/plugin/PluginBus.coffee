bus    = require('WeaverBus')
routes = require('routes')

class PluginBus

  constructor: (@plugin) ->
    @listeners = []

  private: (functionName) ->

    # Enable route based on plugin name and function name
    route = "plugin.function.#{@plugin.getName()}.#{functionName}"
    routes.private.GET(route)

    # Check function execution permission
    bus.private(route).priority(1000).on((req) ->
      # TODO Assert FCL permission
    )

    # Return EventListener
    listener = bus.private(route)
    listener._functionName = functionName
    @listeners.push(listener)
    listener

  getFunctions: ->
    compileFunction = (listener) ->
      route:    listener.eventName
      name:     listener._functionName
      require:  listener._require
      optional: listener._optional
      provide:  listener._provide

    (compileFunction(l) for l in @listeners)

module.exports = PluginBus
