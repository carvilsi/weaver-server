module.exports =
  application:
    singleDatabase: true
    sounds:
      muteAll: false
      loaded:  true
      errors:  true

  server:
    weaver:
      port: 9487
      cors: true
    admin:
      port: 9666
      enablePassword: true
      password: 'yUU2PNzcs!69GZ4B4'

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

  logging:
    console: 'error'
    file:    'warn'
