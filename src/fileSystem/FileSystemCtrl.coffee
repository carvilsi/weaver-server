###
FileSystem.coffee
Dealing with the file management, implemented with minio

$ docker pull minio/minio
$ docker run -p 9000:9000 --name minio -e "MINIO_ACCESS_KEY=NYLEXGR6MF2IE99LZ4UE" -e "MINIO_SECRET_KEY=CjMuTRwYPcneXnGac2aQH0J+EdYdehTW4Cw7bZGD" -v /Path/to/store/data/minio:/data -v /Path/where/the/config/minio/exsits:/root/.minio  minio/minio server /data

###
bus          = require('WeaverBus')
config       = require('config')
Weaver       = require('weaver-sdk')
Error        = Weaver.LegacyError
WeaverError  = Weaver.Error
Promise      = require('bluebird')
logger       = require('logger')
fs           = require('fs')
cuid         = require('cuid')

getMinioClient = (project) ->
  bus.get("internal").emit('getMinioForProject', project)

checkBucket = (project, minioClient) ->
  new Promise((resolve, reject) =>
    logger.code.debug "Going to check project: #{project}"
    minioClient.bucketExists("#{project}", (err) ->
      logger.code.debug "bucket #{project} exists: #{err.code if err?}"
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
  logger.code.debug "Uploading file: #{file}, #{fileName}, #{project}"
  getMinioClient(project).then((minioClient) ->
    logger.code.debug "Got minioclient #{minioClient}"
    checkBucket(project, minioClient)
    .then( ->
      logger.code.debug "Sending file to server"
      sendFileToServer(file, fileName, project, minioClient)
    )
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

downloadFile = (fileName, project, browserSDK) ->
  new Promise((resolve, reject) =>
    getMinioClient(project).then((minioClient) ->
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
              if !browserSDK
                resolve(buffer)
              else
                resolve(buffer.toString('base64'))
            )
            stream.on('error', (err) ->
              reject(err)
            )
        )
      catch error
        reject(error)
    ).catch((err) ->
      reject(err)
    )
  )

deleteFile = (fileName, project) ->
  new Promise((resolve, reject) =>
    getMinioClient(project).then((minioClient) ->
      try
        minioClient.removeObject("#{project}","#{fileName}", (err) ->
          if err and err.code is 'NoSuchBucket'
            reject(Error(WeaverError.FILE_NOT_EXISTS_ERROR, 'Project not found'))
          else
            resolve()
        )
      catch error
        reject(error)
    ).catch((err) ->
      reject(err)
    )
  )

downloadFileByID = (id, project, browserSDK) ->
  new Promise((resolve, reject) =>
    getMinioClient(project).then((minioClient) ->
      size = 0
      bufArray = []
      try
        file = false
        stream = minioClient.listObjectsV2("#{project}","#{id}", true)
        stream.on('data', (obj) ->
          file = true
          resolve(downloadFile(obj.name,project, browserSDK))
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
    ).catch((err) ->
      reject(err)
    )
  )

deleteFileByID = (id, project) ->
  new Promise((resolve, reject) =>
    getMinioClient(project).then((minioClient) ->
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
    ).catch((err) ->
      reject(err)
    )
  )

bus.private('file.upload').require('target', 'buffer', 'fileName').on((req, target, buffer, fileName) ->
  uploadFile(buffer, fileName, target)
)

bus.private('file.download').require('target', 'fileName').on((req, target, fileName) ->
  downloadFile(fileName, target, false)
)

bus.private('file.browser.sdk.download').require('target', 'fileName').on((req, target, fileName) ->
  downloadFile(fileName, target, true)
)

bus.private('file.downloadByID').require('target', 'id').on((req, target, id) ->
  downloadFileByID(id, target, false)
  .catch((err) ->
    Promise.reject(Error WeaverError.FILE_NOT_EXISTS_ERROR, 'File by ID not found')
  )
)

bus.private('file.browser.sdk.downloadByID').require('target', 'id').on((req, target, id) ->
  downloadFileByID(id, target, true)
  .catch((err) ->
    Promise.reject(Error WeaverError.FILE_NOT_EXISTS_ERROR, 'File by ID not found')
  )
)

bus.private('file.delete').require('target', 'fileName').on((req, target, fileName) ->
  deleteFile(fileName, target)
)

bus.private('file.deleteByID').require('target', 'id').on((req, target, id) ->
  deleteFileByID(id, target)
  .catch((err) ->
    Promise.reject(Error WeaverError.FILE_NOT_EXISTS_ERROR, 'Project does not exists')
  )
)
