bus    = require('EventBus').get('weaver')
config = require('config')
rp     = require('request-promise')

createUri = (suffix) ->
  "#{config.get('services.project.endpoint')}/#{suffix}"

doCall = (suffix, parameterName) -> (req, res) ->
  if parameterName?
    parameter = req.payload[parameterName]
    if parameter?
      callParameter = suffix + parameter
    else
      res.error("Expects #{parameterName} parameter")
      return
  else
    callParameter = suffix

  res.promise(
    rp({
      uri: createUri(callParameter)
    })
  )

bus.on('project', doCall("list"))
bus.on('project.create', doCall("create/", "name"))
bus.on('project.delete', doCall("delete/", "id"))
