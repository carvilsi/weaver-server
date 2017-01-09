Promise      = require('bluebird')
Error        = require('weaver-commons').Error
WeaverError  = require('weaver-commons').WeaverError
Action       = require('weaver-commons').WriteOperation.Action
    

module.exports=
  class OperationHandler
    
    constructor: ->
      # Define handlers
      @handler = {}
      register = (code, operation) =>
        @handler[code] = require('./operation/' + operation)

    readNode: () ->
      Promise.resolve()
      
    write: (operations) ->
        
      promises = (@handler[op.code](op) for op in operations)
      Promise.all(promises)
