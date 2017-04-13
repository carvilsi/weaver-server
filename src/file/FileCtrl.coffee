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
MinioClient  = require('MinioClient')
multer       = require('multer')
FileService = require('FileService')

upload = multer({
  dest: 'uploads/'
})

server
.getApp()
.post('/upload', upload.single('file'), (req, res, next) ->
  logger.code.debug('target: ' + req.body.target)
  logger.code.debug('file name: ' + req.body.fileName)
  logger.code.debug('authToken: ' + req.body.authToken)
  if !req.body.authToken
    res.status(500).send('No authToken provided')
  else
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
.require('target', 'id', 'authToken')
.on((req, target, id) ->
  FileService.downloadFileByID(id, target)
  .catch((err) ->
    Promise.reject(Error WeaverError.FILE_NOT_EXISTS_ERROR, 'File by ID not found')
  )
)

bus.private('file.deleteByID')
.require('target', 'id', 'authToken')
.on((req, target, id) ->
  FileService.deleteFileByID(id, target)
  .catch((err) ->
    Promise.reject(Error WeaverError.FILE_NOT_EXISTS_ERROR, 'Project does not exists')
  )
)

bus.provide('minio').retrieve('project').on((req, project) ->
  MinioClient.create(project.fileServer)
)
