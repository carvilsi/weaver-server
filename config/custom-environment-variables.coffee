module.exports =
  application:
    singleDatabase: "APPLICATION_SINGLE_DATABASE"
    sounds:
      muteAll: "APPLICATION_SOUNDS_MUTEALL"

  server:
    admin:
      port: "SERVER_ADMIN_PORT"
      password: "SERVER_ADMIN_PASSWORD"

    weaver:
      port: "SERVER_WEAVER_PORT"

  services:
    projectController:
      endpoint: "SERVICES_PROJECT_ENDPOINT"
    projectDatabase:
      endpoint: "SERVICES_DATABASE_ENDPOINT"
    systemDatabase:
      endpoint: "SERVICES_SYSTEM_DATABASE_ENDPOINT"
    flock:
      endpoint: "SERVICES_FLOCK_ENDPOINT"
    fileSystem:
      endpoint: "SERVICES_FILESYSTEM_ENDPOINT"
      accessKey: "SERVICES_FILESYSTEM_ACCESSKEY"
      secretKey: "SERVICES_FILESYSTEM_SECRETKEY"
