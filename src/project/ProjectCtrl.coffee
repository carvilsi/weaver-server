Promise         = require('bluebird')
config          = require('config')
bus             = require('WeaverBus')
MinioClient     = require('MinioClient')
ProjectService  = require('ProjectService')
FileService     = require('FileService')
ProjectPool     = require('ProjectPool')
AclService      = require('AclService')
DatabaseService = require('DatabaseService')
logger          = require('logger')

bus.private('write').priority(1000).retrieve('user', 'project').on((req, user, project) ->
  if ProjectService.isFrozen(project)
    throw {code: -1, message: 'Project is frozen'}
)

bus.provide("project").require('target').on((req, target) ->
  ProjectService.get(target)
)

bus.provide("database").retrieve('user', 'project').on((req, user, project) ->
  AclService.assertACLReadPermission(user, project.acl)
  new DatabaseService(config.get('services.database.url'), project.id)
)

# Move to FileController
bus.provide('minio').retrieve('project', 'user').on((req, project, user) ->
  AclService.assertACLReadPermission(user, project.acl)
  MinioClient.create(config.get('services.fileServer'))
)

bus.private('project.executeZip').retrieve('user', 'project').require('filename').on((req, user, project, filename) ->
  AclService.assertProjectFunctionPermission(user, project, 'project-administration')
  logger.code.info "Executing ZIP: #{filename}, on: #{project.id}"
  ProjectPool.executeZip(filename, project)
)

bus.private('project.freeze').retrieve('user', 'project').on((req, user, project) ->
  logger.code.info "Freezing project id: #{project.id}"
  ProjectService.freezeProject(user, project)
)

bus.private('project.unfreeze').retrieve('user', 'project').on((req, user, project) ->
  logger.code.info "Unfreezing project id: #{project.id}"
  ProjectService.unfreezeProject(user, project)
)

bus.private('project.app.add').retrieve('user', 'project').require('app').on((req, user, project, app) ->
  logger.code.info "Adding app #{app} to project id: #{project.id}"
  ProjectService.addApp(user, project, app)
)

bus.private('project.app.remove').retrieve('user', 'project').require('app').on((req, user, project, app) ->
  logger.code.info "Remove app #{app} to project id: #{project.id}"
  ProjectService.removeApp(user, project, app)
)

bus.private('project').retrieve('user').on((req, user) ->
  stripProject = (project) ->
    {
      id: project.id
      acl: project.acl
      name: project.name
      apps: project.apps
    }
  projects = ProjectService.all()
  result = []
  for p in projects
    try
      AclService.assertACLReadPermission(user, p.acl)
      result.push(stripProject(p))
    catch error
      # User has no access to this project
  result
)

bus.private('project.name').retrieve('user', 'project').require('name').on((req, user, project, name) ->
  logger.code.info "Renaming project #{project.name} to: #{name}"
  ProjectService.nameProject(user, project, name)
)

bus.private('project.create').retrieve('user').require('id', 'name').on((req, user, id, name) ->
  logger.code.info "Creating project id: #{id} name: #{name}"
  AclService.assertACLWritePermission(user, 'create-projects')

  ProjectPool.create(id).then((project) ->

    # Create an ACL for this user to set on the project
    acl = AclService.createProjectACLs(id, user)
    ProjectService.create(id, name, acl.id)

    logger.code.debug "Project #{id} created, acl: #{acl.id}"

    return acl
  )
)

bus.private('project.clone').retrieve('user', 'project').require('id', 'name').on((req, user, project, id, name) ->
  AclService.assertACLWritePermission(user, 'create-projects')
  AclService.assertProjectFunctionPermission(user, project, 'snapshot')

  logger.usage.info "Cloning project with id #{project.id}"
  ProjectPool.clone(project.id, id).then((cloned_project) ->

    # Create an ACL for this user to set on the project
    acl = AclService.createProjectACLs(id, user)
    ProjectService.create(id, name, acl.id)

    logger.code.debug "Project #{project.id} cloned into #{id}, acl: #{acl.id}"

    return acl

  )
)

bus.private('project.delete').retrieve('user', 'project').on((req, user, project) ->
  AclService.assertProjectFunctionPermission(user, project, 'delete-project')

  logger.usage.info "Deleting project with id #{project.id}"
  Promise.all([
    ProjectPool.clean(project.id)
    ProjectService.delete(project)
  ])
)

bus.private('project.ready').retrieve('user').require('id').on((req, user, id) ->
  logger.usage.silly "Checking acl for ready for project #{id}"
  AclService.assertACLReadPermission(user, AclService.getACLByObject(id).id)
  logger.usage.silly "Checking ready for project #{id}"
  ProjectPool.isReady(id)
)

bus.internal('getMinioForProject').on((project) ->
  Promise.resolve(MinioClient.create(config.get('services.fileServer')))
)

# Create a snapshot with write operations for the project
bus.private('snapshot').retrieve('project', 'user').optional('zipped').on((req, project, user, zipped = false) ->
  AclService.assertProjectFunctionPermission(user, project, 'snapshot')
  logger.usage.info "Generating snapshot for project with id #{project.id} - zipped #{zipped}"
  database = new DatabaseService(config.get('services.database.url'), project.id)
  FileService.storeZip(database.snapshot(), project)
)

# Wipe single project
bus.private('project.wipe')
.retrieve('project', 'user', 'database')
.enable(config.get('application.wipe'))
.on((req, project, user, database) ->
  if not user.isAdmin()
    throw {code: -1, message: 'Permission denied'}

  logger.usage.info "Wiping project with id #{project.id}"
  database.wipe()

)


# Wipe all projects
bus.private('projects.wipe')
.retrieve('user')
.enable(config.get('application.wipe'))
.on((req, user) ->

  if not user.isAdmin()
    throw {code: -1, message: 'Permission denied'}

  logger.usage.info "Wiping all projects"

  ids = (p.id for p in ProjectService.all())
  databases = (new DatabaseService(config.get('services.database.url'), id) for id in ids)

  Promise.map(databases, (database) ->
    logger.usage.info "Wiping database: #{database.uri}"
    database.wipe()
  )
)


# Destroy all projects
bus.private('projects.destroy')
.retrieve('user')
.enable(config.get('application.wipe'))
.on((req, user) ->

  if not user.isAdmin()
    throw {code: -1, message: 'Permission denied'}

  logger.usage.info "Destroying all projects"

  Promise.map(ProjectService.all(), (p) ->
    logger.usage.debug "Destroying project: #{p.id}"
    ProjectPool.clean(p.id).catch((err) ->
      logger.usage.warn "Error cleaning project id #{p.id}"
      Promise.resolve()
    )
  ).then(->
    logger.code.debug "Calling wipe on the project service"
    ProjectService.wipe().then( ->
      logger.code.debug "ProjectService promise completed"
    )
  )
)
