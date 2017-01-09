Promise      = require('bluebird')
Error        = require('weaver-commons').Error
WeaverError  = require('weaver-commons').WeaverError
Action       = require('weaver-commons').WriteOperation.Action
    

handler = (operation) ->
  
  if operation.id is 'a'
    Promise.reject(Error WeaverError.NODE_ALREADY_EXISTS, {id: operation.id})
  else if operation.id is 'b'
    Promise.reject(Error WeaverError.NODE_NOT_FOUND, {id: operation.id})
  else
    Promise.resolve()

    
module.exports = handler
