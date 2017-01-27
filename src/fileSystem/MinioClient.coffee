config       = require('config')
Promise      = require('bluebird')
logger       = require('logger')
minio        = require('minio')

module.exports =
  class MinioSingleton
    instance = null
    
    class MinioClass
      constructor: (@minioClient) ->
        @minioClient = new minio.Client({
          endPoint: "#{config.get('services.fileSystem.endpoint')}".split(":")[1].replace('\/\/','')
          port: parseInt("#{config.get('services.fileSystem.endpoint')}".split(":")[2])
          secure: "#{config.get('services.fileSystem.secure')}" is 'true'
          accessKey: "#{config.get('services.fileSystem.accessKey')}"
          secretKey: "#{config.get('services.fileSystem.secretKey')}"
        })
        
        
    @getInstance: ->
      instance ?= new MinioClass()