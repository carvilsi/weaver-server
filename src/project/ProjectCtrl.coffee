bus         = require('EventBus').get('weaver')
config      = require('config')
rp          = require('request-promise')
Error       = require('weaver-commons').Error
WeaverError = require('weaver-commons').WeaverError
Promise     = require('bluebird')

serviceDatabase = config.get('services.database.endpoint')
serviceProject  = config.get('services.project.endpoint')?

if serviceDatabase?
  databases = []
  startId = 0

  bus.on('project', (req, res) ->
    Proise.resolve(databases)
  )

  bus.on('project.create', (req, res) ->
    if !req.payload.name?
      Promise.reject(Error(WeaverError.OTHER_CAUSE, "Missing parameter name"))
    prj = { name: req.payload.name, id: startId }
    databases.push prj
    startId = startId + 1
    prj
  )
  bus.on('project.delete', (req, res) ->
    if !req.payload.id?
      Promise.reject(Error(WeaverError.OTHER_CAUSE, "Missing parameter id"))
    index = j for i, j in databases when i.id = req.payload.id
  )
  bus.on('getDatabaseForProject', (project) ->
    Promise.resolve(serviceDatabase)
  )

else if serviceProject?
  
  createUri = (suffix) ->
    "#{serviceProject}/#{suffix}"

  doCall = (suffix, parameterName) -> (req, res) ->
    if parameterName? and !req.payload[parameterName]?
      Promise.reject(Error(WeaverError.OTHER_CAUSE, "Missing parameter #{parameterName}"))
    else
      callParameter = suffix + (if parameterName? then req.payload[parameterName] else "")
      rp({
        uri: createUri(callParameter)
      })
  bus.on('project',        doCall("list"))
  bus.on('project.create', doCall("create/", "name"))
  bus.on('project.delete', doCall("delete/", "id"))
  bus.on('getDatabaseForProject', (project) ->
    Promise.reject()
  )

else
  console.error "Either a static database or a projects service needs to be configured"
  process.exit(-1)
