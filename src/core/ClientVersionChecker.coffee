semver          = require('semver')
pack            = require('../../package.json')
logger          = require('logger')
config          = require('config')
DatabaseService = require('DatabaseService')

module.exports =
class ClientVersionChecker
  constructor: (@serverVersion, @connectorVersion) ->
    if @serverVersion?
      throw new Error("Invalid server version: #{@serverVersion}") if not semver.valid(@serverVersion)
    else
      @serverVersion = pack.version
    if @connectorVersion?
      throw new Error("Invalid connector version: #{@connectorVersion}") if not semver.valid(@connectorVersion)

  isValidSDKVersion: (sdkVersion) ->
    if !sdkVersion?
      logger.usage.warn "Client without a sdkVersion connected, rejecting"
      false
    else
      logger.usage.debug "Client connected with version #{sdkVersion}"
      true

  serverSatisfies: (versionRequirement) ->
    if !versionRequirement? or semver.satisfies(@serverVersion, versionRequirement)
      logger.usage.debug "Client with required server version #{versionRequirement}"
      true
    else
      logger.usage.warn "Server does not satisfy client required version #{versionRequirement}"
      false

  connectorSatisfies: (versionRequirement) ->
    @getConnectorVersion().then((connectorVersion) ->
      if !versionRequirement? or semver.satisfies(connectorVersion, versionRequirement)
        logger.usage.debug "Client with required connector version #{versionRequirement}"
        true
      else
        logger.usage.warn "Connector #{connectorVersion} does not satisfy client required version #{versionRequirement}"
        false
    )

  getConnectorVersion: ->
    if !@connectorVersion?
      database = new DatabaseService(config.get('services.database.url'))
      database.base().then((data)=>
        data.version
      )
    else
      Promise.resolve(@connectorVersion)
