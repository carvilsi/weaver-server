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
PassThrough  = require('stream').PassThrough

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
          checkBucket(project, minioClient).then(->
            new Promise((resolve, reject) ->
              files = []
              objStream = minioClient.listObjectsV2("#{project}")
              objStream.on('data', (file) -> files.push(file))
              objStream.on('end', -> resolve(files))
            )
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


    @storeZip: (data, project) ->
      fileName = cuid()
      zippedName = fileName + '.gz'

      pass = new PassThrough()
      data.pipe(pass)

      @uploadFile(zippedName, project.id, pass)

    @uploadFile: (fileName, project, stream) ->
      logger.code.debug "Uploading file stream: #{fileName}, #{project}"
      getMinioClient(project)
        .then((minioClient) ->
          logger.code.debug "Got minioclient #{minioClient}"
          checkBucket(project, minioClient)
          .then( ->
            logger.code.debug "Sending file to server"
            uploadStream(fileName, project, minioClient, stream)
          )
        )

    @downloadFile: (project, fileId, outputStream = ss.createStream()) ->
      getMinioClient(project)
        .then((minioClient) =>
          checkBucket(project, minioClient).then(=>
            @listFiles(project)
          ).then((files) ->
            return minioClient.getObject(project, file.name) for file in files when file.name.startsWith(fileId)

            Promise.reject({code: Weaver.Error.FILE_NOT_EXISTS_ERROR, message: 'File does not exist!'})
          ).then((readStream) ->
            return readStream if outputStream is false
            readStream.pipe(outputStream)
            outputStream
          )
        )

    uploadStream = (fileName, project, minioClient, stream) ->
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

    #######################################
    # LEGACY FUNCTIONS                    #
    # These should eventually be removed  #
    #######################################
    fs = require('fs')

    @uploadFileStream = (filePath, fileName, project) ->
      logger.code.debug "Uploading file stream: #{filePath}, #{fileName}, #{project}"
      getMinioClient(project).then((minioClient) ->
        logger.code.debug "Got minioclient #{minioClient}"
        checkBucket(project, minioClient)
        .then( ->
          logger.code.debug "Sending file to server"
          readStream = fs.createReadStream(filePath)
          sendFileToServerStream(readStream, fileName, project, minioClient, filePath)
        )
      )

    sendFileToServerStream = (readStream, fileName, project, minioClient, filePath) ->
      uuid = cuid()
      new Promise((resolve, reject) =>
        minioClient.putObject("#{project}","#{uuid}-#{fileName}",readStream, 'application/octet-stream', (err) ->
          if err
            reject(err)
          else
            try
              fs.unlink(filePath, (err) ->
                if err
                  logger.code.error('An error trying to delete the file: '.concat(err))
                else
                  logger.code.debug('successfully deleted')
              )
            catch error
              logger.code.error('An error trying to delete the file: '.concat(error))
            finally
              resolve("#{uuid}-#{fileName}")
        )
      )

    @downloadFileByID: (id, project) ->
      new Promise((resolve, reject) =>
        getMinioClient(project).then((minioClient) ->
          size = 0
          bufArray = []
          try
            file = false
            logger.code.debug("The id of the desire file: #{id}")
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
        ).catch((err) ->
          reject(err)
        )
      )

    @deleteFileByID: (id, project) ->
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

    downloadFile = (fileName, project) ->
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
                  resolve(buffer)
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
