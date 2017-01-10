WEAVER = require('RouteHandler').get("weaver")
ADMIN  = require('RouteHandler').get("admin")

# Weaver routes
WEAVER.GET   ""                       # Index Page
WEAVER.GET   "application.version"    # Application version

WEAVER.GET   "read"                   # Reads a single node
WEAVER.POST  "write"                  # Execute Create, Update and Delete operations in bulk

WEAVER.GET "logIn"

WEAVER.GET  "project"                 # Get a list of projects
WEAVER.POST "project.create"          # Create a project
WEAVER.POST "project.delete"          # Delete a project


# Admin routes
ADMIN.POST   "wipe"                   # Wipe entire database