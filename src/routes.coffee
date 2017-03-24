RouteHandler = require('RouteHandler')
bus          = require('WeaverBus')

route =
  public  : new RouteHandler(bus.get("public"))
  private : new RouteHandler(bus.get("private"))
  admin   : new RouteHandler(bus.get("admin"))

# Application
route.public.GET   "application.version"     # Application version
route.public.POST  "application.wipe"        # Complete system wipe of all data (users, projects, etc)

# Database operations
route.private.GET  "read"                    # Reads a single entity
route.private.POST "write"                   # Execute Create, Update and Delete operations in bulk
route.private.POST "wipe"                    # Wipe entire database
route.private.POST "nodes"                   # Lists all nodes on the database
route.private.GET  "relations"               # Lists all relations on the database
route.private.GET  "history"                 # Change history by element

# Querying
route.private.POST "query"                   # Execute a WeaverQuery
route.private.POST "query.native"            # Execute a native query

# Authentication
route.public.POST  "user.signUp"             # Sign up a new user
route.public.POST  "user.signIn"             # Sign in using username and password
route.private.POST "user.signOut"            # Sign out session identified by authToken
route.private.POST "user.read"               # Gets user object using authToken
route.private.POST "user.delete"             # Destroys user

# CRUD: Access Control List (ACL)
route.private.POST "acl.create"
route.private.POST "acl.read"
route.private.POST "acl.read.byObject"       # Gets the ACL by the object id that it applies to
route.private.POST "acl.update"
route.private.GET  "acl.delete"

# CRUD: Roles used for authentication
route.private.POST "role.create"
route.private.GET  "role.read"
route.private.POST "role.update"
route.private.POST "role.delete"

# Project management
route.private.GET  "project"                 # Get a list of projects
route.private.POST "project.create"          # Create a project
route.private.POST "project.delete"          # Delete a project
route.private.POST "project.ready"           # Checks if a project is setup and ready

# Files management
route.private.POST "file.upload"                          # Sends a file to be stored at the object storage server
route.private.GET  "file.download"                        # Retrieves a file from the object storage server by fileName
route.private.GET  "file.browser.sdk.download"            # Retrieves a file from the object storage server by fileName using the js SDK from Browser
route.private.GET  "file.downloadByID"                    # Retrieves a file from the object storage server by ID
route.private.GET  "file.browser.sdk.downloadByID"        # Retrieves a file from the object storage server by ID using the js SDK from Browser
route.private.POST "file.delete"                          # Deletes a file from the object storage server by name
route.private.POST "file.deleteByID"                      # Deletes a file from the object storage server by ID


# Return array of handlers
module.exports = (handler for name, handler of route)
