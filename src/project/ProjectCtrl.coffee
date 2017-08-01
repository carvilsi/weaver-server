Promise         = require('bluebird')
config          = require('config')
bus             = require('WeaverBus')
MinioClient     = require('MinioClient')
ProjectService  = require('ProjectService')
ProjectPool     = require('ProjectPool')
AclService      = require('AclService')
DatabaseService = require('DatabaseService')
logger          = require('logger')
Tracker         = require('Tracker')



bus.provide("project").require('target').on((req, target) ->
  ProjectService.get(target)
)

bus.provide("database").retrieve('user', 'project').on((req, user, project) ->
  AclService.assertACLReadPermission(user, project.acl)
  new DatabaseService(project.database)
)

# Move to FileController
bus.provide('minio').retrieve('project', 'user').on((req, project, user) ->
  AclService.assertACLReadPermission(user, project.acl)
  MinioClient.create(config.get('services.fileServer'))
)

bus.private('project').retrieve('user').on((req, user) ->
  stripProject = (project) ->
    {
      id: project.id
      acl: project.acl
      name: project.name
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

bus.private('project.create').retrieve('user').require('id', 'name').on((req, user, id, name) ->
  AclService.assertACLWritePermission(user, 'create-projects')

  ProjectPool.create(id).then((project) ->

    # Create an ACL for this user to set on the project
    acl = AclService.createProjectACLs(id, user)
    ProjectService.create(id, name, acl.id)

    logger.code.debug "Project #{id} created, acl: #{acl}"

    return acl
  )
)

bus.private('project.delete').retrieve('user', 'project', 'database', 'minio').on((req, user, project, database, minio) ->
  AclService.assertProjectFunctionPermission(user, project, 'delete-project')

  logger.usage.info "Deleting project with id #{project.id}"
  Promise.all([
    database.wipe()
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
bus.private('snapshot').retrieve('project', 'user').on((req, project, user) ->
  AclService.assertProjectFunctionPermission(user, project, 'snapshot')
  logger.usage.info "Generating snapshot for project with id #{project.id}"
  database = new DatabaseService(project.database)
  database.snapshot()
)

# Wipe single project
bus.private('project.wipe')
.retrieve('project', 'user', 'database', 'tracker')
.enable(config.get('application.wipe'))
.on((req, project, user, database, tracker) ->
  if not user.isAdmin()
    throw {code: -1, message: 'Permission denied'}

  logger.usage.info "Wiping project with id #{project.id}"
  Promise.all([
    database.wipe()
    tracker.wipe()
  ])

)


# Wipe all projects
bus.private('projects.wipe')
.retrieve('user')
.enable(config.get('application.wipe'))
.on((req, user) ->

  if not user.isAdmin()
    throw {code: -1, message: 'Permission denied'}

  logger.usage.info "Wiping all projects"

  endpoints = (p.database for p in ProjectService.all())
  databases = (new DatabaseService(endpoint) for endpoint in endpoints)

  trackers = (new Tracker(p.tracker) for p in ProjectService.all())

  Promise.all([
    Promise.map(databases, (database) ->
      logger.usage.info "Wiping database: #{database.uri}"
      database.wipe()
    )
    Promise.map(trackers, (tracker) ->
      logger.usage.info "Wiping tracker"
      tracker.wipe()
    )
  ])
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
