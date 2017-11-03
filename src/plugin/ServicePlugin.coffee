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

      @ready = true
    ).catch((err) =>
      if err.code is "ECONNREFUSED"
        logger.code.warn "Unable to connect to plugin service #{@name} on #{@url}"
      else
        logger.code.warn "Unable add #{@name} service"
        logger.code.warn err

      @ready = false
    )

  _registerFunction: (apipath, details) ->
    if !details.get?
      logger.code.error "Unable to add #{apipath} operation to #{@name} service, only get operations are supported"
      return

    listener = @pluginBus.private(details.get.operationId)

    requireds = []
    optionals = []
    retrieves = []

    if details.get.parameters?
      for i in details.get.parameters
        if i.name in [ 'project', 'user' ]
          retrieves.push i.name
        else if i.required
          requireds.push i.name
        else
          optionals.push i.name

    listener.require(requireds...)
    listener.optional(optionals...)
    listener.retrieve(retrieves...)

    listener.on((params...) =>
      logger.usage.silly("Plugin #{@getName()} got request for operation: #{details.get.operationId} (#{apipath})")
      logger.usage.silly params

      qs = {}

      for param, index in params
        if index >= 1 and index <= retrieves.length
          p = retrieves[index - 1]
          if p is 'project'
            qs.project = param.id
          else if p is 'user'
            qs.user = param.getAuthToken()
          else
            logger.code.error "Unknown retrieve parameter #{p} provided to #{@getName()}.#{details.get.operationId}"
        else if index > retrieves.length && index <= retrieves.length + requireds.length
          p = requireds[index - 1 - retrieves.length]
          qs[p] = param
        else if index > retrieves.length + requireds.length
          p = optionals[index - 1 - retrieves.length - requireds.length]
          if param?
            qs[p] = param

      request = { uri: "#{@url}#{apipath}", qs}
      rp(request)
    )

  getName: ->
    @name

  toServerObject: ->
    name:        @name
    version:     @version
    author:      @author
    description: @description
    functions:   @pluginBus.getFunctions()


module.exports = ServicePlugin
