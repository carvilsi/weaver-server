RouteHandler = require('RouteHandler')
bus          = require('WeaverBus')
config       = require('config')

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
route.private.POST "nodes"                   # Lists all nodes on the database
route.private.POST "node.clone"              # Clone a specific node
route.private.GET  "relations"               # Lists all relations on the database
route.private.GET  "history"                 # Change history by element
route.private.GET  "snapshot"                # Download snapshot write operations
route.private.GET  "snapshotGraph"           # Download snapshot write operations

# Querying
route.private.POST "query"                   # Execute a WeaverQuery
route.private.POST "query.native"            # Execute a native query

# Authentication
route.private.GET  "users"                   # Gets all users
route.private.GET  "projectUsers"            # Gets users beloning to a project

if config.get('application.openUserCreation')
  route.public.POST  "user.signUp"             # Sign up a new user
else
  route.private.POST  "user.signUp"             # Sign up a new user

route.public.POST  "user.signInUsername"     # Sign in using username and password
route.public.POST  "user.signInToken"        # Sign in using a token
route.private.POST "user.signOut"            # Sign out session identified by authToken
route.private.POST "user.read"               # Gets user object using authToken
route.private.POST "user.roles"              # Gets roles for user
route.private.POST "user.projects"           # Gets projects for user
route.private.POST "user.delete"             # Destroys user
route.private.POST "user.update"             # Updates a user profile
route.private.POST "user.changePassword"     # Changes password
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
route.private.GET  "project.freeze"          # Freezes a project
route.private.GET  "project.unfreeze"        # Unfreezes project
route.private.POST "project.app.add"         # Add compatible app to project
route.private.POST "project.app.remove"      # Remove compatible app to project
route.private.POST "project.executeZip"      # Executes a ZIP with WriteOperations
route.private.POST "project.create"          # Create a project
route.private.POST "project.clone"           # Clones a project
route.private.POST "project.name"            # Renames a project
route.private.POST "project.delete"          # Delete a project
route.private.POST "project.ready"           # Checks if a project is setup and ready
route.private.POST "project.wipe"            # Wipe a single project
route.private.POST "projects.wipe"           # Wipe all projects
route.private.POST "projects.destroy"        # Destroy all projects

# Plugins
route.private.GET  "plugins"                 # Get a list of plugins
route.private.POST "plugin.read"             # Get a single plugin

# Files management
route.private.GET  "file.list"               # Retreive all files from a bucket
route.private.GET  "file.download"           # Downloads a file from the object storage using an ID
route.private.POST "file.upload"             # Uploads a file to the object storage server
route.private.POST "file.delete"             # Deletes a file from the object storage by ID
#LEGACY ROUTES
route.private.GET "file.downloadByID"
route.private.POST "file.deleteByID"

# Socket events
route.private.POST "socket.shout"            # Shout a message to all other connected clients

# Model
route.private.POST "model.read"              # Get a single model
route.private.POST "model.reload"            # Reloads a model by reading the yaml file again

# Return array of handlers
module.exports = route
