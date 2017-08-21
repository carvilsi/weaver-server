_             = require('lodash')
config        = require('config')
logger        = require('logger')
Promise       = require('bluebird')
fileService   = require('FileService')
rp            = require('request-promise')
fs            = require('fs')
cuid          = require('cuid')
zip           = require('node-zip')

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
      
      filename = cuid()
      pathFilename = __dirname + '/../../uploads/' + filename
      writeFile = Promise.promisify(fs.writeFile)
      
      writeFile(pathFilename, JSON.stringify(result)).then(->
        fileService.uploadFileStream(pathFilename, filename, id)
      ).then((filenameMinio) ->
        filenameMinio
      )
    )

  isReady: ->
    Promise.resolve({ ready: true })   # Always ready


module.exports = new PostgreSQLProjectPool(config.get('services.database.url'))
