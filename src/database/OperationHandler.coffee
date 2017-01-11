Promise      = require('bluebird')
Error        = require('weaver-commons').Error
WeaverError  = require('weaver-commons').WeaverError
DbConnection = require('DatabaseConnection')
    

module.exports=
  class OperationHandler
    
    constructor: ->
      @connection = new DbConnection('http://localhost:9474')

    read: (id) ->
      @connection.read(id)
      
    write: (operations) ->
      @connection.write(operations)