###
FileSystem.coffee
Dealing with the file management, implemented with minio

$ docker pull minio/minio
$ docker run -p 9000:9000 minio/minio server /path/to/store/the/files
###

minio = require('minio')

module.exports =
class FileSystem
  
  constructor: ->
    @minioClient = new minio.Client({
      endpoint: "#{config.get('services.fileSystem.endpoint')}".split(":")[1].replace('\/\/','')
      port: "#{config.get('services.fileSystem.endpoint')}".split(":")[2]
      secure: true
      accessKey: 'NYLEXGR6MF2IE99LZ4UE'
      secretKey: 'CjMuTRwYPcneXnGac2aQH0J+EdYdehTW4Cw7bZGD'
    })
    
  saveFile: (file) ->
    

  getFile: (file) ->
