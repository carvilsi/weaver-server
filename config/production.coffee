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

    tracker:
      enabled: true
      host: 'trackerdb-alpha'
      port: 3306
      user: 'root'
      password: 'K00B88HQB1UV9MZ7YYUP'
      database: 'trackerdb'

  logging:
    console: 'error'
    file:    'warn'