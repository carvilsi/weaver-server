module.exports=

class EventBus
  constructor: (@name) ->
    @filters = {}
    @listeners = {}

  on: (event, func) ->
    @listeners[event] = [] if !@listeners[event]?
    @listeners[event].push(func)
    
  fire: (event, arg1, arg2, arg3) ->
    promises = ((f(arg1, arg2, arg3)) for f in @listeners[event])
    Promise.all(promises)
    
  emit: (event, arg1, arg2, arg3) ->
    if !@filters[event]?
      @fire(event, arg1, arg2, arg3)
    else
      @filters[event](arg1, arg2, arg3).then(=>
        @fire(event, arg1, arg2, arg3)
      )

  filter: (event, func) ->
    @filters[event] = func

Registry = require('registry')
module.exports = new Registry(EventBus)
