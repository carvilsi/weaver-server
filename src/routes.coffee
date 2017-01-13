WEAVER = require('RouteHandler').get("weaver")
ADMIN  = require('RouteHandler').get("admin")

# Weaver routes
WEAVER.GET  ""                       # Index Page
WEAVER.GET  "application.version"    # Application version

WEAVER.GET  "read"                   # Reads a single entity
WEAVER.POST "write"                  # Execute Create, Update and Delete operations in bulk

WEAVER.GET  "logIn"                   # Execute a log in for an existing user
WEAVER.GET  "permissions"             # Get the permissions for an existing user
WEAVER.POST "signUp"                  # Creates new user
WEAVER.POST "signOff"                  # Deletes an user

WEAVER.GET  "project"                 # Get a list of projects
WEAVER.POST "project.create"          # Create a project
WEAVER.POST "project.delete"          # Delete a project


# Admin routes
ADMIN.POST "wipe"                   # Wipe entire database

