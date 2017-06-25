RouteHandler = require('RouteHandler')
bus          = require('WeaverBus')

route =
  public  : new RouteHandler(bus.get("public"))
  private : new RouteHandler(bus.get("private"))
  admin   : new RouteHandler(bus.get("admin"))

# Application
route.public.GET   "application.version"     # Application version
route.public.GET   "application.time"        # Server system time

# Database operations
route.private.GET  "read"                    # Reads a single entity
route.private.POST "write"                   # Execute Create, Update and Delete operations in bulk
route.private.POST "write.quick"             # Execute Create, Update and Delete operations in bulk without checks
route.private.POST "nodes"                   # Lists all nodes on the database
route.private.GET  "relations"               # Lists all relations on the database
route.private.GET  "history"                 # Change history by element
route.private.GET  "snapshot"                # Download snapshot write operations

# Querying
route.private.POST "query"                   # Execute a WeaverQuery
route.private.POST "query.native"            # Execute a native query

# Authentication
route.private.GET  "users"                   # Gets all users
route.public.POST  "user.signUp"             # Sign up a new user
route.public.POST  "user.signInUsername"     # Sign in using username and password
route.public.POST  "user.signInToken"        # Sign in using a token
route.private.POST "user.signOut"            # Sign out session identified by authToken
route.private.POST "user.read"               # Gets user object using authToken
route.private.POST "user.roles"              # Gets roles for user
route.private.POST "user.delete"             # Destroys user
route.private.POST "user.update"             # Updates a user profile
route.private.POST "users.wipe"              # Wipes all users

# CRUD: Access Control List (ACL)
route.private.GET  "acl.all"
route.private.GET  "acl.objects"
route.private.POST "acl.create"
route.private.POST "acl.read"
route.private.POST "acl.read.byObject"       # Gets the ACL by the object id that it applies to
route.private.POST "acl.update"
route.private.GET  "acl.delete"

# CRUD: Roles used for authentication
route.private.GET  "roles"
route.private.POST "role.create"
route.private.GET  "role.read"
route.private.POST "role.update"
route.private.POST "role.delete"

# Project management
route.private.GET  "project"                 # Get a list of projects
route.private.POST "project.create"          # Create a project
route.private.POST "project.delete"          # Delete a project
route.private.POST "project.ready"           # Checks if a project is setup and ready
route.private.POST "project.wipe"            # Wipe a single project
route.private.POST "projects.wipe"           # Wipe all projects
route.private.POST "projects.destroy"        # Destroy all projects

# Plugins
route.private.GET  "plugins"                 # Get a list of plugins
route.private.POST "plugin.read"             # Get a single plugin

# Files management
route.private.GET  "file.downloadByID"       # Retrieves a file from the object storage server by ID
route.private.POST "file.deleteByID"         # Deletes a file from the object storage server by ID

# Return array of handlers
module.exports = route
