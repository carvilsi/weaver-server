module.exports =
  server:
    weaver:
      port: 9487
      cors: true
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
    flock:
      endpoint: 'http://localhost:4567/api/v1'
    project:
      endpoint: 'http://localhost:9888'

  logging:
    console: 'ERROR'
    file:    'WARN'