module.exports =
  admin:
    username: "ADMIN_USERNAME"

  application:
    wipe:
      __name: "APPLICATION_WIPE"
      __format: "json"
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
    port: "SERVER_PORT"

  services:
    projectController:
      endpoint:  "SERVICES_PROJECT_ENDPOINT"

  logging:
    console: "LOGGING_CONSOLE"
    file:    "LOGGING_FILE"
