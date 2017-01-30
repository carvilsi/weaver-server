###
FileSystem.coffee
Dealing with the file management, implemented with minio

$ docker pull minio/minio
$ docker run -p 9000:9000 --name minio -e "MINIO_ACCESS_KEY=NYLEXGR6MF2IE99LZ4UE" -e "MINIO_SECRET_KEY=CjMuTRwYPcneXnGac2aQH0J+EdYdehTW4Cw7bZGD" -v /Path/to/store/data/minio:/data -v /Path/where/the/config/minio/exsits:/root/.minio  minio/minio server /data

###
bus          = require('EventBus').get('weaver')
config       = require('config')
Weaver       = require('weaver-sdk')
Error        = Weaver.LegacyError
WeaverError  = Weaver.Error
Promise      = require('bluebird')
logger       = require('logger')
minio        = require('minio')
MinioClass   = require('MinioClient')
fs           = require('fs')
cuid         = require('cuid')

checkBucket = (project, minioClient) ->
  new Promise((resolve, reject) =>
    minioClient.bucketExists("#{project}", (err) ->
      if err and err.code is 'NoSuchBucket'
        createBucket("#{project}", minioClient)
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
  
sendFileToServer = (file, fileName, project, minioClient) ->
  buf = new Buffer(file.data)
  uuid = cuid()
  new Promise((resolve, reject) =>
    minioClient.putObject("#{project}","#{uuid}-#{fileName}",buf, 'application/octet-stream', (err) ->
      if err
        reject(err)
      else
        resolve("#{uuid}-#{fileName}")
    )
  )

downloadFile = (fileName, project) ->
  new Promise((resolve, reject) =>
    minioClient = MinioClass.getInstance().minioClient
    size = 0
    bufArray = []
    try
      minioClient.getObject("#{project}","#{fileName}", (err, stream) ->
        if err
          reject(err)
        else
          stream.on('data', (chunk) ->
            size += chunk.length
            bufArray.push(chunk)
          )
          stream.on('end', ->
            buffer = Buffer.concat(bufArray)
            resolve(buffer)
          )
          stream.on('error', (err) ->
            reject(err)
          )
      )
    catch error
      reject(error)
  )
  
deleteFile = (fileName, project) ->
  new Promise((resolve, reject) =>
    minioClient = MinioClass.getInstance().minioClient
    try
      minioClient.removeObject("#{project}","#{fileName}", (err) ->
        if err and err.code is 'NoSuchBucket'
          reject(Error(WeaverError.FILE_NOT_EXISTS_ERROR, 'Project not found'))
        else
          resolve()
      )
    catch error
      reject(error)
  )

downloadFileByID = (id, project) ->
  new Promise((resolve, reject) =>
    minioClient = MinioClass.getInstance().minioClient
    size = 0
    bufArray = []
    try
      file = false
      stream = minioClient.listObjectsV2("#{project}","#{id}", true)
      stream.on('data', (obj) ->
        file = true
        resolve(downloadFile(obj.name,project))
      )
      stream.on('error', (err) ->
        file = true
        reject(err)
      )
      stream.on('end', (smt) ->
        if !file
          reject('file not found')
      )
    catch error
      reject(error)
  )

deleteFileByID = (id, project) ->
  new Promise((resolve, reject) =>
    minioClient = MinioClass.getInstance().minioClient
    size = 0
    bufArray = []
    try
      file = false
      stream = minioClient.listObjectsV2("#{project}","#{id}", true)
      stream.on('data', (obj) ->
        file = true
        resolve(deleteFile(obj.name,project))
      )
      stream.on('error', (err) ->
        file = true
        reject(err)
      )
      stream.on('end', (smt) ->
        if !file
          reject('file not found')
      )
    catch error
      reject(error)
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
  if !req.payload.target?
    Promise.reject(Error WeaverError.DATATYPE_INVALID, 'The provided data is not valid. You must provide a target.')
  else if !req.payload.fileName?
    Promise.reject(Error WeaverError.DATATYPE_INVALID, 'The provided data is not valid. You must provide a file name.')
  else
    downloadFile(req.payload.fileName,req.payload.target)
)

bus.on('downloadFileByID', (req, res) ->
  if !req.payload.target?
    Promise.reject(Error WeaverError.DATATYPE_INVALID, 'The provided data is not valid. You must provide a target.')
  else if !req.payload.id?
    Promise.reject(Error WeaverError.DATATYPE_INVALID, 'The provided data is not valid. You must provide an ID.')
  else
    downloadFileByID(req.payload.id,req.payload.target)
    .catch((err) ->
      Promise.reject(Error WeaverError.FILE_NOT_EXISTS_ERROR, 'File by ID not found')
    )
)

bus.on('deleteFile', (req, res) ->
  if !req.payload.target?
    Promise.reject(Error WeaverError.DATATYPE_INVALID, 'The provided data is not valid. You must provide a target.')
  else if !req.payload.fileName?
    Promise.reject(Error WeaverError.DATATYPE_INVALID, 'The provided data is not valid. You must provide a file name.')
  else
    deleteFile(req.payload.fileName,req.payload.target)
)

bus.on('deleteFileByID', (req, res) ->
  if !req.payload.target?
    Promise.reject(Error WeaverError.DATATYPE_INVALID, 'The provided data is not valid. You must provide a target.')
  else if !req.payload.id?
    Promise.reject(Error WeaverError.DATATYPE_INVALID, 'The provided data is not valid. You must provide an ID.')
  else
    deleteFileByID(req.payload.id,req.payload.target)
    .catch((err) ->
      Promise.reject(Error WeaverError.FILE_NOT_EXISTS_ERROR, 'Project does not exists')
    )
)
