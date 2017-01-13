module.exports =
  server:
    weaver:
      port: 9487                      # Port to connect to
      cors: true                      # Allow cross origin requests
    admin:
      port: 9666
      password: 'yUU2PNzcs!69GZ4B4'
  
  comm:
    http:
      enable: true
    socket:
      enable: true
      
  services:
    database:
      endpoint: 'http://localhost:9474'
    chirql:
      host: 'localhost'
      port: 9573
    flock:
      host: 'localhost'
      port: 4567
      endpoint:'http://localhost:4567/api/v1'
    project:
      endpoint: 'http://localhost:9888'

  logging:
    console: 'ERROR'
    file:    'WARN'
