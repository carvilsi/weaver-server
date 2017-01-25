###
FileSystem.coffee
Dealing with the file management, implemented with minio

$ docker pull minio/minio
$ docker run -p 9000:9000 --name minio -e "MINIO_ACCESS_KEY=NYLEXGR6MF2IE99LZ4UE" -e "MINIO_SECRET_KEY=CjMuTRwYPcneXnGac2aQH0J+EdYdehTW4Cw7bZGD" -v /Path/to/store/data/minio:/data -v /Path/where/the/config/minio/exsits:/root/.minio  minio/minio server /data

###
bus          = require('EventBus').get('weaver')
config       = require('config')
Error        = require('weaver-commons').Error
WeaverError  = require('weaver-commons').WeaverError
Promise      = require('bluebird')
logger       = require('logger')
minio        = require('minio')
MinioClass   = require('MinioSingleton')
fs           = require('fs')

checkBucket = (project, minioClient) ->
  new Promise((resolve, reject) =>
    minioClient.bucketExists("#{project}", (err) ->
      if err and err.code is 'NoSuchBucket'
        createBucket("#{project}", minioClient).then(  ->
          resolve()
        ).catch((err) ->
          reject(err)
        )
      else
        resolve()
    )
  )
  
createBucket = (project, minioClient) ->
  new Promise((resolve, reject) =>
    minioClient.makeBucket("#{project}", "#{config.get('services.fileSystem.region')}", (err) ->
      if err
        reject()
      else
        resolve()
    )
  )

uploadFile = (file, fileName, project) ->
  minioClient = MinioClass.getInstance().minioClient
  checkBucket(project, minioClient)
  .then( ->
    sendFileToServer(file, fileName, project, minioClient)
  )
  .catch((error) ->
    error
  )
  
sendFileToServer = (file, fileName, project, minioClient) ->
  buf = new Buffer(file.data)
  minioClient.putObject("#{project}","#{fileName}",buf, 'application/octet-stream', (err) ->
    if err
      logger.error(err)
      Promise.reject(err)
    else
      logger.debug('file uploaded ok')
      Promise.resolve('file uploaded ok')
  )

downloadFile = (fileName, project, minioClient) ->
  new Promise((resolve, reject) =>
    
    minioClient = MinioClass.getInstance().minioClient
    size = 0
    bufArray = []
    minioClient.getObject("#{project}","#{fileName}", (err, stream) ->
      if err
        logger.error(err)
        reject(err)
      else
        logger.debug('success :)')
        stream.on('data', (chunk) ->
          size += chunk.length
          bufArray.push(chunk)
          logger.debug(chunk)
        )
        stream.on('end', ->
          logger.debug('total size: ' + size)
          buffer = Buffer.concat(bufArray)
          resolve(buffer)
        )
        stream.on('error', (err) ->
          logger.error(err)
          reject(err)
        )
    )
  )
  
bus.on('uploadFile', (req, res) ->
  if !req.payload.target?
    Promise.reject(Error WeaverError.DATATYPE_INVALID, 'The provided data is not valid. You must provide a target.')
  else if !req.payload.buffer.data?
    Promise.reject(Error WeaverError.DATATYPE_INVALID, 'The provided data is not valid. You must provide an attached file.')
  else if !req.payload.fileName?
    Promise.reject(Error WeaverError.DATATYPE_INVALID, 'The provided data is not valid. You must provide a file name.')
  else
    uploadFile(req.payload.buffer,req.payload.fileName,req.payload.target)
)

bus.on('downloadFile', (req, res) ->
  logger.debug(req)
  if !req.payload.target?
    Promise.reject(Error WeaverError.DATATYPE_INVALID, 'The provided data is not valid. You must provide a target.')
  else if !req.payload.fileName?
    Promise.reject(Error WeaverError.DATATYPE_INVALID, 'The provided data is not valid. You must provide a file name.')
  else
    downloadFile(req.payload.fileName,req.payload.target)
)