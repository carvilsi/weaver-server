config  = require('config')
rp      = require('request-promise')
logger  = require('logger')


class KubernetesProjectPool

  constructor: (@endpoint) ->
    logger.config.info("K8s project pool loaded")

  request: (path) ->
    rp({
      uri: "#{@endpoint}/#{path}"
      json: true
    })

  create: (id) ->
    @request("create/#{id}").then((status) ->
      project =
        database: status.services.service
        fileServer:
          endpoint:  status.services.minio
          accessKey: status.minio.MINIO_ACCESS_KEY
          secretKey: status.minio.MINIO_SECRET_KEY

      project
    )

  clean: (id) ->
    @request("delete/#{id}")

  isReady: (id) ->
    @request("status/#{id}").then((status) ->
      {
        ready: status.ready
      }
    )

module.exports = new KubernetesProjectPool(config.get('services.projectController.endpoint'))
