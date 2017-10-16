bus             = require('WeaverBus')
Weaver          = require('weaver-sdk')
Promise         = require('bluebird')
FileService     = require('FileService')
AclService      = require('AclService')
ProjectService  = require('ProjectService')

bus.private('file.list')
  .retrieve('project', 'user')
  .require('target')
  .on((req, project, user, target) ->
    AclService.assertACLReadPermission(user, project.acl)
    FileService.listFiles(project.id)
  )

bus.private('file.download')
  .retrieve('project', 'user')
  .require('target', 'fileId')
  .on((req, project, user, target, fileId) ->
    AclService.assertACLReadPermission(user, project.acl)
    outputStream = req.res if req.res?
    FileService.downloadFile(project.id, fileId, outputStream)
  )

bus.private('file.upload')
  .retrieve('project', 'user')
  .require('target', 'file', 'filename')
  .on((req, project, user, target, file, filename) ->
    AclService.assertACLWritePermission(user, project.acl)
    FileService.uploadFile(filename, project.id, file)
  )

bus.private('file.delete')
  .retrieve('project', 'user')
  .require('target', 'fileId')
  .on((req, project, user, target, fileId) ->
    AclService.assertACLReadPermission(user, project.acl)
    FileService.deleteFile(fileId, project.id)
  )
