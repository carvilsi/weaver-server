RouteHandler = require('RouteHandler')
bus          = require('WeaverBus')

route =
  public  : new RouteHandler(bus.get("public"))
  private : new RouteHandler(bus.get("private"))
  admin   : new RouteHandler(bus.get("admin"))

# Application
route.public.GET   "application.version"     # Application version
route.private.POST "application.wipe"        # Complete system wipe of all data (users, projects, etc)

# Database operations
route.private.GET  "read"                    # Reads a single entity
route.private.POST "write"                   # Execute Create, Update and Delete operations in bulk
route.private.POST "wipe"                    # Wipe entire database
route.private.POST "nodes"                   # Lists all nodes on the database
route.private.GET  "relations"               # Lists all relations on the database

# Querying
route.private.POST "query"                   # Execute a WeaverQuery
route.private.POST "query.native"            # Execute a native query

# Authentication
route.public.POST  "auth.signUp"             # Sign up a new user
route.public.POST  "auth.signIn"             # Sign in using username and password
route.private.POST "auth.getUser"            # Gets user object using authToken
route.private.POST "auth.destroyUser"        # Destroys user. Only user itself right now. TODO: WHO CAN DO THIS?
route.private.POST "auth.signOut"            # Sign out session identified by authToken
route.private.POST "auth.signOut.all"        # Sign out all active sessions

###
  User object must have an ACL because others can create the user. But what if users are created automatically?
###

# User management
route.private.GET  "users"                   # Get all users
route.private.POST "users.create"            # Creates a user
route.private.GET  "users.delete"            # Deletes a user

# Access Control List (ACL)
route.private.POST "acl.read"                # Gets an ACL
route.private.POST "acl.write"               # Creates or saves an ACL
route.private.GET  "acl.delete"              # Deletes an ACL

# Project management
route.private.GET  "project"                 # Get a list of projects
route.private.POST "project.create"          # Create a project
route.private.POST "project.delete"          # Delete a project
route.private.POST "project.ready"           # Checks if a project is setup and ready

# Files management
route.private.POST "file.upload"              # Sends a file to be stored at the object storage server
route.private.GET  "file.download"            # Retrieves a file from the object storage server by fileName
route.private.GET  "file.downloadByID"        # Retrieves a file from the object storage server by ID
route.private.POST "file.delete"              # Deletes a file from the object storage server by name
route.private.POST "file.deleteByID"          # Deletes a file from the object storage server by ID


# Return array of handlers
module.exports = (handler for name, handler of route)
