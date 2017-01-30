module.exports =
  application:
    scroll:
      # https://github.com/lorenwest/node-config/issues/272#issuecomment-223146123
      __name: "APPLICATION_SCROLL"
      __format: "json"
    singleDatabase:
      __name: "APPLICATION_SINGLE_DATABASE"
      __format: "json"
    sounds:
      muteAll:
        __name: "APPLICATION_SOUNDS_MUTEALL"
        __format: "json"

  server:
    weaver:
      port:      "SERVER_WEAVER_PORT"
    admin:
      port:         "SERVER_ADMIN_PORT"
      password:     "SERVER_ADMIN_PASSWORD"

  services:
    projectController:
      endpoint:  "SERVICES_PROJECT_ENDPOINT"
    projectDatabase:
      endpoint:  "SERVICES_DATABASE_ENDPOINT"
    systemDatabase:
      endpoint:  "SERVICES_SYSTEM_DATABASE_ENDPOINT"
    flock:
      endpoint:  "SERVICES_FLOCK_ENDPOINT"
    fileSystem:
      endpoint:  "SERVICES_FILESYSTEM_ENDPOINT"
      accessKey: "SERVICES_FILESYSTEM_ACCESSKEY"
      secretKey: "SERVICES_FILESYSTEM_SECRETKEY"
      region:    "SERVICES_FILESYSTEM_REGION"
      secure:    "SERVICES_FILESYSTEM_SECURE"

  logging:
    console: "LOGGING_CONSOLE"
    file:    "LOGGING_FILE"
