module.exports =
  application:
    scroll: false
    singleDatabase: true
    sounds:
      muteAll: true
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

  logging:
    console: 'debug'
    file:    'warn'
