events = require('events')

EventEmitterEnhancer = require('event-emitter-enhancer')

module.exports=

class EventBus
  constructor: (@name) ->
    EnhancedEventEmitter = EventEmitterEnhancer.extend(events.EventEmitter)
    @eventEmitter = new EnhancedEventEmitter()

  on: (event, func) ->
    @eventEmitter.on(event, func)
    
  emit: (event, arg1, arg2, arg3) ->
    @eventEmitter.emit(event, arg1, arg2, arg3)
    

Registry = require('registry')
module.exports = new Registry(EventBus)  
