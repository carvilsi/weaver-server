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
    @projects.insert({id, name, acl, apps: {}})

  get: (id) ->
    project = @projects.find({id})[0]
    if not project?
      throw {code: -1, message: "No project found for id #{id}"}

    project.apps = {} if not project.apps? # Init for existing projects
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

  _getProjectToEdit: (user, project) ->
    AclService.assertProjectFunctionPermission(user, project, 'project-administration')
    @projects.find({id: project.id})[0]

  nameProject: (user, project, name) ->
    project = @_getProjectToEdit(user, project)
    project.name = name

  addApp: (user, project, appName) ->
    project = @_getProjectToEdit(user, project)
    project.apps[appName] = true

  removeApp: (user, project, appName) ->
    project = @_getProjectToEdit(user, project)
    delete project.apps[appName]

  unfreezeProject: (user, project) ->
    project = @_getProjectToEdit(user, project)
    project.frozen = false

  freezeProject: (user, project) ->
    project = @_getProjectToEdit(user, project)
    project.frozen = true

  isFrozen: (project) ->
    frozenState = @projects.find({id: project.id})[0].frozen
    if frozenState? then frozenState else false

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
