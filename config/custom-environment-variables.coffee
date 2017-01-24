module.exports =
  server:
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
