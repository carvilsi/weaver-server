module.exports =
  admin:
    generatePassword: true

  application:
    wipe: false
    scroll: false
    singleDatabase: false
    sounds:
      muteAll: true

  server:
    port: 8080

  services:
    projectController:
      endpoint: 'http://localhost:9888'

  logging:
    console: 'error'
    file:    'warn'
