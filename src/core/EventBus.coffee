Promise       = require('bluebird')
EventListener = require("EventListener")

class EventBus
  constructor: (@name) ->
    @listeners = {"*": []} # The wildcard array is initialized

  addListener: (event) ->
    l = new EventListener(event)
    @listeners[event] = @listeners[event] or []
    @listeners[event].push(l)
    l

  emit: (event, args...) ->
    # Always add the wildcard listeners to each event
    notify = @listeners["*"].concat(@listeners[event] or [])

    # Sort based on priority
    sorted = notify.sort((a,b) -> a.after(b))

    tillFinal = []
    for l in sorted
      tillFinal.push(l)
      if l.isFinal()
        break

    # Promise.mapSeries runs promises sequentially (as opposed to Promise.map)
    Promise.mapSeries(tillFinal, (listener) ->
      listener.call(args...)
    ).then((result) ->

      # Remove null and undefined
      result = result.filter((r) -> r?)

      # Return single result if only 1 listener responded, else the array of results
      if result.length is 1 then result[0] else result
    )

module.exports = EventBus
