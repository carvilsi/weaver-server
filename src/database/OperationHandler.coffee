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

      register Action.CREATE_NODE,              'CreateNode'
      register Action.UPDATE_NODE_ATTRIBUTE,    'UpdateNodeAttribute'
      register Action.REMOVE_NODE_ATTRIBUTE,    'RemoveNodeAttribute'
      
    readNode: () ->
      Promise.resolve()
      
    write: (operations) ->
        
      promises = (@handler[op.code](op) for op in operations)
      Promise.all(promises)