semver  = require('semver')
packSDK = require('../../node_modules/weaver-sdk/package.json')

module.exports =
class SDKVersionChecker
  constructor: (@serverVersion) ->
    if @serverVersion?
      throw new Error("Invalid server version: #{@serverVersion}") if not semver.valid(@serverVersion)
    else
      @serverVersion = packSDK.version

  isValidSDKVersion: (sdkVersion) ->
    try
      semver.gt(sdkVersion, @serverVersion)
    catch
      false
