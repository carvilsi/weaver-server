bus          = require('WeaverBus')
Weaver       = require('weaver-sdk')
Error        = Weaver.LegacyError
WeaverError  = Weaver.Error
Promise      = require('bluebird')
logger       = require('logger')
cuid         = require('cuid')
server       = require('WeaverServer')
zlib         = require('zlib')
ss           = require('socket.io-stream')
Readable     = require('stream').Readable

module.exports =
  class FileService

    getMinioClient = (project) ->
      bus.get("internal").emit('getMinioForProject', project)

    checkBucket = (project, minioClient) ->
      minioClient.bucketExists("#{project}")
        .catch((err) ->
          logger.code.debug "Minio bucket error for project #{project}: #{err.code if err?}"
          createBucket("#{project}", minioClient) if err and err.code is 'NoSuchBucket'
        )

    createBucket = (project, minioClient) ->
      minioClient.makeBucket("#{project}", "us-east-1")
        .catch((err) -> logger.code.error(err))

    @listFiles: (project) ->
      getMinioClient(project)
        .then((minioClient) ->
          new Promise((resolve, reject) ->
            files = []
            objStream = minioClient.listObjectsV2("#{project}")
            objStream.on('data', (file) -> files.push(file))
            objStream.on('end', -> resolve(files))
          )
        )

    @gunZip: (data, project) ->
      read = new Readable()
      read.push(JSON.stringify(data))
      read.push(null)

      fileName = cuid()
      gzip = zlib.createGzip()
      zippedName = fileName + '.gz'
      read.pipe(gzip)

      @uploadFile(zippedName, project.id, gzip)

    @uploadFile: (fileName, project, stream) ->
      logger.code.debug "Uploading file stream: #{fileName}, #{project}"
      getMinioClient(project)
        .then((minioClient) ->
          logger.code.debug "Got minioclient #{minioClient}"
          checkBucket(project, minioClient)
          .then( ->
            logger.code.debug "Sending file to server"
            uploadFileStream(fileName, project, minioClient, stream)
          )
        )

    @downloadFile: (project, fileId, outputStream) ->
      outputStream = ss.createStream() if not outputStream?
      getMinioClient(project)
        .then((minioClient) =>
          checkBucket(project, minioClient).then(=>
            @listFiles(project)
          ).then((files) ->
            return minioClient.getObject(project, file.name) for file in files when file.name.startsWith(fileId)

            Promise.reject({code: Weaver.Error.FILE_NOT_EXISTS_ERROR, message: 'File does not exist!'})
          ).then((readStream) ->
            readStream.pipe(outputStream)
            outputStream
          )
        )

    uploadFileStream = (fileName, project, minioClient, stream) ->
      uuid = cuid()
      minioClient
        .putObject(project, "#{uuid}-#{fileName}", stream, 'application/octet-stream')
        .then(-> Promise.resolve({
          id: uuid
          name: fileName
        }))

    @deleteFile = (fileId, project) ->
      getMinioClient(project)
        .then((minioClient) =>
          checkBucket(project, minioClient).then(=>
            @listFiles(project)
          ).then((files) ->
            return minioClient.removeObject(project, file.name) for file in files when file.name.startsWith(fileId)

            Promise.reject({code: Weaver.Error.FILE_NOT_EXISTS_ERROR, message: 'File does not exist!'})
          )
        )
