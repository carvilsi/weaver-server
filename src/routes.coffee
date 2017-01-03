WEAVER = require('RouteHandler').get("weaver")
ADMIN  = require('RouteHandler').get("admin")

# Weaver routes
WEAVER.GET   ""                       # Index Page
WEAVER.GET   "application.version"    # Application version

WEAVER.GET   "read"                   # Reads a single entity
WEAVER.POST  "write"                  # Execute Create, Update and Delete operations in bulk

WEAVER.GET  "projects"                # Get a list of projects
WEAVER.POST "projects.create"         # Create a project
WEAVER.POST "projects.delete"         # Delete a project

# Admin routes
ADMIN.POST   "wipe"                   # Wipe entire database

