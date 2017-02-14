module.exports =
  admin:
    enabled: true
    password: 'yUU2PNzcs!69GZ4B4'

  application:
    scroll: true
    singleDatabase: true
    sounds:
      muteAll: false
      loaded:  true
      errors:  true

  server:
    port: 8787
    # port: 9487
    cors: true

  comm:
    http:
      enable: true
    socket:
      enable: true

  services:
    systemDatabase:
      endpoint: 'http://localhost:9474'
    projectDatabase:
      endpoint: 'http://localhost:9474'
    projectController:
      endpoint: 'http://localhost:9888'
    flock:
      endpoint: 'http://localhost:4567/api/v1'
    fileSystem:
      endpoint: 'http://localhost:9000'
      region: 'us-east-1' # this must match with the minio config
      accessKey: 'NYLEXGR6MF2IE99LZ4UE'
      secretKey: 'CjMuTRwYPcneXnGac2aQH0J+EdYdehTW4Cw7bZGD'
      secure: false

  logging:
    console: 'error'
    file:    'warn'
