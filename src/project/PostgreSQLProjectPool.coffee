_       = require('lodash')
config  = require('config')
logger  = require('logger')
Promise = require('bluebird')
rp      = require('request-promise')

class PostgreSQLProjectPool

  constructor:  (@endpoint) ->
    logger.code.info("PostgreSQL project pool loaded with endpoint: -#{@endpoint}-")

  request: (method) -> (path, qs) =>
    logger.code.debug "PostgreSQLProjectPool calling uri: #{@endpoint}/#{path}"
    rp({
      method
      uri: "#{@endpoint}/#{path}"
      json: true
      qs
    }).then((response) ->
      logger.code.silly "Called -#{path}-, reponse: -#{response}-"
      response
    )

  create: (id) ->
    logger.code.info "PostgreSQL creating project with id #{id}"
    @request("POST")('createDatabase', { database: id }).then((result) ->
      logger.usage.info "New PostgreSQL database created: #{id}"
      result
    )

  clean: (id) ->
    logger.code.info "PostgreSQL deleting project with id #{id}"
    @request("POST")('deleteDatabase', { database: id }).then((result) ->
      logger.usage.info "PostgresSQL database #{id} deleted"
      result
    )

  dump: (id) ->
    @request("GET")('dump', { database: id }).then((result) ->
      logger.usage.info "Dumping postgres database #{id}"
      # todo zip results
      result
    )

  isReady: ->
    Promise.resolve({ ready: true })   # Always ready


module.exports = new PostgreSQLProjectPool(config.get('services.database.url'))
