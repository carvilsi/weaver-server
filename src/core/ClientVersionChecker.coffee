semver = require('semver')
pack   = require('../../package.json')
logger = require('logger')

module.exports =
class ClientVersionChecker
  constructor: (@serverVersion) ->
    if @serverVersion?
      throw new Error("Invalid server version: #{@serverVersion}") if not semver.valid(@serverVersion)
    else
      @serverVersion = pack.version

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
