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
    redis:
      host: 'localhost'
      port: 6379
    connector:
      host: 'localhost'
      port: 9474
    chirql:
      host: 'localhost'
      port: 9573
    flock:
      host: 'localhost'
      port: 7343
    project:
      endpoint: 'http://localhost:9888/api/v1'

  logging:
    console: 'ERROR'
    file:    'WARN'
