LokiService = require('LokiService')
cuid        = require('cuid')
_           = require('lodash')
logger      = require('logger')
AclService  = require('AclService')

class ProjectService extends LokiService

  constructor: ->
    super('projects',
      projects: ['id', 'name', 'acl']
    )

  create: (id, name, acl) ->
    if @projects.find({id}).length isnt 0
      throw {code:-1, message: "Project with id #{id} already exists"}

    logger.code.info "ProjectService storing project with id-name-acl #{id}-#{name}-#{acl}"
    @projects.insert({id, name, acl})

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

  load: ->
    super().then(=>
      @checkProjectAcls()
    )
  
  nameProject: (user, project, name) ->
    AclService.assertACLWritePermission(user, project.acl)
    project = @projects.find({id: project.id})[0]
    project.name = name
    
  getProjectsForUser: (user) ->
    projects = []

    for p in @projects.find()
      try
        AclService.assertACLReadPermission(user, p.acl)
        projects.push(p)
      catch err
        continue

    projects

  checkProjectAcls: ->
    for project in @all
      AclService.checkProjectAcl(project.id)

module.exports = new ProjectService()
