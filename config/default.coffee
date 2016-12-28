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
      ip: 'localhost'
      port: 6379
    database:
      ip: 'localhost'
      port: 9474
    chirql:
      ip: 'localhost'
      port: 9573
    flock:
      ip: 'localhost'
      port: 7343

  logging:
    console: 'ERROR'
    file:    'WARN'