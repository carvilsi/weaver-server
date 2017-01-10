bus    = require('EventBus').get('weaver')
config = require('config')
rp     = require('request-promise')
Error  = require('weaver-commons').Error
WeaverError = require('weaver-commons').WeaverError


createUri = (suffix) ->
  "#{config.get('services.project.endpoint')}/#{suffix}"

doCall = (suffix, parameterName) -> (req, res) ->
  if parameterName? and !req.payload[parameterName]?
    res.error(Error WeaverError.OTHER_CAUSE, "Missing parameter #{parameterName}")
  else
    callParameter = suffix + (if parameterName? then req.payload[parameterName] else "")
    res.promise(
      rp({
        uri: createUri(callParameter)
      })
    )

bus.on('project', doCall("list"))
bus.on('project.create', doCall("create/", "name"))
bus.on('project.delete', doCall("delete/", "id"))
