Promise         = require('bluebird')
config          = require('config')
bus             = require('WeaverBus')
MinioClient     = require('MinioClient')
ProjectService  = require('ProjectService')
ProjectPool     = require('ProjectPool')
AclService      = require('AclService')
DatabaseService = require('DatabaseService')



bus.provide("project").require('target').on((req, target) ->
  ProjectService.get(target)
)

bus.provide("database").retrieve('user', 'project').on((req, user, project) ->
  AclService.assertACLReadPermission(user, project.acl)
  new DatabaseService(project.endpoint)
)

bus.private('project').on((req) ->
  ProjectService.all()
)

bus.private('project.create').retrieve('user').require('id', 'name').on((req, user, id, name) ->

  ProjectPool.create().then((project) ->

    # Create an ACL for this user to set on the project
    acl = AclService.createACL(id, user)
    ProjectService.create(id, name, project.database, acl.id)

    return
  )
)

bus.private('project.delete').retrieve('project', 'database').on((req, project, database) ->
  Promise.all([
    database.wipe()
    ProjectService.delete(project)
  ])
)

bus.private('project.ready').require('id').on((req, id) ->
  ProjectPool.isReady(id)
)

bus.internal('getMinioForProject').on((project) ->
  Promise.resolve(MinioClient.create(config.get('services.fileSystem')))
)
