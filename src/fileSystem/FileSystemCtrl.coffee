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
  fileTemp = '/Users/char/temp/fortnightlyCheck.pdf'
  minioClient.fPutObject("#{project}","#{fileName}",fileTemp,'application/octet-stream', (err,etag) ->
    if err
      Promise.reject(err)
    else
      Promise.resolve()
  )

downloadFile = (file) ->
  fileTemp = '/Users/char/temp/downloadedFile.pdf'
  getMinioClient().fGetObject('whatever5','pdf.pdf','/Users/char/temp/downloadedFile.pdf', (err) ->
    if err
      logger.error(err)
    else
      logger.debug('success :)')
  )
  
bus.on('uploadFile', (req, res) ->
  console.log '=^^=|_uploadFile'
  uploadFile('','newFilesLolaopalTioOmmmmm.pdf','eltitoom')
)

bus.on('downloadFile', (req, res) ->
  minioClient = MinioClass.getInstance().minioClient
  console.log minioClient
)