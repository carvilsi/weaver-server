_             = require('lodash')
config        = require('config')
logger        = require('logger')
Promise       = require('bluebird')
fileService   = require('FileService')
rp            = require('request-promise')

class PostgreSQLProjectPool

  constructor:  (@endpoint) ->
    logger.code.info("PostgreSQL project pool loaded with endpoint: -#{@endpoint}-")

  request: (method) -> (path, qs, body) =>
    logger.code.debug "PostgreSQLProjectPool calling uri: #{@endpoint}/#{path}"
    rp({
      method
      uri: "#{@endpoint}/#{path}"
      json: true
      body
      qs
    }).then((response) ->
      logger.code.silly "Called -#{path}-, reponse: -#{response}-"
      response
    )

  upload: (path, qs, formData) ->
    logger.code.debug "PostgreSQLProjectPool calling upload uri: #{@endpoint}/#{path}"
    rp({
      method: "POST"
      uri: "#{@endpoint}/#{path}"
      qs
      formData
    }).then((response) ->
      logger.code.silly "Called -#{path}-, reponse: -#{response}-"
      response
    )

  executeZip: (filename, project) ->
    fileService.downloadFileByID(filename, project.id).then((file) =>
      @upload("upload", { database: project.id }, { file })
    ).then((result) ->
      logger.usage.info "Executed write operations from zip on: #{project.id}"
      result
    )

  create: (id) ->
    logger.code.info "PostgreSQL creating project with id #{id}"
    @request("POST")('createDatabase', { database: id }).then((result) ->
      logger.usage.info "New PostgreSQL database created: #{id}"
      result
    )

  clone: (id, clone_id) ->
    logger.code.info "PostgreSQL cloning project with id #{id}"
    @request("POST")('duplicateDatabase', { database: id, cloned_database: clone_id }).then((result) ->
      logger.usage.info "New PostgreSQL database cloned: #{clone_id}"
      result
    )

  clean: (id) ->
    logger.code.info "PostgreSQL deleting project with id #{id}"
    @request("POST")('deleteDatabase', { database: id }).then((result) ->
      logger.usage.info "PostgresSQL database #{id} deleted"
      result
    )

  isReady: ->
    Promise.resolve({ ready: true })   # Always ready


module.exports = new PostgreSQLProjectPool(config.get('services.database.url'))
