_             = require('lodash')
config        = require('config')
logger        = require('logger')
Promise       = require('bluebird')
fileService   = require('FileService')
rp            = require('request-promise')
fs            = require('fs')
cuid          = require('cuid')


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

  dump: (id) ->
    @request("GET")('dump', { database: id }).then((result) ->
      logger.usage.info "Dumping postgres database #{id}"
      
      filename = cuid()
      path = __dirname + '/../../uploads/'
      pathFilename = path + filename
            
      writeFile = Promise.promisify(fs.writeFile)
      
      writeFile(pathFilename, JSON.stringify(result)).then(->
        gz = fileService.gunZip(path, filename)
        fileService.uploadFileStream(gz.pathAndName, gz.zippedName, id)
      ).then((filenameMinio) ->
        filenameMinio
      )
    )

  isReady: ->
    Promise.resolve({ ready: true })   # Always ready


module.exports = new PostgreSQLProjectPool(config.get('services.database.url'))
