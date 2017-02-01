config       = require('config')
Promise      = require('bluebird')
logger       = require('logger')
minio        = require('minio')

module.exports =
  class MinioClient
    constructor: (config) ->
      logger.debug "Creating MinioClient with settings #{JSON.stringify(config)}"
      @minioClient = new minio.Client({
        endPoint: config.endpoint.split(":")[1].replace('\/\/','')
        port: parseInt(config.endpoint.split(":")[2])
        secure: config.secure
        accessKey: config.accessKey
        secretKey: config.secretKey
      })
