config  = require('config')
rp      = require('request-promise')
logger  = require('logger')
Promise = require('bluebird')

class KubernetesProjectPool

  constructor: (@endpoint) ->
    logger.config.info("K8s project pool loaded")

  request: (path) ->
    rp({
      uri: "#{@endpoint}/#{path}"
      json: true
    }).then((response) ->
      logger.code.silly "Called #{path}, reponse: #{response}"
      response
    )

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
    logger.code.info "Deleting project with id #{id}"
    @request("delete/#{id}").then( ->
      logger.code.info "Delete of project with id #{id} successful"
    ).catch((err) ->
      logger.code.warn "Error on clean: #{err}"
      Promise.reject(err)
    )

  isReady: (id) ->
    @request("status/#{id}").then((status) ->
      {
        ready: status.ready
      }
    )

module.exports = new KubernetesProjectPool(config.get('services.projectController.endpoint'))
