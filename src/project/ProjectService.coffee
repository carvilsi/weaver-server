LokiService = require('LokiService')
cuid        = require('cuid')
_           = require('lodash')
logger      = require('logger')

class ProjectService extends LokiService

  constructor: ->
    super('projects',
      projects: ['id', 'name', 'database', 'acl', 'fileServer', 'tracker']
    )

  create: (id, name, database, acl, fileServer, tracker) ->
    if @projects.find({id}).length isnt 0
      throw {code:-1, message: "Project with id #{id} already exists"}

    logger.code.info "ProjectService creating project with id #{id}"
    @projects.insert({id, name, database, acl, fileServer, tracker })

  get: (id) ->
    project = @projects.find({id})[0]
    if not project?
      throw {code: -1, message: "No project found for id #{id}"}

    project

  delete: (project) ->
    logger.code.info "ProjectService deleting project with id #{project.id if project}"
    @projects.remove(project)

  all: ->
    @projects.find()


module.exports = new ProjectService()
