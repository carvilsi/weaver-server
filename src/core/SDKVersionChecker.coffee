semver = require('semver')

module.exports =
class SDKVersionChecker
  constructor: (@serverVersion) ->
    throw new Error("Invalid server version: #{@serverVersion}") if not semver.valid(@serverVersion)

  checkSDKVersion: (sdkVersion) ->
    semver.gt(sdkVersion, @serverVersion)
