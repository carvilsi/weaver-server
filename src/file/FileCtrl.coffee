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

#######################################
# LEGACY FUNCTIONS                    #
# These should eventually be removed  #
#######################################
config          = require('config')
multer          = require('multer')
server          = require('WeaverServer')
logger          = require('logger')
AdminUser       = require('AdminUser')
UserService     = require('UserService')
ProjectService  = require('ProjectService')

upload = multer({
  dest: config.get('services.fileServer.uploads')
})

server
.getApp()
.post('/upload', upload.single('file'), (req, res, next) ->
  logger.code.debug('target: ' + req.body.target)
  logger.code.debug('file name: ' + req.body.fileName)
  logger.code.debug('authToken: ' + req.body.authToken)

  if not req.body.authToken?
    res.status(500).send('No authToken provided')
    return

  if not req.body.target?
    res.status(500).send('No target provided')
    return

  # Check permission
  if not AdminUser.hasAuthToken(req.body.authToken)
    user = UserService.getUser(req.body.authToken)
    user.isAdmin = -> false
    project = ProjectService.get(req.body.target)
    try
      AclService.assertACLWritePermission(user, project.acl)
    catch err
      res.status(500).send('Permission denied')
      return

  # All good
  FileService.uploadFileStream(req.file.path,req.body.fileName, req.body.target)
  .then((resol) ->
    logger.code.debug(resol)
    res.send(resol)
  )
  .catch((err) ->
    logger.code.error(err)
    res.status(500).send('Error somewhere')
  )
)

bus.private('file.downloadByID')
  .retrieve('project', 'user')
  .require('target', 'id')
  .on((req, project, user, target, id) ->

    AclService.assertACLReadPermission(user, project.acl)

    FileService.downloadFileByID(id, target)
    .catch((err) ->
      Promise.reject(Error WeaverError.FILE_NOT_EXISTS_ERROR, 'File by ID not found')
    )
  )

bus.private('file.deleteByID')
  .retrieve('project', 'user')
  .require('target', 'id')
  .on((req, project, user, target, id) ->

    AclService.assertACLWritePermission(user, project.acl)

    FileService.deleteFileByID(id, target)
    .catch((err) ->
      Promise.reject(Error WeaverError.FILE_NOT_EXISTS_ERROR, 'Project does not exists')
    )
  )
