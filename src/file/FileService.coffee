bus          = require('WeaverBus')
Weaver       = require('weaver-sdk')
Error        = Weaver.LegacyError
WeaverError  = Weaver.Error
Promise      = require('bluebird')
logger       = require('logger')
fs           = require('fs')
cuid         = require('cuid')
server       = require('WeaverServer')
zlib         = require('zlib')
config       = require('config')

module.exports =
  class FileService

    constructor: ->

    getMinioClient = (project) ->
      bus.get("internal").emit('getMinioForProject', project)


    checkBucket = (project, minioClient) ->
      new Promise((resolve, reject) =>
        minioClient.bucketExists("#{project}", (err) ->
          logger.code.debug "bucket #{project} exists: #{err.code if err?}"
          if err and err.code is 'NoSuchBucket'
            createBucket("#{project}", minioClient).then(->
              resolve()
            )
          else
            resolve()
        )
      )

    createBucket = (project, minioClient) ->
      new Promise((resolve, reject) =>
        minioClient.makeBucket("#{project}", "us-east-1", (err) ->
          if err
            logger.code.error(err)
            reject()
          else
            resolve()
        )
      )

    @writeToDisk: (text) ->
      filename = cuid()
      path = config.get('services.fileServer.uploads')
      url = path + filename

      writeFile = Promise.promisify(fs.writeFile)
      
      writeFile(url, JSON.stringify(text)).then(->
        {path: path, name: filename, url}
      )

    @gunZip: (filename, project) ->
      gzip = zlib.createGzip()
      path = config.get('services.fileServer.uploads')
      zippedName = filename + '.gz'
      url = path + zippedName
      r = fs.createReadStream(path + filename)
      w = fs.createWriteStream(url)
      r.pipe(gzip).pipe(w)
      
      fs.unlink(config.get('services.fileServer.uploads') + filename, (err) ->
        if err
          logger.code.error('An error occurred trying to delete the file: '.concat(err))
        else
          logger.code.debug('Successfully deleted source file')
      )

      @uploadFileStream(url, zippedName, project.id)
      
    @uploadFileStream: (filePath, fileName, project) ->
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

    sendFileToServer: (file, fileName, project, minioClient) ->
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
