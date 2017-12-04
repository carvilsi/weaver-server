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
    method = ""
    definition = {}
    if details.get?
      method = "GET"
      definition = details.get
    else if details.post?
      method = "POST"
      definition = details.post
    else
      logger.code.error "Unable to add #{apipath} operation to #{@name} service, only get operations are supported"
      return

    listener = @pluginBus.private(definition.operationId)

    requireds = []
    optionals = []
    retrieves = []

    if definition.parameters?
      for i in definition.parameters
        if i.name in [ 'project', 'user' ]
          retrieves.push i.name
        else if i.required
          requireds.push i.name
        else
          optionals.push i.name

    listener.retrieve(retrieves...)
    listener.require(requireds...)
    listener.optional(optionals...)

    listener.on((params...) =>
      logger.usage.silly("Plugin #{@getName()} got request for operation: #{definition.operationId} (#{apipath})")
      logger.usage.silly params

      qs = {}

      for param, index in params
        if index >= 1 and index <= retrieves.length
          p = retrieves[index - 1]
          if p is 'project'
            qs.project = param.id
          else if p is 'user'
            if param.getAuthToken?
              qs.user = param.getAuthToken()
            else
              qs.user = params[0].payload.authToken
          else
            logger.code.error "Unknown retrieve parameter #{p} provided to #{@getName()}.#{definition.operationId}"
        else if index > retrieves.length && index <= retrieves.length + requireds.length
          p = requireds[index - 1 - retrieves.length]
          qs[p] = param
        else if index > retrieves.length + requireds.length
          p = optionals[index - 1 - retrieves.length - requireds.length]
          if param?
            qs[p] = param

      request = { uri: "#{@url}#{apipath}", method, qs}

      if definition.produces? and definition.produces[0] is 'application/octet-stream'
        request = { uri: "#{@url}#{apipath}", method, qs, encoding: null}

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
