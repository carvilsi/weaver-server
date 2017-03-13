LokiService = require('LokiService')
cuid        = require('cuid')
_           = require('lodash')

class ProjectService extends LokiService

  constructor: ->
    super('projects',
      projects: ['id', 'name', 'endpoint', 'acl']
    )

  create: (id, name, endpoint, acl) ->
    if @projects.find({id}).length isnt 0
      throw {code:-1, message: "Project with id #{id} already exists"}

    @projects.insert({id, name, endpoint, acl})

  get: (id) ->
    project = @projects.find({id})[0]
    if not project?
      throw {code: -1, message: "No project found for id #{id}"}

    project

  # TODO: check docs
  delete: (id) ->
    return

  # TODO: check find all
  all: ->
    @projects.find()



module.exports = new ProjectService()
