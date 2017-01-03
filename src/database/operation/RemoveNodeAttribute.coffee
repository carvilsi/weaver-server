Promise      = require('bluebird')
Error        = require('weaver-commons').Error
WeaverError  = require('weaver-commons').WeaverError
Code         = require('weaver-commons').WriteOperation.Code
    
handler = (operation) ->
  if operation.id is 'a'
    Promise.reject(Error WeaverError.NODE_ALREADY_EXISTS, {id: operation.id})
  else
    Promise.resolve()

module.exports = handler
