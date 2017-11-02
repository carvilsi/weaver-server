path      = require('path')
PluginBus = require('PluginBus')
rp        = require('request-promise')
SwaggerParser = require('swagger-parser')
logger    = require('logger')

class ServicePlugin

  constructor: (@url, @name) ->
    @pluginBus = new PluginBus(@)

  init: ->
    SwaggerParser.validate("#{@url}/swagger")
    .then((api) =>
      @description = api.info.description
      @version = api.info.version
      @author = api.info.contact.email

      logger.code.info("Service plugin #{@name} loaded with #{Object.keys(api.paths).length} Swagger paths parsed")
      
      for apipath, details of api.paths
        @_registerFunction(apipath, details)
    )

  _registerFunction: (apipath, details) ->
    @pluginBus.private(details.get.operationId).on((req) =>
      logger.usage.silly("Plugin #{@getName()} got request for operation: #{details.get.operationId} (#{apipath})")
      rp({ uri: "#{@url}#{apipath}"})
    )

  getName: ->
    @name

  toServerObject: ->
    name:        @name
    version:     @version
    author:      @author
    description: @getDescription
    functions:   @pluginBus.getFunctions()


module.exports = ServicePlugin
