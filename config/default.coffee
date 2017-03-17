module.exports =
  admin:
    username: 'admin'
    password: 'admin'
    generatePassword: false

  projectPool: [
    {
      database: 'http://localhost:9474'
      fileServer:
        endpoint: 'http://localhost:9000'
        accessKey: 'NYLEXGR6MF2IE99LZ4UE'
        secretKey: 'CjMuTRwYPcneXnGac2aQH0J+EdYdehTW4Cw7bZGD'
    }
#    {
#      database: 'http://localhost:9475'
#      fileServer:
#        endpoint: 'http://localhost:9001'
#        accessKey: 'NYLEXGR6MF2IE99LZ4UE'
#        secretKey: 'CjMuTRwYPcneXnGac2aQH0J+EdYdehTW4Cw7bZGD'
#    }
  ]

  application:
    wipe: true
    scroll: true
    singleDatabase: true
    sounds:
      muteAll: false
      loaded:  true
      errors:  true

  server:
    port: 9487
    cors: true

  comm:
    http:
      enable: true
    socket:
      enable: true

  services:
    projectController:
      endpoint: 'http://localhost:9888'

  logging:
    console: 'error'
    file:    'warn'
