events = require('events');

module.exports=

class EventBus 
  
  constructor: (@name) ->
    @eventEmitter = new events.EventEmitter();

  on: (event, func) ->
    @eventEmitter.on(event, func)
    
  emit: (event, arg1, arg2, arg3) ->
    @eventEmitter.emit(event, arg1, arg2, arg3)
    

Registry = require('registry')
module.exports = new Registry(EventBus)  