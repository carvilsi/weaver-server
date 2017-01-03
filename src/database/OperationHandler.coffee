Promise      = require('bluebird')
Error        = require('weaver-commons').Error
WeaverError  = require('weaver-commons').WeaverError
Code         = require('weaver-commons').WriteOperation.Code
    

module.exports=
  class OperationHandler
    
    constructor: ->
      # Define handlers
      @handler = {}
      register = (code, operation) =>
        @handler[code] = require('./operation/' + operation)

      register Code.CREATE_NODE,              'CreateNode'
      register Code.UPDATE_NODE_ATTRIBUTE,    'UpdateNodeAttribute'
      register Code.REMOVE_NODE_ATTRIBUTE,    'RemoveNodeAttribute'

    readNode: () ->
      Promise.resolve()
      
    write: (operations) ->
        
      promises = (@handler[op.code](op) for op in operations)
      Promise.all(promises)