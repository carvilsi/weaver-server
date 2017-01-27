WEAVER = require('RouteHandler').get("weaver")
ADMIN  = require('RouteHandler').get("admin")

# Weaver routes
WEAVER.GET  ""                       # Index Page
WEAVER.GET  "application.version"    # Application version

# Database operations
WEAVER.GET  "read"                   # Reads a single entity
WEAVER.POST "write"                  # Execute Create, Update and Delete operations in bulk
WEAVER.POST "wipe"                   # Wipe entire database

# Querying
WEAVER.POST "query"                  # Execute a WeaverQuery

# User management
WEAVER.GET  "logIn"                  # Execute a log in for an existing user
WEAVER.GET  "permissions"            # Get the permissions for an existing user
WEAVER.POST "signUp"                 # Creates new user
WEAVER.POST "signOff"                # Deletes an user
WEAVER.GET  "usersList"               # Retrieves all users at weaver-flock

# Project management
WEAVER.GET  "project"                # Get a list of projects
WEAVER.POST "project.create"         # Create a project
WEAVER.POST "project.delete"         # Delete a project
WEAVER.POST "project.ready"          # Checks if a project is setup and ready
WEAVER.POST "application"            # Creates an application

# Files management
WEAVER.POST "uploadFile"             # Sends a file to be stored at the object storage server
WEAVER.GET  "downloadFile"           # Retrieves a file from the object storage server by fileName
WEAVER.GET  "downloadFileByID"       # Retrieves a file from the object storage server by ID
WEAVER.POST "deleteFile"             # Deletes a file from the object storage server by name
WEAVER.POST "deleteFileByID"         # Deletes a file from the object storage server by ID

# Admin routes
ADMIN.POST "wipe"                    # Wipe entire database
