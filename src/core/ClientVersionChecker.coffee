semver = require('semver')
pack   = require('../../package.json')
logger = require('logger')
request = require('request')

module.exports =
class ClientVersionChecker
  constructor: (@serverVersion, @connectorVersion) ->
    if @serverVersion?
      throw new Error("Invalid server version: #{@serverVersion}") if not semver.valid(@serverVersion)
    else
      @serverVersion = pack.version
    if @connectorVersion?
      throw new Error("Invalid connector version: #{@connectorVersion}") if not semver.valid(@connectorVersion)
    else
      request.get {uri:'http://127.0.0.1:4567/', json : true}, (err, r, body) -> 
        @connectorVersion = JSON.stringify(body.version)

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
      logger.usage.warn "Server does not satisfy required version #{versionRequirement}"
      false

  connectorSatisfies: (versionRequirement) ->
    if !versionRequirement? or semver.satisfies(@connectorVersion, versionRequirement)
      logger.usage.debug "Client with required connector version #{versionRequirement}"
      true
    else
      logger.usage.warn "Connector does not satisfy required version #{versionRequirement}"
      false
