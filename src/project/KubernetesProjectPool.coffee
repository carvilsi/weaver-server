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
      trackerInfo = status.services.trackerdb.match(/http:\/\/([^:]*)\:([0-9]*)/)
      logger.code.info "Created new project #{id}"
      logger.code.info status
      project =
        database: status.services.service
        fileServer:
          endpoint:  status.services.minio
          accessKey: status.env.minio.MINIO_ACCESS_KEY
          secretKey: status.env.minio.MINIO_SECRET_KEY
        tracker:
          enabled:true
          host: trackerInfo[1]
          port: trackerInfo[2]
          user: "root"
          password: status.env['tracker-db'].MYSQL_ROOT_PASSWORD
          database: status.env['tracker-db'].MYSQL_DATABASE

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
