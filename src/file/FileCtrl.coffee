###
FileSystem.coffee
Dealing with the file management, implemented with minio

$ docker pull minio/minio
$ docker run -p 9000:9000 --name minio -e "MINIO_ACCESS_KEY=NYLEXGR6MF2IE99LZ4UE" -e "MINIO_SECRET_KEY=CjMuTRwYPcneXnGac2aQH0J+EdYdehTW4Cw7bZGD" -v /Path/to/store/data/minio:/data -v /Path/where/the/config/minio/exsits:/root/.minio  minio/minio server /data

###
bus          = require('WeaverBus')
Weaver       = require('weaver-sdk')
Error        = Weaver.LegacyError
WeaverError  = Weaver.Error
Promise      = require('bluebird')
logger       = require('logger')
server       = require('WeaverServer')
multer       = require('multer')
FileService = require('FileService')
AclService    = require('AclService')
UserService     = require('UserService')
AdminUser       = require('AdminUser')
ProjectService  = require('ProjectService')
config          = require('config')

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
