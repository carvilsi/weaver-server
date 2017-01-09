Promise      = require('bluebird')
Error        = require('weaver-commons').Error
WeaverError  = require('weaver-commons').WeaverError
DatabaseConnection = require('DatabaseConnection')
    

module.exports=
  class OperationHandler
    
    constructor: ->
      @connection = new DatabaseConnection('http://localhost:9474')

    read: (id) ->
      @connection.read(id)
      
    write: (operations) ->
      @connection.write(operations)