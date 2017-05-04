semver  = require('semver')
packSDK = require('../../node_modules/weaver-sdk/package.json')
logger  = require('logger')

module.exports =
class SDKVersionChecker
  constructor: (@serverVersion) ->
    if @serverVersion?
      throw new Error("Invalid server version: #{@serverVersion}") if not semver.valid(@serverVersion)
    else
      @serverVersion = packSDK.version

    logger.code.info "Version checker instantiated with version #{@serverVersion} to check against"

  checkSDKVersion: (sdkVersion) ->
    semver.gt(sdkVersion, @serverVersion)
