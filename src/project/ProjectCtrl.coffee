bus    = require('EventBus').get('weaver')
config = require('config')
rp     = require('request-promise')

createUri = (suffix) ->
  "#{config.get('services.project.endpoint')}/#{suffix}"

doCall = (res, suffix) ->
  res.promise(
    rp({
      uri: createUri(suffix)
    })
  )

bus.on('project', (req, res) ->
  doCall(res, "list")
)

bus.on('project.create', (req, res) ->
  if !req.body.name?
    res.error("Expects name parameter")
  else
    doCall(res, "create/#{req.body.name}")
)

bus.on('project.delete', (req, res) ->
  if !req.body.id?
    res.error("Expects id parameter")
  else
    doCall(res, "delete/#{req.body.id}")
)

